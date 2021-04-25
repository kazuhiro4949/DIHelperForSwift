//
//  ExprSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//
//

import Foundation
import SwiftSyntax

extension ExprSyntax {
    public static func makeFalseKeyword() -> ExprSyntax {
        ExprSyntax(SyntaxFactory
                .makeBooleanLiteralExpr(
                    booleanLiteral: SyntaxFactory
                        .makeFalseKeyword()
                )
        )
    }
    
    public static func makeZeroKeyword() -> ExprSyntax {
        ExprSyntax(SyntaxFactory
                .makeBooleanLiteralExpr(
                    booleanLiteral: SyntaxFactory.makeIntegerLiteral("0")
                )
        )
    }
}

extension ExprSyntax {
    public static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> ExprSyntax {
        switch TypeSyntax.ReturnValue(typeSyntax: typeSyntax) {
        case .simple(let literal):
            return literal
        case .array:
            return ExprSyntax(ArrayExprSyntax.makeBlank())
        case .dictionary:
            return ExprSyntax(DictionaryExprSyntax.makeBlank())
        case .function:
            return ExprSyntax(SyntaxFactory.makeVariableExpr("<#T##\(typeSyntax.description)#>"))
        case .optional:
            return ExprSyntax(
                SyntaxFactory.makeNilLiteralExpr(
                    nilKeyword: SyntaxFactory.makeNilKeyword()
                )
            )
        case .reserved(let snippet):
            return ExprSyntax(SyntaxFactory.makeVariableExpr(snippet.body))
        case .none:
            return ExprSyntax(SyntaxFactory.makeVariableExpr("<#T##\(typeSyntax.description)#>"))
        }
    }
}
