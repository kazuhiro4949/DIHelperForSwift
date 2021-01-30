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
    
    var format: String {
        switch self {
        case .stub:
            return "%@Stub"
        }
    }
}

class MockGenerater: SyntaxVisitor {
    internal init(mockType: MockType) {
        self.mockType = mockType
    }
    
    let mockType: MockType
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let nameFormat = Settings.shared.protocolSettings.nameFormat
        let regexString = nameFormat.replacingOccurrences(of: "%@", with: "(.+)")
        let regex = try? NSRegularExpression(pattern: "^\(regexString)$", options: [])
        let protocolName = node.identifier.text
        
        
        guard let match = regex?.firstMatch(in: protocolName, options: .anchored, range: protocolName.nsString.range(of: protocolName)) else {
            return .skipChildren
        }
        
        let baseName = protocolName.nsString.substring(with: match.range(at: 1))
        let title = String(format: mockType.format, baseName)
        
        let identifier = SyntaxFactory
            .makeToken(.identifier(title), presence: .present)
        
        let indentationValue = 4
        
        let decls = node.members.members.compactMap { (item) -> [MemberDeclListItemSyntax]? in
            let indentationTrivia = Trivia(pieces: [.spaces(indentationValue)])
            var codeBlockItems = [CodeBlockItemSyntax]()
            var memberDeclListItems = [MemberDeclListItemSyntax]()
            
            if let funcDeclSyntax = item.decl.as(FunctionDeclSyntax.self) {
                
                // call properties
                let (callVarDeclItem, callCodeBlockItem) = makeCallVal(
                    identifierBaseText: funcDeclSyntax.identifier.text,
                    indentationCount: indentationValue
                )
                codeBlockItems.append(callCodeBlockItem)
                memberDeclListItems.append(callVarDeclItem)
                // count properties
                let (countVarDeclItem, countCodeBlockItem) = makeCountVal(
                    identifierBaseText: funcDeclSyntax.identifier.text,
                    indentationCount: indentationValue
                )
                codeBlockItems.append(countCodeBlockItem)
                memberDeclListItems.append(countVarDeclItem)
                // arg properties
                let argsVal = makeArgsValIfNeeded(
                    funcDecl: funcDeclSyntax,
                    indentationCount: indentationValue
                )
                if let (argsVarDeclItem, argsCodeBlockItem) = argsVal {
                    codeBlockItems.append(argsCodeBlockItem)
                    memberDeclListItems.append(argsVarDeclItem)
                }
                
                // val properties
                let returnVal = makeReturnValIfNeeded(
                    funcDecl: funcDeclSyntax,
                    indentationCount: indentationValue
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
                        leadingTrivia: indentationTrivia,
                        trailingTrivia: .newlines(1)
                    )
                )
                
                // function
                let funcSyntax = DeclSyntax(
                    funcDeclSyntax
                        .withBody(block)
                        .withLeadingTrivia(indentationTrivia)
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
                // protocol always has the following pattern.
                let binding = variableDecl.bindings.first!
                let accessorBlock = binding.accessor!.as(AccessorBlockSyntax.self)
                
                let identifier = binding.pattern.as(IdentifierPatternSyntax.self)!.identifier
                
                let decls = accessorBlock?.accessors.map({ (accessor) -> (AccessorDeclSyntax, [MemberDeclListItemSyntax])in
                    var memberDeclItems = [MemberDeclListItemSyntax]()
                    var codeBlockItems = [CodeBlockItemSyntax]()
                    let baseIdentifierText = "\(identifier.text)_\(accessor.accessorKind.text)"
                    
                    // wasCalled
                    let (wasCalledDecl, wasCalledBlockExpr) = makeCallVal(
                        identifierBaseText: baseIdentifierText,
                        indentationCount: indentationValue
                    )
                    memberDeclItems.append(wasCalledDecl)
                    codeBlockItems.append(
                        wasCalledBlockExpr
                            .withLeadingTrivia(.spaces(indentationValue * 3))
                    )
                    
                    // count
                    let (countVarDecl, countBlockExpr) = makeCountVal(
                        identifierBaseText: baseIdentifierText,
                        indentationCount: indentationValue
                    )
                    memberDeclItems.append(countVarDecl)
                    codeBlockItems.append(
                        countBlockExpr
                            .withLeadingTrivia(.spaces(indentationValue * 3))
                    )
                    
                    // args
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
                            ),
                            indentationCount: indentationValue
                        )
                        memberDeclItems.append(argsDecl)
                        codeBlockItems.append(
                            argsBlockExpr
                                .withLeadingTrivia(.spaces(indentationValue * 3))
                        )
                    }
                    
                    // return
                    if accessor.accessorKind.text == "get", let type = binding.typeAnnotation?.type {
                        let typeSyntax: TypeSyntax
                        if let optionalType = type.as(OptionalTypeSyntax.self) {
                            typeSyntax = optionalType
                                .wrappedType
                                .withTrailingTrivia(.zero)
                        } else {
                            typeSyntax = type
                                .withTrailingTrivia(.zero)
                        }
                        
                        let (returnDecl, returnBlockExpr) = makeReturnVal(
                            identifierBaseText: baseIdentifierText,
                            typeSyntax: typeSyntax,
                            indentationCount: indentationValue
                        )
                        memberDeclItems.append(returnDecl)
                        codeBlockItems.append(
                            returnBlockExpr
                                .withLeadingTrivia(.spaces(indentationValue * 3))
                        )
                    }
                    
                    let accessor = SyntaxFactory.makeAccessorDecl(
                        attributes: accessor.attributes,
                        modifier: accessor.modifier,
                        accessorKind: accessor.accessorKind
                            .withLeadingTrivia([.spaces(indentationValue * 2)]),
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
                                .withLeadingTrivia([.spaces(indentationValue * 2)])
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
                                        .withLeadingTrivia(.spaces(indentationValue))
                                        .withTrailingTrivia(.newlines(1))
                                )
                        ),
                        trailingComma: nil)
                ])
                
                let propDeclListItems = decls?.map { $0.1 }.flatMap { $0 } ?? []
                
                let variable = SyntaxFactory.makeVariableDecl(
                    attributes: nil,
                    modifiers: nil,
                    letOrVarKeyword: SyntaxFactory
                        .makeVarKeyword()
                        .withLeadingTrivia(.spaces(indentationValue))
                        .withTrailingTrivia(.spaces(1)),
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
            classKeyword: SyntaxFactory
                .makeClassKeyword(
                    leadingTrivia: .zero,
                    trailingTrivia: .spaces(1)
                ),
            identifier: identifier,
            genericParameterClause: nil,
            inheritanceClause: SyntaxFactory.makeTypeInheritanceClause(
                colon: SyntaxFactory
                    .makeColonToken()
                    .withTrailingTrivia(.spaces(1)),
                inheritedTypeCollection: SyntaxFactory
                    .makeInheritedTypeList(
                        [SyntaxFactory
                            .makeInheritedType(
                                typeName: SyntaxFactory.makeTypeIdentifier(protocolName), trailingComma: nil)]
                    )
            )
            .withTrailingTrivia(.spaces(1)),
            genericWhereClause: nil,
            members: SyntaxFactory.makeMemberDeclBlock(
                leftBrace: SyntaxFactory
                    .makeLeftBraceToken()
                    .withLeadingTrivia(.zero)
                    .withTrailingTrivia(.newlines(1)),
                members: SyntaxFactory
                    .makeMemberDeclList(decls.flatMap { $0 })
                    .withLeadingTrivia(.spaces(indentationValue))
                    .withTrailingTrivia(.newlines(1)),
                rightBrace: SyntaxFactory
                    .makeRightBraceToken()
                    .withLeadingTrivia(.zero)
                    .withTrailingTrivia(.newlines(1))
            )
        )
        print(mockClassDecl.description)
        return .skipChildren
    }
    
    private func makeReturnValIfNeeded(funcDecl: FunctionDeclSyntax, indentationCount: Int) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    )? {
        let _output = funcDecl.signature.output
        guard let output = _output else {
            return nil
        }
        
        return makeReturnVal(
            identifierBaseText: funcDecl.identifier.text,
            typeSyntax: output.returnType,
            indentationCount: indentationCount
        )
    }
    
    private func makeReturnVal(
        identifierBaseText: String,
        typeSyntax: TypeSyntax,
        indentationCount: Int) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    ) {
        
        let identifier = "\(identifierBaseText)_val"
        let varDecl = SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: SyntaxFactory
                .makeVarKeyword(
                    leadingTrivia: .spaces(indentationCount),
                    trailingTrivia: .spaces(1)
                ),
            bindings: SyntaxFactory
                .makePatternBindingList([
                    SyntaxFactory.makePatternBinding(
                        pattern: PatternSyntax(SyntaxFactory
                            .makeIdentifierPattern(
                                identifier: SyntaxFactory.makeIdentifier(
                                    identifier
                                )
                            )
                        ),
                        typeAnnotation: SyntaxFactory
                            .makeTypeAnnotation(
                                colon: SyntaxFactory.makeColonToken(),
                                type: TypeSyntax(
                                    SyntaxFactory
                                        .makeImplicitlyUnwrappedOptionalType(
                                            wrappedType: typeSyntax,
                                            exclamationMark: SyntaxFactory.makeExclamationMarkToken()
                                        )
                                ).withLeadingTrivia(.spaces(1))
                            ),
                        initializer: nil,
                        accessor: nil,
                        trailingComma: nil
                    )
                ])
        )
        
        let varDeclItem = SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(varDecl)
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
        

        let codeBlockItem = SyntaxFactory.makeCodeBlockItem(
            item: Syntax(SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory
                    .makeExprList([
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory
                                            .makeReturnKeyword(),
                                        declNameArguments: nil
                                    )
                                    .withLeadingTrivia(.spaces(indentationCount * 2))
                        ),
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory
                                            .makeIdentifier(identifier),
                                        declNameArguments: nil
                                    )
                                    .withLeadingTrivia(.spaces(1))
                                    .withTrailingTrivia(.newlines(1))
                        )
                    ])
            )),
            semicolon: nil,
            errorTokens: nil)
        
        return (varDeclItem, codeBlockItem)
    }
    
    private func makeArgsValIfNeeded(funcDecl: FunctionDeclSyntax, indentationCount: Int) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    )? {
        let paramters = funcDecl.signature.input.parameterList
        guard !paramters.isEmpty else {
            return nil
        }
        
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
            identifierBaseText: funcDecl.identifier.text,
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
                                    ),
            indentationCount: indentationCount
        )
    }
    
    private func makeArgsVal(
        identifierBaseText: String,
        typeSyntax: TypeSyntax,
        substitutionExprSyntax: ExprSyntax,
        indentationCount: Int) -> (
            MemberDeclListItemSyntax,
            CodeBlockItemSyntax
        ) {
        
        let identifier = "\(identifierBaseText)_args"
        
        let varDecl = SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: SyntaxFactory
                .makeVarKeyword(
                    leadingTrivia: .spaces(indentationCount),
                    trailingTrivia: .spaces(1)
                ),
            bindings: SyntaxFactory
                .makePatternBindingList([
                    SyntaxFactory.makePatternBinding(
                        pattern: PatternSyntax(SyntaxFactory
                            .makeIdentifierPattern(
                                identifier: SyntaxFactory.makeIdentifier(
                                    identifier
                                )
                            )
                        ),
                        typeAnnotation: SyntaxFactory
                            .makeTypeAnnotation(
                                colon: SyntaxFactory.makeColonToken(),
                                type: TypeSyntax(SyntaxFactory
                                    .makeOptionalType(
                                        wrappedType: typeSyntax,
                                        questionMark: SyntaxFactory.makePostfixQuestionMarkToken()
                                    )
                                )
                            ),
                        initializer: nil,
                        accessor: nil,
                        trailingComma: nil
                    )
                ])
        )
        
        let varDeclItem = SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(varDecl)
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
        

        let codeBlockItem = SyntaxFactory.makeCodeBlockItem(
            item: Syntax(SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory
                    .makeExprList([
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory
                                            .makeIdentifier(identifier),
                                        declNameArguments: nil
                                    )
                                    .withLeadingTrivia(.spaces(indentationCount * 2))
                                    .withTrailingTrivia(.spaces(1))
                        ),
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory.makeIdentifier("="),
                                        declNameArguments: nil
                                    )
                                    .withTrailingTrivia(.spaces(1))
                        ),
                        substitutionExprSyntax
                    ])
            )),
            semicolon: nil,
            errorTokens: nil)
        
        return (varDeclItem, codeBlockItem)
    }
    
    private func makeCountVal(identifierBaseText: String, indentationCount: Int) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    ) {
        let identifier = "\(identifierBaseText)_callCount"
        
        let varDecl = SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: SyntaxFactory.makeVarKeyword(
                leadingTrivia: .spaces(indentationCount),
                trailingTrivia: .spaces(1)),
            bindings: SyntaxFactory
                .makePatternBindingList([
                    SyntaxFactory.makePatternBinding(
                        pattern: PatternSyntax(SyntaxFactory
                            .makeIdentifierPattern(
                                identifier: SyntaxFactory.makeIdentifier(
                                    identifier
                                )
                            )
                        ),
                        typeAnnotation: nil,
                        initializer: SyntaxFactory.makeInitializerClause(
                            equal: SyntaxFactory.makeEqualToken(
                                leadingTrivia: .spaces(1),
                                trailingTrivia: .spaces(1)
                            ),
                            value: ExprSyntax(SyntaxFactory
                                .makeBooleanLiteralExpr(
                                    booleanLiteral: SyntaxFactory
                                        .makeIntegerLiteral("0")
                                ))
                        ),
                        accessor: nil,
                        trailingComma: nil
                    )
                ]))
        
        let varDeclItem = SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(varDecl)
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
        

        let codeBlockItem = SyntaxFactory.makeCodeBlockItem(
            item: Syntax(SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory
                    .makeExprList([
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory
                                            .makeIdentifier(identifier),
                                        declNameArguments: nil
                                    )
                                    .withLeadingTrivia(.spaces(indentationCount * 2))
                                    .withTrailingTrivia(.spaces(1))
                        ),
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory.makeIdentifier("+="),
                                        declNameArguments: nil
                                    )
                                    .withTrailingTrivia(.spaces(1))
                        ),
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory.makeIntegerLiteral("1"),
                                        declNameArguments: nil
                                    )
                                    .withTrailingTrivia(.newlines(1))
                        )
                    ])
            )),
            semicolon: nil,
            errorTokens: nil)
        
        return (varDeclItem, codeBlockItem)
    }
    
    private func makeCallVal(identifierBaseText: String, indentationCount: Int) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    ) {
        let callIdentifier = "\(identifierBaseText)_wasCalled"
        
        let callVarDecl = SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: SyntaxFactory.makeVarKeyword(
                leadingTrivia: .spaces(indentationCount),
                trailingTrivia: .spaces(1)),
            bindings: SyntaxFactory
                .makePatternBindingList([
                    SyntaxFactory.makePatternBinding(
                        pattern: PatternSyntax(SyntaxFactory
                            .makeIdentifierPattern(
                                identifier: SyntaxFactory.makeIdentifier(
                                    callIdentifier
                                )
                            )
                        ),
                        typeAnnotation: nil,
                        initializer: SyntaxFactory.makeInitializerClause(
                            equal: SyntaxFactory.makeEqualToken(
                                leadingTrivia: .spaces(1),
                                trailingTrivia: .spaces(1)
                            ),
                            value: ExprSyntax(SyntaxFactory
                                .makeBooleanLiteralExpr(
                                    booleanLiteral: SyntaxFactory
                                        .makeFalseKeyword()
                                ))
                        ),
                        accessor: nil,
                        trailingComma: nil
                    )
                ]))
        
        let callVarDeclItem = SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(callVarDecl)
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
        

        let callCodeBlockItem = SyntaxFactory.makeCodeBlockItem(
            item: Syntax(SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory
                    .makeExprList([
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory
                                            .makeIdentifier(callIdentifier),
                                        declNameArguments: nil
                                    )
                                    .withLeadingTrivia(.spaces(indentationCount * 2))
                                    .withTrailingTrivia(.spaces(1))
                        ),
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory.makeEqualToken(),
                                        declNameArguments: nil
                                    )
                                    .withTrailingTrivia(.spaces(1))
                        ),
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: SyntaxFactory.makeTrueKeyword(),
                                        declNameArguments: nil
                                    )
                                    .withTrailingTrivia(.newlines(1))
                        )
                    ]))),
            semicolon: nil,
            errorTokens: nil)
        
        return (callVarDeclItem, callCodeBlockItem)
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
}
