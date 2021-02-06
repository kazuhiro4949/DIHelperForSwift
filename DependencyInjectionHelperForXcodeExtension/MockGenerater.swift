//
//  MockGenerater.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/27.
//  
//

import Foundation
import SwiftSyntax

enum MockType {
    case stub
    case spy
    
    var format: String {
        switch self {
        case .stub:
            return "%@Stub"
        case .spy:
            return Settings
                .shared
                .spySettings
                .nameFormat ?? "%@Spy"
        }
    }
}


class ProtocolNameHandler {
    let node: ProtocolDeclSyntax
    init(_ node: ProtocolDeclSyntax) {
        self.node = node
    }
    
    var originalName: String {
        node.identifier.text
    }
    
    func getBaseName() -> String {
        let nameFormat = Settings
            .shared
            .protocolSettings
            .nameFormat ?? "%@Protocol"
        
        let regexString = nameFormat
            .replacingOccurrences(
                of: "%@",
                with: "(.+)"
            )
        let regex = try? NSRegularExpression(
            pattern: "^\(regexString)$",
            options: []
        )
        
        let firstMatch = regex?.firstMatch(
            in: originalName,
            options: .anchored,
            range: originalName
                .nsString
                .range(of: originalName)
        )
        
        if let _firstMatch = firstMatch {
            return originalName.nsString
                .substring(with: _firstMatch.range(at: 1))
        } else {
            return originalName
        }
    }
}

class MockGenerater: SyntaxVisitor {
    internal init(mockType: MockType) {
        self.mockType = mockType
    }
    
    let mockType: MockType
    var mockDecls = [ClassDeclSyntax]()

    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let protocolNameHandler = ProtocolNameHandler(node)
        let baseName = protocolNameHandler.getBaseName()
        
        let mockName = String(format: mockType.format, baseName)
        let identifier = SyntaxFactory.makeIdentifier(mockName)
        
        let decls = node.members.members.compactMap { (item) -> [MemberDeclListItemSyntax]? in
            var codeBlockItems = [CodeBlockItemSyntax]()
            var memberDeclListItems = [MemberDeclListItemSyntax]()
            
            if let funcDeclSyntax = item.decl.as(FunctionDeclSyntax.self) {
                guard !Settings.shared.spySettings.getTarget(target: .function) else {
                    return []
                }
                
                let identifierBaseText = funcDeclSyntax.signatureAddedIdentifier
                
                // call properties
                if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
                    let (callVarDeclItem, callCodeBlockItem) = makeCallVal(
                        identifierBaseText: identifierBaseText
                    )
                    codeBlockItems.append(callCodeBlockItem)
                    memberDeclListItems.append(callVarDeclItem)
                }
                // count properties
                if !Settings.shared.spySettings.getCapture(capture: .callCount) {
                    let (countVarDeclItem, countCodeBlockItem) = makeCountVal(
                        identifierBaseText: identifierBaseText
                    )
                    codeBlockItems.append(countCodeBlockItem)
                    memberDeclListItems.append(countVarDeclItem)
                }
                // arg properties
                if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
                    let argsVal = makeArgsValIfNeeded(
                        identifierBaseText: identifierBaseText,
                        funcDecl: funcDeclSyntax
                    )
                    if let (argsVarDeclItem, argsCodeBlockItem) = argsVal {
                        codeBlockItems.append(argsCodeBlockItem)
                        memberDeclListItems.append(argsVarDeclItem)
                    }
                }
                
                // val properties
                let returnVal = makeReturnValIfNeeded(
                    identifierBaseText: identifierBaseText,
                    funcDecl: funcDeclSyntax
                )
                if let (returnVarDeclItem, returnCodeBlockItem) = returnVal {
                    codeBlockItems.append(returnCodeBlockItem)
                    memberDeclListItems.append(returnVarDeclItem)
                }
                
                // block
                let block = SyntaxFactory.makeCodeBlock(
                    leftBrace: SyntaxFactory.makeLeftBraceToken(
                        leadingTrivia: .spaces(1),
                        trailingTrivia: [.spaces(1), .newlines(1)]
                    ),
                    statements: SyntaxFactory
                        .makeCodeBlockItemList(codeBlockItems),
                    rightBrace: SyntaxFactory.makeRightBraceToken(
                        leadingTrivia: .indent,
                        trailingTrivia: .newlines(1)
                    )
                )
                
