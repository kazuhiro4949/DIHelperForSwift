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

struct SpyPropertyForAccessor {
    var members: [MemberDeclListItemSyntax] = []
    var accessor: AccessorDeclSyntax
    
    mutating func appendCodeBlockItem(_ codeBlock: CodeBlockItemSyntax) {
        var statements = accessor.body?.statements.map { $0 } ?? []
        statements.append(codeBlock)
        accessor = accessor.makeAccessorDeclForMock(statements)
            .withLeadingTrivia(.indent(2))
    }
}


class MockGenerater: SyntaxVisitor {
    internal init(mockType: MockType) {
        self.mockType = mockType
    }
    
    let mockType: MockType
    var mockClasses = [ClassDeclSyntax]()
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        mockClasses.append(
            .makeForMock(
                identifier: SyntaxFactory
                    .makeIdentifier(
                        .init(
                            format: mockType.format,
                            ProtocolNameHandler(node).getBaseName()
                        )
                    ),
                protocolNameHandler: ProtocolNameHandler(node),
                members: node.makeMemberDeclListItems()
            )
        )
        
        return .skipChildren
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

extension TypeSyntax {
    var unwrapped: TypeSyntax {
        if let optionalType = self.as(OptionalTypeSyntax.self) {
            return optionalType
                .wrappedType
        } else {
            return self
        }
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
    
    static func makeCleanFormattedLeftBrance(_ indentTrivia: Trivia = .zero) -> TokenSyntax {
        SyntaxFactory
            .makeLeftBraceToken()
            .withLeadingTrivia(indentTrivia)
            .withTrailingTrivia(.newlines(1))
    }
    
    static func makeCleanFormattedRightBrance(_ indentTrivia: Trivia = .zero) -> TokenSyntax {
        SyntaxFactory
            .makeRightBraceToken()
            .withLeadingTrivia(indentTrivia)
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
    static func makeFunctionForMock(_ funcDecl:  FunctionDeclSyntax, _ codeBlockItems: [CodeBlockItemSyntax]) -> MemberDeclListItemSyntax {
        let codeBlockAddedFuncDecl = DeclSyntax(
            funcDecl
                .withBody(.makeFormattedCodeBlock(codeBlockItems))
                .withLeadingTrivia(.indent)
                .withTrailingTrivia(.newlines(2))
        )
        return SyntaxFactory
            .makeMemberDeclListItem(
                decl: codeBlockAddedFuncDecl,
                semicolon: nil
            )
    }
    
    static func makeArgsValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> MemberDeclListItemSyntax {
        makeFormattedAssign(
            to: identifier,
            typeAnnotation: .makeFormatted(
                TypeSyntax(SyntaxFactory
                    .makeOptionalType(
                        wrappedType: typeSyntax,
                        questionMark: SyntaxFactory.makePostfixQuestionMarkToken()
                    )
                )
            )
        )
    }
    
    static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> MemberDeclListItemSyntax {
        SyntaxFactory
            .makeMemberDeclListItem(
                decl: DeclSyntax(
                    VariableDeclSyntax
                        .makeReturnedValForMock(identifier, typeSyntax)
                ),
                semicolon: nil
        )
    }
    
    static func makeFormattedZeroAssign(to identifier: String)  -> MemberDeclListItemSyntax {
        .makeFormattedAssign(
            to: identifier,
            from: .makeZeroKeyword()
        )
    }
    
    static func makeFormattedFalseAssign(to identifier: String)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        from: .makeFalseKeyword()
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
    
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
    static func makeNewValueArgsExprForMock(_ identifier: String) -> CodeBlockItemSyntax {
        CodeBlockItemSyntax
            .makeArgsExprForMock(
                identifier,
                ExprSyntax(IdentifierExprSyntax.makeFormattedNewValueExpr())
            )
    }
    
    static func makeArgsExprForMock(_ identifier: String, _ exprSyntax: ExprSyntax) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: SyntaxFactory.makeIdentifier(identifier),
            expr: SyntaxFactory.makeEqualToken(),
            right: exprSyntax
        )
    }
    
