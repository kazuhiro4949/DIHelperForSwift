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
    public enum SimpleDefaultValue {
        case bool
        case string
        case integer
        case float
    }
    
    public enum Literal: String {
        
        case bool
        
        case string
        case nSString
        
        case int
        case int8
        case int16
        case int32
        case int64
        case nSInteger
        
        case uInt
        case uInt8
        case uInt16
        case uInt32
        case uInt64
        
        case double
        case float
        case float32
        case float64
        case cGFloat

        public init?(capitalizedString: String) {
            let rawValue = capitalizedString.prefix(1).lowercased() + capitalizedString.dropFirst()
            self.init(rawValue: rawValue)
        }
        
        public var defaultValue: SimpleDefaultValue {
            switch self {
            case .bool:
                return .bool
            case .string, .nSString:
                return .string
            case .int, .int8, .int16, .int32, .int64, .nSInteger:
                return .integer
            case .uInt, .uInt8, .uInt16, .uInt32, .uInt64:
                return .integer
            case .double, .float, .float32, .float64, .cGFloat:
                return .float
            }
        }
    }
}

extension SimpleTypeIdentifierSyntax {
    public func tryToConvertToLiteralExpr() -> ExprSyntax? {
        guard let literal = Literal(capitalizedString: name.text) else {
            return nil
        }
        
        switch literal.defaultValue {
        case .bool:
            return ExprSyntax(SyntaxFactory
                    .makeBooleanLiteralExpr(
                        booleanLiteral: SyntaxFactory
                            .makeFalseKeyword()
                    )
            )
        case .string:
            return ExprSyntax(SyntaxFactory
                .makeStringLiteralExpr(""))
        case .integer:
            return ExprSyntax(SyntaxFactory
                .makeIntegerLiteralExpr(
                    digits: SyntaxFactory
                        .makeIntegerLiteral("0")
                )
            )
        case .float:
            return ExprSyntax(SyntaxFactory
                .makeFloatLiteralExpr(
                    floatingDigits: SyntaxFactory
                        .makeFloatingLiteral("0.0")
                )
            )
        }
    }
}