                // function
                let funcSyntax = DeclSyntax(
                    funcDeclSyntax
                        .withBody(block)
                        .withLeadingTrivia(.indent)
                        .withTrailingTrivia(.newlines(2))
                )
                let funcSyntaxItem = SyntaxFactory
                    .makeMemberDeclListItem(
                        decl: funcSyntax,
                        semicolon: nil
                    )
                memberDeclListItems.append(funcSyntaxItem)
                return memberDeclListItems
            } else if let variableDecl = item.decl.as(VariableDeclSyntax.self) {
                guard !Settings.shared.spySettings.getTarget(target: .property) else {
                    return []
                }
                
                // protocol always has the following pattern.
                let binding = variableDecl.bindings.first!
                let accessorBlock = binding.accessor!.as(AccessorBlockSyntax.self)
                
                let identifier = binding.pattern.as(IdentifierPatternSyntax.self)!.identifier
                
                let decls = accessorBlock?.accessors.map({ (accessor) -> (AccessorDeclSyntax, [MemberDeclListItemSyntax])in
                    var memberDeclItems = [MemberDeclListItemSyntax]()
                    var codeBlockItems = [CodeBlockItemSyntax]()
                    let baseIdentifierText = "\(identifier.text)_\(accessor.accessorKind.text)"
                    
                    // wasCalled
                    if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
                        let (wasCalledDecl, wasCalledBlockExpr) = makeCallVal(
                            identifierBaseText: baseIdentifierText
                        )
                        memberDeclItems.append(wasCalledDecl)
                        codeBlockItems.append(
                            wasCalledBlockExpr
                                .withLeadingTrivia(.indent(3))
                        )
                    }
                    
                    // count
                    if !Settings.shared.spySettings.getCapture(capture: .callCount) {
                        let (countVarDecl, countBlockExpr) = makeCountVal(
                            identifierBaseText: baseIdentifierText
                        )
                        memberDeclItems.append(countVarDecl)
                        codeBlockItems.append(
                            countBlockExpr
                                .withLeadingTrivia(.indent(3))
                        )
                    }
                    
                    // args
                    if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
                        if accessor.accessorKind.text == "set", let type = binding.typeAnnotation?.type {
                            let typeSyntax: TypeSyntax
                            if let optionalType = type.as(OptionalTypeSyntax.self) {
                                typeSyntax = optionalType
                                    .wrappedType
                                    .withTrailingTrivia(.zero)
                            } else {
                                typeSyntax = type
                                    .withTrailingTrivia(.zero)
                            }
                            
                            let (argsDecl, argsBlockExpr) = makeArgsVal(
                                identifierBaseText: baseIdentifierText,
                                typeSyntax: typeSyntax,
                                substitutionExprSyntax: ExprSyntax(
                                    SyntaxFactory
                                        .makeVariableExpr("newValue")
                                        .withTrailingTrivia(.newlines(1))
                                )
                            )
                            memberDeclItems.append(argsDecl)
                            codeBlockItems.append(
                                argsBlockExpr
                                    .withLeadingTrivia(.indent(3))
                            )
                        }
                    }
                    
                    // return
                    if accessor.accessorKind.text == "get", let type = binding.typeAnnotation?.type {
                        let typeSyntax = type
                            .withTrailingTrivia(.zero)
                        
                        let (returnDecl, returnBlockExpr) = makeReturnVal(
                            identifierBaseText: baseIdentifierText,
                            typeSyntax: typeSyntax
                        )
                        memberDeclItems.append(returnDecl)
                        codeBlockItems.append(
                            returnBlockExpr
                                .withLeadingTrivia(.indent(3))
                        )
                    }
                    
                    let accessor = SyntaxFactory.makeAccessorDecl(
                        attributes: accessor.attributes,
                        modifier: accessor.modifier,
                        accessorKind: accessor.accessorKind
                            .withLeadingTrivia(.indent(3)),
                        parameter: accessor.parameter,
                        body: SyntaxFactory.makeCodeBlock(
                            leftBrace: SyntaxFactory
                                .makeLeftBraceToken()
                                .withLeadingTrivia(.spaces(1))
                                .withTrailingTrivia(.newlines(1)),
                            statements: SyntaxFactory
                                .makeCodeBlockItemList(codeBlockItems),
                            rightBrace: SyntaxFactory
                                .makeRightBraceToken()
                                .withLeadingTrivia(.indent(2))
                                .withTrailingTrivia([.newlines(1)])
                        ))
                    
                    return (accessor, memberDeclItems)
                })
                
                let patternList = SyntaxFactory.makePatternBindingList([
                    SyntaxFactory.makePatternBinding(
                        pattern: binding.pattern,
                        typeAnnotation: binding.typeAnnotation,
                        initializer: nil,
                        accessor: Syntax(
                            SyntaxFactory
                                .makeAccessorBlock(
                                    leftBrace: SyntaxFactory
                                        .makeLeftBraceToken()
                                        .withTrailingTrivia(.newlines(1)),
                                    accessors: SyntaxFactory.makeAccessorList(
                                        decls?.map { $0.0 } ?? []
                                    ),
                                    rightBrace: SyntaxFactory
                                        .makeRightBraceToken()
                                        .withLeadingTrivia(.indent)
                                        .withTrailingTrivia(.newlines(1))
                                )
                        ),
                        trailingComma: nil)
                ])
                
                let propDeclListItems = decls?.map { $0.1 }.flatMap { $0 } ?? []
                
                let variable = SyntaxFactory.makeVariableDecl(
                    attributes: nil,
                    modifiers: nil,
                    letOrVarKeyword: .makeFormattedVarKeyword(),
                    bindings: patternList)
                let declListItem = SyntaxFactory.makeMemberDeclListItem(
                    decl: DeclSyntax(variable),
                    semicolon: nil
                )
                return propDeclListItems + [declListItem]
            } else {
                return nil
            }
        }
        
        let mockClassDecl = SyntaxFactory.makeClassDecl(
            attributes: nil,
            modifiers: nil,//ModifierListSyntax?,
            classKeyword: .makeFormattedClassKeyword(),
            identifier: identifier,
            genericParameterClause: nil,
            inheritanceClause: .makeFormattedProtocol(protocolNameHandler),
            genericWhereClause: nil,
            members: .makeFormatted(with: decls)
        )
        
        mockDecls.append(mockClassDecl)
        return .skipChildren
    }
    
    private func makeReturnValIfNeeded(identifierBaseText: String, funcDecl: FunctionDeclSyntax) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    )? {
        let _output = funcDecl.signature.output
        guard let output = _output else {
            return nil
        }
        
        return makeReturnVal(
            identifierBaseText: identifierBaseText,
            typeSyntax: output.returnType
        )
    }
    
    private func makeReturnVal(
        identifierBaseText: String,
        typeSyntax: TypeSyntax) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    ) {
        let identifier = "\(identifierBaseText)_val"
        return (SyntaxFactory
                    .makeMemberDeclListItem(
                        decl: DeclSyntax(
                            VariableDeclSyntax
                                .makeReturnedValForMock(identifier, typeSyntax)
                        ),
                        semicolon: nil
                ),
                .makeFormattedExpr(
                    expr: SyntaxFactory.makeReturnKeyword(),
                    right: SyntaxFactory.makeIdentifier(identifier)
                )
        )
    }
    
    private func makeArgsValIfNeeded(
        identifierBaseText: String,
        funcDecl: FunctionDeclSyntax) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    )? {
        let paramters = funcDecl.signature.input.parameterList
        if paramters.isEmpty {
            return nil
        } else if paramters.count == 1,
                  let parameter = paramters.first,
                  let type = parameter.type {
            
            let tokenSyntax: TokenSyntax
            if let secondName = parameter.secondName {
                tokenSyntax = secondName
            } else if let firstName = parameter.firstName {
                tokenSyntax = firstName
            } else {
                tokenSyntax = SyntaxFactory.makeIdentifier("")
            }
            
            let typeSyntax: TypeSyntax
            if let optionalType = type.as(OptionalTypeSyntax.self) {
                typeSyntax = optionalType
                    .wrappedType
                    .withTrailingTrivia(.zero)
            } else {
                typeSyntax = type
                    .withTrailingTrivia(.zero)
            }
            
            
            return makeArgsVal(
                identifierBaseText: identifierBaseText,
                typeSyntax: typeSyntax,
                substitutionExprSyntax: ExprSyntax(
                    SyntaxFactory
                        .makeVariableExpr(tokenSyntax.text)
                        .withTrailingTrivia(.newlines(1))
                )
            )
        } else {
            let tupleElements = paramters
                .compactMap { paramter -> TupleTypeElementSyntax? in
                    let tokenSyntax: TokenSyntax
                    if let secondName = paramter.secondName {
                        tokenSyntax = secondName
                    } else if let firstName = paramter.firstName {
                        tokenSyntax = firstName
                    } else {
                        tokenSyntax = SyntaxFactory.makeIdentifier("")
                    }
                    
                    let type: TypeSyntax = paramter.type ?? SyntaxFactory.makeTypeIdentifier("")
                    
                    
                    return SyntaxFactory.makeTupleTypeElement(
                        name: tokenSyntax,
                        colon: paramter.colon,
                        type: type,
                        trailingComma: paramter.trailingComma)
            }
            
            let bindingTupleElements = paramters
                .compactMap { paramter -> TupleExprElementSyntax? in
                    let tokenSyntax: TokenSyntax
                    if let secondName = paramter.secondName {
                        tokenSyntax = secondName
                    } else if let firstName = paramter.firstName {
                        tokenSyntax = firstName
                    } else {
                        tokenSyntax = SyntaxFactory.makeIdentifier("")
                    }
                    
                    return SyntaxFactory.makeTupleExprElement(
                        label: nil,
                        colon: nil,
                        expression: ExprSyntax(
                            SyntaxFactory
                                .makeVariableExpr(tokenSyntax.text)
                        ),
                        trailingComma: paramter.trailingComma)
            }
            
            return makeArgsVal(
                identifierBaseText: identifierBaseText,
                typeSyntax: TypeSyntax(
                    SyntaxFactory
                        .makeTupleType(
                            leftParen: SyntaxFactory.makeLeftParenToken(),
                            elements:
                                SyntaxFactory
                                    .makeTupleTypeElementList(tupleElements),
                            rightParen: SyntaxFactory.makeRightParenToken())
                ).withLeadingTrivia(.spaces(1)),
                substitutionExprSyntax: ExprSyntax(SyntaxFactory.makeTupleExpr(
                                                    leftParen: SyntaxFactory.makeLeftParenToken(),
                                                    elementList: SyntaxFactory
                                                        .makeTupleExprElementList(
                                                            bindingTupleElements
                                                        ),
                                                    rightParen: SyntaxFactory.makeRightParenToken())
                                                    .withTrailingTrivia(.newlines(1))
                                        )
            )
        }

    }
    
    private func makeArgsVal(
        identifierBaseText: String,
        typeSyntax: TypeSyntax,
        substitutionExprSyntax: ExprSyntax) -> (
            MemberDeclListItemSyntax,
            CodeBlockItemSyntax
        ) {
        
        let identifier = "\(identifierBaseText)_args"
        return (
            .makeFormattedAssign(
                to: identifier,
                typeAnnotation: .makeFormatted(
                    TypeSyntax(SyntaxFactory
                        .makeOptionalType(
                            wrappedType: typeSyntax,
                            questionMark: SyntaxFactory.makePostfixQuestionMarkToken()
                        )
                    )
                )
            ),
            .makeFormattedExpr(
                left: SyntaxFactory.makeIdentifier(identifier),
                expr: SyntaxFactory.makeEqualToken(),
                right: substitutionExprSyntax
            )
        )

    }
    
    private func makeCountVal(identifierBaseText: String) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    ) {
        let identifier = "\(identifierBaseText)_callCount"
        return (
            .makeFormattedAssign(
                to: identifier,
                from: .makeZeroKeyword()
            ),
            .makeFormattedExpr(
                left: SyntaxFactory
                    .makeIdentifier(identifier),
                expr: SyntaxFactory.makeIdentifier("+="),
                right: SyntaxFactory.makeIntegerLiteral("1")
            )
        )
    }
    
    private func makeCallVal(identifierBaseText: String) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    ) {
        
        let callIdentifier = "\(identifierBaseText)_wasCalled"
        return (
            .makeFormattedAssign(
                to: callIdentifier,
                from: .makeFalseKeyword()
            ),
            .makeTrueSubstitutionExpr(
                callIdentifier: callIdentifier
            )
        )
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        dump(node)
        return .skipChildren
    }
}

