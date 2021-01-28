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
        
        let decls = node.members.members.compactMap { (item) -> [MemberDeclListItemSyntax]? in
            if let funcDeclSyntax = item.decl.as(FunctionDeclSyntax.self) {
                let indentationValue = 4
                let indentationTrivia = Trivia(pieces: [.spaces(indentationValue)])
                
                // call properties
                let callIdentifier = "\(funcDeclSyntax.identifier.text)_wasCalled"
                
                let callVarDecl = SyntaxFactory.makeVariableDecl(
                    attributes: nil,
                    modifiers: nil,
                    letOrVarKeyword: SyntaxFactory.makeVarKeyword(
                        leadingTrivia: indentationTrivia,
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
                                            .withLeadingTrivia(Trivia(pieces: [.spaces(indentationValue * 2)]))
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
                
                // block
                let block = SyntaxFactory.makeCodeBlock(
                    leftBrace: SyntaxFactory.makeLeftBraceToken(
                        leadingTrivia: .spaces(1),
                        trailingTrivia: [.spaces(1), .newlines(1)]
                    ),
                    statements: SyntaxFactory
                        .makeCodeBlockItemList(
                            [
                                callCodeBlockItem
                            ]
                        ),
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
                
                return [callVarDeclItem, funcSyntaxItem]
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
                    .withTrailingTrivia(.newlines(1)),
                members: SyntaxFactory
                    .makeMemberDeclList(decls.flatMap { $0 })
                    .withTrailingTrivia(.newlines(1)),
                rightBrace: SyntaxFactory
                    .makeRightBraceToken()
                    .withTrailingTrivia(.newlines(1))
            )
        )
        print(mockClassDecl.description)
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
}