    static func makeReturnExpr(_ identifier: String, _ indent: Trivia) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            expr: SyntaxFactory.makeReturnKeyword(),
            right: SyntaxFactory.makeIdentifier(identifier)
        )
        .withLeadingTrivia(indent)
    }
    
    static func makeIncrementExpr(to identifier: String) -> CodeBlockItemSyntax {
        .makeFormattedExpr(
            left: SyntaxFactory
                .makeIdentifier(identifier),
            expr: SyntaxFactory.makeIdentifier("+="),
            right: SyntaxFactory.makeIntegerLiteral("1")
        )
    }
    
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
    
    static func makeTrueSubstitutionExpr(to callIdentifier: String) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: SyntaxFactory.makeIdentifier(callIdentifier),
            expr: SyntaxFactory.makeEqualToken(),
            right: SyntaxFactory.makeTrueKeyword()
        )
    }
}

extension VariableDeclSyntax {
    func generateMemberDeclItemsForSpy() -> [MemberDeclListItemSyntax] {
        // protocol always has the following pattern.
        let binding = bindings.first!
        let accessorBlock = binding.accessor!.as(AccessorBlockSyntax.self)
        
        let identifier = binding.pattern.as(IdentifierPatternSyntax.self)!.identifier
        
        let spyProperties = accessorBlock?.accessors.map { $0.makeSpyProperty(identifier, binding) }
        
        let accessors = spyProperties?.map { $0.accessor } ?? []
        let patternList = SyntaxFactory.makePatternBindingList([
            binding.makeAccessorForMock(accessors: accessors)
        ])
        
        let propDeclListItems = spyProperties?.map { $0.members }.flatMap { $0 } ?? []
        
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
    }
    
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

extension AccessorDeclSyntax {
    var isSet: Bool {
        accessorKind.text == "set"
    }
    
    var isGet: Bool {
        accessorKind.text == "get"
    }
    
    func makeSpyProperty(_ identifier: TokenSyntax, _ binding: PatternBindingSyntax) -> SpyPropertyForAccessor {
        let identifierByAccessor = "\(identifier.text)_\(accessorKind.text)"
        var spyProperty = SpyPropertyForAccessor(accessor: self)
        
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            spyProperty.members.append(.makeFormattedFalseAssign(to: identifierByAccessor.wasCalled))
            spyProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeTrueSubstitutionExpr(to: identifierByAccessor.wasCalled).withLeadingTrivia(.indent(3)))
        }
        if !Settings.shared.spySettings.getCapture(capture: . callCount) {
            spyProperty.members.append(.makeFormattedZeroAssign(to: identifierByAccessor.callCount))
            spyProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeIncrementExpr(to: identifierByAccessor.callCount).withLeadingTrivia(.indent(3)))
        }
        if isSet, !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            spyProperty.members.append(.makeArgsValForMock(identifierByAccessor.args, binding.typeAnnotation!.type.unwrapped.withTrailingTrivia(.zero)))
            spyProperty.appendCodeBlockItem(.makeNewValueArgsExprForMock(identifierByAccessor.args))
        }
        if isGet {
            let typeSyntax = binding.typeAnnotation!.type.withTrailingTrivia(.zero)
            spyProperty.members.append(.makeReturnedValForMock(identifierByAccessor.val, typeSyntax))
            spyProperty.appendCodeBlockItem(.makeReturnExpr(identifierByAccessor.val, .indent(3)))
        }
        return spyProperty
    }
    
    func makeAccessorDeclForMock(_ codeBlockItems: [CodeBlockItemSyntax]) -> AccessorDeclSyntax {
        SyntaxFactory.makeAccessorDecl(
            attributes: attributes,
            modifier: modifier,
            accessorKind: accessorKind
                .withLeadingTrivia(.indent(3))
                .withTrailingTrivia(.zero),
            parameter: parameter,
            body: SyntaxFactory.makeCodeBlock(
                leftBrace: .makeCleanFormattedLeftBrance(.spaces(1)),
                statements: SyntaxFactory
                    .makeCodeBlockItemList(codeBlockItems),
                rightBrace: .makeCleanFormattedRightBrance(.indent(2))
            ))
    }
}