extension String {
    var nsString: NSString {
        self as NSString
    }
    
    func replacingToVariableAllowedString() -> String {
        let trivialsRemovedParamListText = replacingOccurrences(
                of: "[\\n\\s\\t]",
                with: "",
                options: .regularExpression,
                range: self.range(of: self)
            )
        let encodedString = trivialsRemovedParamListText.replacingOccurrences(
            of: "[\\(\\)]",
            with: "$p",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        ).replacingOccurrences(
            of: "[\\[\\]]",
            with: "$b",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        ).replacingOccurrences(
            of: "[:]",
            with: "$k",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        ).replacingOccurrences(
            of: "[,]",
            with: "$c",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        )
        .replacingOccurrences(
            of: "[_]",
            with: "$u",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText))
        .replacingOccurrences(
            of: "[\\.]",
            with: "$d",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        )
        return encodedString
    }
}

extension PatternBindingListSyntax {
    static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> PatternBindingListSyntax {
        SyntaxFactory
            .makePatternBindingList([
                .makeReturnedValForMock(identifier, typeSyntax)
            ])
    }
}

extension MemberDeclBlockSyntax {
    static func makeFormatted(with decls: [[MemberDeclListItemSyntax]]) -> MemberDeclBlockSyntax {
        SyntaxFactory.makeMemberDeclBlock(
            leftBrace: .makeCleanFormattedLeftBrance(),
            members: .makeFormattedMemberDeclList(decls),
            rightBrace: .makeCleanFormattedRightBrance()
        )
    }
}

