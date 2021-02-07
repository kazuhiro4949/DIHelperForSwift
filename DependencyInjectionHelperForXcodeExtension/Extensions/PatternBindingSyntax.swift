//
//  PatternBindingSyntax.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

extension PatternBindingSyntax {
    struct ContextualKeyword : OptionSet {
        let rawValue: UInt
        
        static let get = ContextualKeyword(rawValue: 1 << 0)
        static let set   = ContextualKeyword(rawValue: 1 << 1)
    }
    
    func convertForProtocol(with contextualKeyword: ContextualKeyword) -> VariableDeclSyntax {
        let accessorDeclSyntaxes: [AccessorDeclSyntax]
        if contextualKeyword == [.get, .set] {
            accessorDeclSyntaxes = [
                SyntaxFactory.makeAccessorDecl(with: "get")
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1)),
                SyntaxFactory.makeAccessorDecl(with: "set")
                    .withTrailingTrivia(.spaces(1))
            ]
        } else if contextualKeyword == .get {
            accessorDeclSyntaxes = [
                SyntaxFactory.makeAccessorDecl(with: "get")
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1))
            ]
        } else if contextualKeyword == .set {
            accessorDeclSyntaxes = [
                SyntaxFactory.makeAccessorDecl(with: "set")
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1))
            ]
        } else {
            accessorDeclSyntaxes = []
        }
        
        let accessorBlock = SyntaxFactory.makeAccessorBlock(
            leftBrace: SyntaxFactory.makeLeftBraceToken(),
            accessors: SyntaxFactory.makeAccessorList(accessorDeclSyntaxes),
            rightBrace: SyntaxFactory.makeRightBraceToken()
        )
        
        let patternBinding = SyntaxFactory.makePatternBinding(
            pattern: pattern,
            typeAnnotation: typeAnnotation?
                .withTrailingTrivia(.spaces(1)),
            initializer: nil,
            accessor: Syntax(accessorBlock),
            trailingComma: nil)
        
        let variableDecl = SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: SyntaxFactory.makeToken(
                .varKeyword,
                presence: .present
            ),
            bindings: SyntaxFactory.makePatternBindingList([
                patternBinding
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1))
            ])
        )
        return variableDecl
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
