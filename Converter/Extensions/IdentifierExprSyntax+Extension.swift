//
//  IdentifierExprSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax


extension IdentifierExprSyntax {
    public static func makeFormattedVariableExpr(_ tokenSyntax: TokenSyntax) -> IdentifierExprSyntax {
        SyntaxFactory
            .makeVariableExpr(tokenSyntax.text)
            .withTrailingTrivia(.newlines(1))
    }
    
    public static func makeFormattedNewValueExpr() -> IdentifierExprSyntax {
        SyntaxFactory
            .makeVariableExpr("newValue")
            .withTrailingTrivia(.newlines(1))
    }
}