extension TypeInheritanceClauseSyntax {
    static func makeFormattedProtocol(_ handler: ProtocolNameHandler) -> TypeInheritanceClauseSyntax {
        SyntaxFactory.makeTypeInheritanceClause(
            colon: SyntaxFactory
                .makeColonToken()
                .withTrailingTrivia(.spaces(1)),
            inheritedTypeCollection: SyntaxFactory
                .makeInheritedTypeList(
                    [SyntaxFactory
                        .makeInheritedType(
                            typeName: SyntaxFactory
                                .makeTypeIdentifier(handler.originalName),
                            trailingComma: nil
                        )
                    ]
                )
        )
        .withTrailingTrivia(.spaces(1))
    }
}

extension TokenSyntax {
    static func makeFormattedVarKeyword() -> TokenSyntax {
        SyntaxFactory
            .makeVarKeyword()
            .withLeadingTrivia(.indent)
            .withTrailingTrivia(.spaces(1))
    }
    
    static func makeFormattedClassKeyword() -> TokenSyntax {
        SyntaxFactory
            .makeClassKeyword(
                leadingTrivia: .zero,
                trailingTrivia: .spaces(1)
            )
    }
    
    static func makeCleanFormattedLeftBrance() -> TokenSyntax {
        SyntaxFactory
            .makeLeftBraceToken()
            .withLeadingTrivia(.zero)
            .withTrailingTrivia(.newlines(1))
    }
    
