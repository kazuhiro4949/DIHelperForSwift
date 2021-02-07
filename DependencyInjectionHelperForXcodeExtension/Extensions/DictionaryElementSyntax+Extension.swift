//
//  DictionaryElementSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension DictionaryElementSyntax {
    static func makeBlank() -> DictionaryElementSyntax {
        SyntaxFactory
            .makeDictionaryElement(
                keyExpression: ExprSyntax(
                    SyntaxFactory
                        .makeBlankUnknownExpr()
                ),
                colon: SyntaxFactory
                    .makeColonToken(),
                valueExpression: ExprSyntax(
                    SyntaxFactory
                        .makeBlankUnknownExpr()
                ),
                trailingComma: nil)
    }
}
