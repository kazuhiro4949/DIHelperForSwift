//
//  ArrayExprSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension ArrayExprSyntax {
    public static func makeBlank() -> ArrayExprSyntax {
        SyntaxFactory
            .makeArrayExpr(
                leftSquare: SyntaxFactory
                    .makeLeftSquareBracketToken(),
                elements: SyntaxFactory
                    .makeBlankArrayElementList(),
                rightSquare: SyntaxFactory
                    .makeRightSquareBracketToken()
            )
    }
}