extension PatternBindingSyntax {
    func makeAccessorForMock(accessors: [AccessorDeclSyntax]) -> PatternBindingSyntax {
        SyntaxFactory.makePatternBinding(
            pattern: pattern,
            typeAnnotation: typeAnnotation,
            initializer: nil,
            accessor: Syntax(
                SyntaxFactory
                    .makeAccessorBlock(
                        leftBrace: .makeCleanFormattedLeftBrance(),
                        accessors: SyntaxFactory.makeAccessorList(
                            accessors
                        ),
                        rightBrace: .makeCleanFormattedRightBrance(.indent)
                    )
            ),
            trailingComma: nil)
    }
    
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
    func generateCodeBlockItemsForSpy() -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            codeBlockItems.append(.makeTrueSubstitutionExpr(to: signatureAddedIdentifier.wasCalled))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            codeBlockItems.append(.makeIncrementExpr(to: signatureAddedIdentifier.callCount))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                codeBlockItems.append(makeSingleTypeArgsExprForMock())
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForMock())
            }
        }
        if let _ = signature.output {
            codeBlockItems.append(.makeReturnExpr(signatureAddedIdentifier.val, .indent(2)))
        }
        return codeBlockItems
    }
    
    func generateMemberDeclItemsForSpy() -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            memberDeclListItems.append(.makeFormattedFalseAssign(to: signatureAddedIdentifier.wasCalled))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            memberDeclListItems.append(.makeFormattedZeroAssign(to: signatureAddedIdentifier.callCount))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                memberDeclListItems.append(makeSingleTypeArgsValForMock())
            case .tuple:
                memberDeclListItems.append(makeTupleArgsValForMock())
            }
        }
        if let output = signature.output {
            memberDeclListItems.append(.makeReturnedValForMock(signatureAddedIdentifier.val, output.returnType))
        }
        let codeBlockItems = generateCodeBlockItemsForSpy()
        memberDeclListItems.append(.makeFunctionForMock(self, codeBlockItems))
        return memberDeclListItems
    }
    
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
    
    func makeSingleTypeArgsValForMock() -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier.args,
            signature.input.parameterList.first!.type!.unwrapped.withTrailingTrivia(.zero)
        )
    }
    
    func makeSingleTypeArgsExprForMock() -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier.args,
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            signature.input.parameterList.first!.tokenForMockProperty
                        )
            )
        )
    }
    
    func makeTupleArgsValForMock() -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier.args,
            TypeSyntax(TupleTypeSyntax.make(with: signature.input.parameterList.makeTupleForMemberDecl()))
        )
    }
    
    func makeTupleArgsExprForMock() -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier.args,
            ExprSyntax(TupleExprSyntax.make(with: signature.input.parameterList.makeTupleForCodeBlockItem()))
        )
    }
}

extension ClassDeclSyntax {
    static func makeForMock(identifier: TokenSyntax, protocolNameHandler: ProtocolNameHandler, members: [[MemberDeclListItemSyntax]]) -> ClassDeclSyntax  {
        SyntaxFactory.makeClassDecl(
            attributes: nil,
            modifiers: nil,//ModifierListSyntax?,
            classKeyword: .makeFormattedClassKeyword(),
            identifier: identifier,
            genericParameterClause: nil,
            inheritanceClause: .makeFormattedProtocol(protocolNameHandler),
            genericWhereClause: nil,
            members: .makeFormatted(with: members)
        )
    }
}