    static func makeCleanFormattedRightBrance() -> TokenSyntax {
        SyntaxFactory
            .makeRightBraceToken()
            .withLeadingTrivia(.zero)
            .withTrailingTrivia(.newlines(1))
    }
}

extension MemberDeclListSyntax {
    static func makeFormattedMemberDeclList(_ decls: [[MemberDeclListItemSyntax]]) -> MemberDeclListSyntax {
        SyntaxFactory
            .makeMemberDeclList(decls.flatMap { $0 })
            .withLeadingTrivia(.indent)
            .withTrailingTrivia(.newlines(1))
    }
}

extension MemberDeclListItemSyntax {
    static func makeFormattedAssign(to identifier: String, from expr: ExprSyntax)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        from: expr
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
    
    static func makeFormattedAssign(to identifier: String, typeAnnotation: TypeAnnotationSyntax)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        typeAnnotation: typeAnnotation
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}

extension SyntaxFactory {
    static func makeCleanFormattedLeftBrance() -> TokenSyntax {
        SyntaxFactory
            .makeLeftBraceToken()
            .withLeadingTrivia(.zero)
            .withTrailingTrivia(.newlines(1))
    }
    
    
    static func makeCleanFormattedRightBrance() -> TokenSyntax {
        SyntaxFactory
            .makeRightBraceToken()
            .withLeadingTrivia(.zero)
            .withTrailingTrivia(.newlines(1))
    }
}

