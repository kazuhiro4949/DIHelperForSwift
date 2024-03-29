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
    public struct ContextualKeyword : OptionSet {
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public let rawValue: UInt
        
        public static let get = ContextualKeyword(rawValue: 1 << 0)
        public static let set   = ContextualKeyword(rawValue: 1 << 1)
    }
    
    public func convertForProtocol(
        with contextualKeyword: ContextualKeyword,
        asyncKeyword: TokenSyntax?,
        throwsKeyword: TokenSyntax?,
        modifiers: ModifierListSyntax?,
        attributes: AttributeListSyntax?) -> VariableDeclSyntax {
        let accessorDeclSyntaxes: [AccessorDeclSyntax]
        if contextualKeyword == [.get, .set] {
            accessorDeclSyntaxes = [
                SyntaxFactory.makeAccessorDecl(with: "get",
                                               asyncKeyword: asyncKeyword,
                                               throwsKeyword: throwsKeyword)
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1)),
                SyntaxFactory.makeAccessorDecl(with: "set")
                    .withTrailingTrivia(.spaces(1))
            ]
        } else if contextualKeyword == .get {
            accessorDeclSyntaxes = [
                SyntaxFactory.makeAccessorDecl(with: "get",
                                               asyncKeyword: asyncKeyword,
                                               throwsKeyword: throwsKeyword)
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
            attributes: attributes?
                .withTrailingTrivia(.newlineAndIndent),
            modifiers: modifiers,
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
    public func makeAccessorForMock(accessors: [AccessorDeclSyntax]?, initializer: InitializerClauseSyntax?) -> PatternBindingSyntax {
        SyntaxFactory.makePatternBinding(
            pattern: pattern,
            typeAnnotation: typeAnnotation,
            initializer: initializer,
            accessor: AccessorBlockSyntax.makeAccessorBlock(accessors: accessors).flatMap { Syntax($0) },
            trailingComma: nil)
    }
    
    public static func makeAssign(to identifier: String,
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

    public static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> PatternBindingSyntax {
        let typeAnnotation: TypeSyntax?
        if let returnValue = TypeSyntax.ReturnValue(typeSyntax: typeSyntax),
           returnValue.needsExplicit {
            typeAnnotation = typeSyntax
        } else {
            typeAnnotation = nil
        }

        let valueExpr = ExprSyntax.makeReturnedValForMock(identifier, typeSyntax)
        
        return SyntaxFactory.makePatternBinding(
            pattern: .makeIdentifierPatternSyntax(with: identifier),
            typeAnnotation: typeAnnotation.flatMap { .makeFormatted($0) },
            initializer: InitializerClauseSyntax
                .makeFormatted(valueExpr)?
                .withLeadingTrivia(.spaces(1)),
            accessor: nil,
            trailingComma: nil
        )
    }
}