extension FunctionParameterSyntax {
    var tokenForMockProperty: TokenSyntax {
        if let secondName = secondName {
            return secondName
        } else if let firstName = firstName {
            return firstName
        } else {
            return SyntaxFactory.makeIdentifier("")
        }
    }
}

extension FunctionParameterListSyntax {
    enum MockParameter {
        case none
        case singleType
        case tuple
    }
    
    var mockParameter: MockParameter {
        if isEmpty {
            return .none
        } else if count == 1 {
            return .singleType
        } else {
            return .tuple
        }
    }
    
    func makeTupleForMemberDecl() -> [TupleTypeElementSyntax] {
        compactMap { paramter -> TupleTypeElementSyntax? in
            return SyntaxFactory.makeTupleTypeElement(
                name: paramter.tokenForMockProperty,
                colon: paramter.colon,
                type: paramter.type!,
                trailingComma: paramter.trailingComma)
        }
    }
    
    func makeTupleForCodeBlockItem() -> [TupleExprElementSyntax] {
        compactMap { paramter -> TupleExprElementSyntax? in
            return SyntaxFactory.makeTupleExprElement(
                label: nil,
                colon: nil,
                expression: ExprSyntax(
                    SyntaxFactory
                        .makeVariableExpr(paramter.tokenForMockProperty.text)
                ),
                trailingComma: paramter.trailingComma)
        }
    }
}

extension TupleTypeSyntax {
    static func make(with elements: [TupleTypeElementSyntax]) -> TupleTypeSyntax {
        SyntaxFactory
            .makeTupleType(
                leftParen: SyntaxFactory.makeLeftParenToken(),
                elements:
                    SyntaxFactory
                        .makeTupleTypeElementList(elements),
                rightParen: SyntaxFactory
                    .makeRightParenToken()
            ).withLeadingTrivia(.spaces(1))
    }
}

extension TupleExprSyntax {
    static func make(with elements: [TupleExprElementSyntax]) -> TupleExprSyntax {
        SyntaxFactory.makeTupleExpr(
            leftParen: SyntaxFactory.makeLeftParenToken(),
            elementList: SyntaxFactory
                .makeTupleExprElementList(elements),
            rightParen: SyntaxFactory.makeRightParenToken()
        )
        .withTrailingTrivia(.newlines(1))
    }
}

extension IdentifierExprSyntax {
    static func makeFormattedVariableExpr(_ tokenSyntax: TokenSyntax) -> IdentifierExprSyntax {
        SyntaxFactory
            .makeVariableExpr(tokenSyntax.text)
            .withTrailingTrivia(.newlines(1))
    }
    
    static func makeFormattedNewValueExpr() -> IdentifierExprSyntax {
        SyntaxFactory
            .makeVariableExpr("newValue")
            .withTrailingTrivia(.newlines(1))
            .withLeadingTrivia(.indent(3))
    }
}

extension CodeBlockSyntax {
    static func makeFormattedCodeBlock(_ codeBlockItems: [CodeBlockItemSyntax]) -> CodeBlockSyntax {
        SyntaxFactory.makeCodeBlock(
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
    }
}

extension ProtocolDeclSyntax {
    func makeMemberDeclListItems() -> [[MemberDeclListItemSyntax]] {
        members.members.compactMap { (item) -> [MemberDeclListItemSyntax]? in
            if let funcDeclSyntax = item.decl.as(FunctionDeclSyntax.self),
               !Settings.shared.spySettings.getTarget(target: .function) {
                return funcDeclSyntax.generateMemberDeclItemsForSpy()
            } else if let variableDecl = item.decl.as(VariableDeclSyntax.self),
                      !Settings.shared.spySettings.getTarget(target: .property) {
                return variableDecl.generateMemberDeclItemsForSpy()
            } else {
                return nil
            }
        }
    }
}

extension String {
    var wasCalled: String {
        self + "_wasCalled"
    }
    
    var callCount: String {
        self + "_callCount"
    }
    
    var args: String {
        self + "_args"
    }
    
    var val: String {
        self + "_val"
    }
}
