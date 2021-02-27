//
//  SimpleTypeIdentifierSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension SimpleTypeIdentifierSyntax {
    func tryToConvertToLiteralExpr() -> ExprSyntax? {
        switch name.text {
        case "Bool":
            return ExprSyntax(SyntaxFactory
                    .makeBooleanLiteralExpr(
                        booleanLiteral: SyntaxFactory
                            .makeFalseKeyword()
                    )
            )
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
