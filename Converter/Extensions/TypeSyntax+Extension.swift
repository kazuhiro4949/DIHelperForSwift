//
//  TypeSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension TypeSyntax {
    var unwrapped: TypeSyntax {
        if let optionalType = self.as(OptionalTypeSyntax.self) {
            return optionalType
                .wrappedType
        } else if let iuoType = self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return iuoType
                .wrappedType
        } else {
            return self
        }
    }
    
    var removingAttributes: TypeSyntax {
        if let attributedTypSyntax = self.as(AttributedTypeSyntax.self) {
            return attributedTypSyntax.baseType
        } else {
            return self
        }
    }
    
    var tparenthesizedIfNeeded: TypeSyntax {
        if self.is(FunctionTypeSyntax.self) {
            return TypeSyntax(SyntaxFactory.makeTupleType(
                leftParen: SyntaxFactory.makeLeftParenToken(),
                elements: SyntaxFactory.makeTupleTypeElementList(
                    [
                        SyntaxFactory.makeTupleTypeElement(
                            type: self,
                            trailingComma: nil
                        )
                    ]
                ),
                rightParen: SyntaxFactory.makeRightParenToken()
            ))
        } else {
            return self
        }
    }
}

extension TypeSyntax {
    /// needs to assign an explicit type to the returned property
    enum ReturnValue {
        case simple(ExprSyntax)
        case array
        case dictionary
        case optional
        case function
        case reserved(InitSnippet)
        
        init?(typeSyntax: TypeSyntax) {
            let unwrappedTypeSyntax = TokenSyntax.makeUnwrapped(typeSyntax)
            
            if let type = unwrappedTypeSyntax.as(SimpleTypeIdentifierSyntax.self),
               let literal = type.tryToConvertToLiteralExpr() {
                self = .simple(literal)
            } else if unwrappedTypeSyntax.is(ArrayTypeSyntax.self) {
                self = .array
            } else if unwrappedTypeSyntax.is(DictionaryTypeSyntax.self) {
                self = .dictionary
            } else if typeSyntax.is(OptionalTypeSyntax.self) {
                self = .optional
            } else if let snippet = UserDefaults.group.snippets.first(where: { $0.name == unwrappedTypeSyntax.description }) {
                self = .reserved(snippet)
            } else {
                return nil
            }
        }
        
        var needsExplicit: Bool {
            switch self {
            case .simple, .array, .dictionary, .optional:
                return true
            case .function, .reserved:
                return false
            }
        }
    }
}
