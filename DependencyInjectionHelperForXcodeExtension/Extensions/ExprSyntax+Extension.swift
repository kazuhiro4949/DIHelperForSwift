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
