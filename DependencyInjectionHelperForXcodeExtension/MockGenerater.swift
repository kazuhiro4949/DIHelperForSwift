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
                    funcDecl: funcDeclSyntax,
                    indentationCount: indentationValue
                )
                codeBlockItems.append(callCodeBlockItem)
                memberDeclListItems.append(callVarDeclItem)
                // call properties
                let (countVarDeclItem, countCodeBlockItem) = makeCountVal(
                    funcDecl: funcDeclSyntax,
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
                
                let decls = accessorBlock?.accessors.map({ (accessor) -> (AccessorDeclSyntax, VariableDeclSyntax)in
                    
                    let wasCallIdentifier = "\(identifier.text)_\(accessor.accessorKind.text)_wasCalled"
                    let wasCalledDecl = SyntaxFactory.makeVariableDecl(
                        attributes: nil,
                        modifiers: nil,
                        letOrVarKeyword: SyntaxFactory
                            .makeVarKeyword()
                            .withTrailingTrivia(.spaces(1)),
                        bindings: SyntaxFactory
                            .makePatternBindingList(
                                [
                                    SyntaxFactory.makePatternBinding(
                                        pattern: PatternSyntax(SyntaxFactory
                                            .makeIdentifierPattern(
                                                identifier: SyntaxFactory
                                                    .makeIdentifier(wasCallIdentifier)
                                            ))
                                            .withTrailingTrivia(.spaces(1)),
                                        typeAnnotation: nil,
                                        initializer: SyntaxFactory
                                            .makeInitializerClause(
                                                equal: SyntaxFactory
                                                    .makeEqualToken()
                                                    .withTrailingTrivia(.spaces(1)),
                                                value: ExprSyntax(
                                                    SyntaxFactory
                                                        .makeBooleanLiteralExpr(
                                                            booleanLiteral: SyntaxFactory
                                                                .makeFalseKeyword()
                                                        )
                                                )
                                            ),
                                        accessor: nil,
                                        trailingComma: nil)
                                ]
                            )
                    )
                    .withLeadingTrivia(.spaces(indentationValue))
                    .withTrailingTrivia(.newlines(1))
                    
                    let wasCalledExpr = Syntax(SyntaxFactory
                                                .makeSequenceExpr(
                                                    elements: SyntaxFactory.makeExprList([
                                                        ExprSyntax(SyntaxFactory.makeIdentifierExpr(
                                                            identifier: SyntaxFactory
                                                                .makeIdentifier(wasCallIdentifier),
                                                            declNameArguments: nil))
                                                            .withTrailingTrivia(.spaces(1))
                                                        ,
                                                        ExprSyntax(
                                                            SyntaxFactory
                                                                .makeAssignmentExpr(
                                                                    assignToken: SyntaxFactory.makeEqualToken()
                                                                )
                                                        )
                                                        .withTrailingTrivia(.spaces(1)),
                                                        ExprSyntax(
                                                            SyntaxFactory
                                                                .makeBooleanLiteralExpr(
                                                                    booleanLiteral: SyntaxFactory.makeTrueKeyword())
                                                        ),
                                                    ]
                                                    )
                                                )
                    )
                    .withLeadingTrivia(.spaces(indentationValue * 3))
                    .withTrailingTrivia(.newlines(1))
                    
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
                                .makeCodeBlockItemList([
                                    SyntaxFactory
                                        .makeCodeBlockItem(
                                            item: wasCalledExpr,
                                            semicolon: nil,
                                            errorTokens: nil
                                        )
                                        
                                ]),
                            rightBrace: SyntaxFactory
                                .makeRightBraceToken()
                                .withLeadingTrivia([.spaces(indentationValue * 2)])
                                .withTrailingTrivia([.newlines(1)])
                        ))
                    
                    return (accessor, wasCalledDecl)
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
                return [declListItem]
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
        
        let identifier = "\(funcDecl.identifier.text)_val"
        
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
                                            wrappedType: output.returnType,
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
        
        let identifier = "\(funcDecl.identifier.text)_args"
        
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
                                        wrappedType: TypeSyntax(
                                            SyntaxFactory
                                                .makeTupleType(
                                                    leftParen: SyntaxFactory.makeLeftParenToken(),
                                                    elements:
                                                        SyntaxFactory
                                                            .makeTupleTypeElementList(tupleElements),
                                                    rightParen: SyntaxFactory.makeRightParenToken())
                                        ),
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
                        ExprSyntax(SyntaxFactory.makeTupleExpr(
                                    leftParen: SyntaxFactory.makeLeftParenToken(),
                                    elementList: SyntaxFactory
                                        .makeTupleExprElementList(
                                            bindingTupleElements
                                        ),
                                    rightParen: SyntaxFactory.makeRightParenToken())
                                    .withTrailingTrivia(.newlines(1))
                        )
                    ])
            )),
            semicolon: nil,
            errorTokens: nil)
        
        return (varDeclItem, codeBlockItem)
    }
    
    private func makeCountVal(funcDecl: FunctionDeclSyntax, indentationCount: Int) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    ) {
        let identifier = "\(funcDecl.identifier.text)_callCount"
        
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
    
    private func makeCallVal(funcDecl: FunctionDeclSyntax, indentationCount: Int) -> (
        MemberDeclListItemSyntax,
        CodeBlockItemSyntax
    ) {
        let callIdentifier = "\(funcDecl.identifier.text)_wasCalled"
        
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