extension CodeBlockItemSyntax {
    static func makeFormattedExpr(expr: TokenSyntax, right: TokenSyntax) -> CodeBlockItemSyntax {
        SyntaxFactory.makeCodeBlockItem(
            item: Syntax(SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory
                    .makeExprList([
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: expr,
                                        declNameArguments: nil
                                    )
                                    .withLeadingTrivia(.indent(2))
                                    .withTrailingTrivia(.spaces(1))
                        ),
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: right,
                                        declNameArguments: nil
                                    )
                                    .withTrailingTrivia(.newlines(1))
                        )
                    ]))),
            semicolon: nil,
            errorTokens: nil)
    }
    
    static func makeFormattedExpr(left: TokenSyntax, expr: TokenSyntax, right: TokenSyntax) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: left,
                                    declNameArguments: nil
                                )
                                .withLeadingTrivia(.indent(2))
                                .withTrailingTrivia(.spaces(1))
                    ),
            expr: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: expr,
                                    declNameArguments: nil
                                )
                                .withTrailingTrivia(.spaces(1))
                    ),
            right: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: right,
                                    declNameArguments: nil
                                )
                                .withTrailingTrivia(.newlines(1))
                    )
        )
    }
    
    static func makeFormattedExpr(left: TokenSyntax, expr: TokenSyntax, right: ExprSyntax) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: left,
                                    declNameArguments: nil
                                )
                                .withLeadingTrivia(.indent(2))
                                .withTrailingTrivia(.spaces(1))
                    ),
            expr: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: expr,
                                    declNameArguments: nil
                                )
                                .withTrailingTrivia(.spaces(1))
                    ),
            right: right
        )
    }
    
    static func makeFormattedExpr(left: ExprSyntax, expr: ExprSyntax, right: ExprSyntax) -> CodeBlockItemSyntax {
        SyntaxFactory.makeCodeBlockItem(
            item: Syntax(SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory
                    .makeExprList([
                        left,
                        expr,
                        right
                    ]))),
            semicolon: nil,
            errorTokens: nil)
    }
    
    static func makeTrueSubstitutionExpr(callIdentifier: String) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: SyntaxFactory.makeIdentifier(callIdentifier),
            expr: SyntaxFactory.makeEqualToken(),
            right: SyntaxFactory.makeTrueKeyword()
        )
    }
}

extension VariableDeclSyntax {
    static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> VariableDeclSyntax {
        SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: .makeFormattedVarKeyword(),
            bindings: .makeReturnedValForMock(identifier, typeSyntax)
        ).withTrailingTrivia(.newlines(1))
    }
    
    static func makeDeclWithAssign(to identifier: String, from expr: ExprSyntax) -> VariableDeclSyntax {
        SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: .makeFormattedVarKeyword(),
            bindings: SyntaxFactory
                .makePatternBindingList([
                    .makeAssign(to: identifier,
                                from: expr
                    )
                ]))
    }
    
    static func makeDeclWithAssign(to identifier: String,
                                   typeAnnotation: TypeAnnotationSyntax) -> VariableDeclSyntax {
        
        SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: .makeFormattedVarKeyword(),
            bindings: SyntaxFactory
                .makePatternBindingList([
                    .makeAssign(to: identifier,
                                typeAnnotation: typeAnnotation
                    )
                ]))
    }
}

extension PatternBindingSyntax {
    static func makeAssign(to identifier: String,
                           from expr: ExprSyntax? = nil,
                           typeAnnotation: TypeAnnotationSyntax? = nil) -> PatternBindingSyntax {
        SyntaxFactory.makePatternBinding(
            pattern: PatternSyntax(SyntaxFactory
                .makeIdentifierPattern(
                    identifier: SyntaxFactory.makeIdentifier(
                        identifier
                    )
                )
            ),
            typeAnnotation: typeAnnotation,
            initializer: expr.flatMap { SyntaxFactory.makeInitializerClause(
                equal: SyntaxFactory.makeEqualToken(
                    leadingTrivia: .spaces(1),
                    trailingTrivia: .spaces(1)
                ),
                value: $0
            ) },
            accessor: nil,
            trailingComma: nil
        )
    }

