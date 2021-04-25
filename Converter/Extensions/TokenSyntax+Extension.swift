//
//  TokenSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension TokenSyntax {
    public static func makeUnwrapped(_ typeSyntax: TypeSyntax) -> TypeSyntax {
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
    
    public static func makeFormattedEqual() -> TokenSyntax {
        SyntaxFactory
            .makeEqualToken()
            .withTrailingTrivia(.spaces(1))
    }
}


extension TokenSyntax {
    public static func makeFormattedVarKeyword() -> TokenSyntax {
        SyntaxFactory
            .makeVarKeyword()
            .withTrailingTrivia(.spaces(1))
    }
    
    public static func makeFormattedClassKeyword() -> TokenSyntax {
        SyntaxFactory
            .makeClassKeyword(
                leadingTrivia: .zero,
                trailingTrivia: .spaces(1)
            )
    }
    
    public static func makeCleanFormattedLeftBrance(_ indentTrivia: Trivia = .zero) -> TokenSyntax {
        SyntaxFactory
            .makeLeftBraceToken()
            .withLeadingTrivia(indentTrivia)
            .withTrailingTrivia(.newlines(1))
    }
    
    public static func makeCleanFormattedRightBrance(_ indentTrivia: Trivia = .zero) -> TokenSyntax {
        SyntaxFactory
            .makeRightBraceToken()
            .withLeadingTrivia(indentTrivia)
            .withTrailingTrivia(.newlines(1))
    }
}

extension TokenSyntax {
    public func signatureAddedIdentifier(counter: Counter? = nil) -> String {
        var identifierBaseText = text
        
        if let counter = counter {
            let digit = Int(log10(Double(counter.max)))
            let zeroPaddingCount = String(format: "%0\(digit)d", counter.count)
            identifierBaseText = "\(identifierBaseText)_<#T##identifier\(zeroPaddingCount)##identifier\(zeroPaddingCount)#>"
        }
        
        return identifierBaseText
    }
}