    static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> PatternBindingSyntax {
        let unwrappedTypeSyntax = TokenSyntax.makeUnwrapped(typeSyntax)
        
        let processedTypeSyntax: TypeSyntax
        let valueExpr: ExprSyntax?
        if let simpleType = unwrappedTypeSyntax.as(SimpleTypeIdentifierSyntax.self),
            let literal = simpleType.tryToConvertToLiteralExpr() {
            processedTypeSyntax = typeSyntax
            valueExpr = literal
        } else if unwrappedTypeSyntax.is(ArrayTypeSyntax.self) {
            processedTypeSyntax = typeSyntax
            valueExpr = ExprSyntax(ArrayExprSyntax.makeBlank())
        } else if unwrappedTypeSyntax.is(DictionaryTypeSyntax.self) {
            processedTypeSyntax = typeSyntax
            valueExpr = ExprSyntax(DictionaryExprSyntax.makeBlank())
        } else if let functionTypeSyntax = unwrappedTypeSyntax.as(FunctionTypeSyntax.self) {
            processedTypeSyntax = TypeSyntax(
                ImplicitlyUnwrappedOptionalTypeSyntax
                    .make(TypeSyntax(
                            TupleTypeSyntax.makeParen(with: functionTypeSyntax)
                    ))
            )
            valueExpr = nil
        } else {
            processedTypeSyntax = TypeSyntax(
                ImplicitlyUnwrappedOptionalTypeSyntax
                    .make(unwrappedTypeSyntax)
            )
            valueExpr = nil
        }
        
        return SyntaxFactory.makePatternBinding(
            pattern: .makeIdentifierPatternSyntax(with: identifier),
            typeAnnotation: .makeFormatted(processedTypeSyntax),
            initializer: .makeFormatted(valueExpr),
            accessor: nil,
            trailingComma: nil
        )
    }
}

extension ImplicitlyUnwrappedOptionalTypeSyntax {
    static func make(_ unwrappedTypeSyntax: TypeSyntax) -> ImplicitlyUnwrappedOptionalTypeSyntax {
        SyntaxFactory
            .makeImplicitlyUnwrappedOptionalType(
                wrappedType: unwrappedTypeSyntax,
                exclamationMark: SyntaxFactory
                    .makeExclamationMarkToken()
            )
    }
}

extension ExprSyntax {
    static func makeFalseKeyword() -> ExprSyntax {
        ExprSyntax(SyntaxFactory
                .makeBooleanLiteralExpr(
                    booleanLiteral: SyntaxFactory
                        .makeFalseKeyword()
                )
        )
    }
    
    static func makeZeroKeyword() -> ExprSyntax {
        ExprSyntax(SyntaxFactory
                .makeBooleanLiteralExpr(
                    booleanLiteral: SyntaxFactory.makeIntegerLiteral("0")
                )
        )
    }
}

extension InitializerClauseSyntax {
    static func makeFormatted(_ valueExpr: ExprSyntax?) -> InitializerClauseSyntax? {
        valueExpr.flatMap {
            SyntaxFactory.makeInitializerClause(
                equal: .makeFormattedEqual(),
                value: $0)
        }
    }
}

extension TupleTypeSyntax {
    static func makeParen(with anonimousFunctionType: FunctionTypeSyntax) -> TupleTypeSyntax {
        SyntaxFactory.makeTupleType(
            leftParen: SyntaxFactory.makeLeftParenToken(),
            elements: SyntaxFactory
                .makeTupleTypeElementList(
                    [
                        SyntaxFactory.makeTupleTypeElement(
                            type: TypeSyntax(anonimousFunctionType),
                            trailingComma: nil)
                    ]
                ),
            rightParen: SyntaxFactory.makeRightParenToken())
    }
}

extension ArrayExprSyntax {
    static func makeBlank() -> ArrayExprSyntax {
        SyntaxFactory
            .makeArrayExpr(
                leftSquare: SyntaxFactory
                    .makeLeftSquareBracketToken(),
                elements: SyntaxFactory
                    .makeBlankArrayElementList(),
                rightSquare: SyntaxFactory
                    .makeRightSquareBracketToken()
            )
    }
}

extension DictionaryExprSyntax {
    static func makeBlank() -> DictionaryExprSyntax {
        SyntaxFactory
            .makeDictionaryExpr(
                leftSquare: SyntaxFactory
                    .makeLeftSquareBracketToken(),
                content: Syntax(DictionaryElementListSyntax.makeBlank()),
                rightSquare: SyntaxFactory
                    .makeRightSquareBracketToken())
    }
}

extension DictionaryElementListSyntax {
    static func makeBlank() -> DictionaryElementListSyntax {
        SyntaxFactory
            .makeDictionaryElementList(
                [.makeBlank()]
            )
    }
}

extension DictionaryElementSyntax {
    static func makeBlank() -> DictionaryElementSyntax {
        SyntaxFactory
            .makeDictionaryElement(
                keyExpression: ExprSyntax(
                    SyntaxFactory
                        .makeBlankUnknownExpr()
                ),
                colon: SyntaxFactory
                    .makeColonToken(),
                valueExpression: ExprSyntax(
                    SyntaxFactory
                        .makeBlankUnknownExpr()
                ),
                trailingComma: nil)
    }
}

extension TokenSyntax {
    static func makeUnwrapped(_ typeSyntax: TypeSyntax) -> TypeSyntax {
        let unwrappedTypeSyntax: TypeSyntax
        
        if let optionalTypeSyntax = typeSyntax.as(OptionalTypeSyntax.self) {
            unwrappedTypeSyntax = optionalTypeSyntax.wrappedType
        } else if let iuoTypeSyntax = typeSyntax.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            unwrappedTypeSyntax = iuoTypeSyntax.wrappedType
        } else {
            unwrappedTypeSyntax = typeSyntax
        }
        
        return unwrappedTypeSyntax
    }
    
    static func makeFormattedEqual() -> TokenSyntax {
        SyntaxFactory
            .makeEqualToken()
            .withTrailingTrivia(.spaces(1))
    }
}

extension PatternSyntax {
    static func makeIdentifierPatternSyntax(with name: String) -> PatternSyntax {
        PatternSyntax(SyntaxFactory
            .makeIdentifierPattern(
                identifier: SyntaxFactory.makeIdentifier(
                    name
                )
            )
        )
    }
}


extension TypeAnnotationSyntax {
    static func makeFormatted(_ typeSyntax: TypeSyntax) -> TypeAnnotationSyntax {
        SyntaxFactory
            .makeTypeAnnotation(
                colon: SyntaxFactory
                    .makeColonToken()
                    .withTrailingTrivia(.spaces(1)),
                type: typeSyntax
            )
            .withTrailingTrivia(.spaces(1))
    }
}

extension SimpleTypeIdentifierSyntax {
    func tryToConvertToLiteralExpr() -> ExprSyntax? {
        switch name.text {
        case "String":
            return ExprSyntax(SyntaxFactory
                .makeStringLiteralExpr(""))
        case "NSString":
            return ExprSyntax(SyntaxFactory
                .makeStringLiteralExpr(""))
        case "Int", "Int8", "Int16","Int32", "Int64", "NSInteger":
            return ExprSyntax(SyntaxFactory
                .makeIntegerLiteralExpr(
                    digits: SyntaxFactory
                        .makeIntegerLiteral("0")
                )
            )
        case "UInt", "UInt8", "UInt16","UInt32", "UInt64":
            return ExprSyntax(SyntaxFactory
                .makeIntegerLiteralExpr(
                    digits: SyntaxFactory
                        .makeIntegerLiteral("0")
                )
            )
        case "Double", "Float", "Float32", "Float64", "CGFloat":
            return ExprSyntax(SyntaxFactory
                .makeFloatLiteralExpr(
                    floatingDigits: SyntaxFactory
                        .makeFloatingLiteral("0.0")
                )
            )
        default:
            return nil
        }
    }
}

extension SyntaxFactory {
    func makeIdentifier(_ text: String) -> TokenSyntax {
        SyntaxFactory
            .makeToken(.identifier(text), presence: .present)
    }
}

extension Trivia {
    static var indent: Trivia {
        .spaces(Settings.shared.indentationValue)
    }
    
    static func indent(_ level: Int) -> Trivia {
        .spaces(Settings.shared.indentationValue * level)
    }
}

extension FunctionDeclSyntax {
    var signatureAddedIdentifier: String {
        var identifierBaseText = identifier.text
        
        // TODO:- added ignorance and increment option
        let paramListText = signature.input.parameterList.description
        let returnText = signature.output?.returnType.description ?? ""
        let encodedParamListText = paramListText.replacingToVariableAllowedString()
        let encodedReturnText = returnText.replacingToVariableAllowedString()
        if !encodedParamListText.isEmpty {
            identifierBaseText = "\(identifierBaseText)_\(encodedParamListText)"
        }
        if !encodedReturnText.isEmpty {
            identifierBaseText = "\(identifierBaseText)_\(encodedReturnText)"
        }
        
        return identifierBaseText
    }
}
