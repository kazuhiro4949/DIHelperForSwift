//
//  DictionaryExprSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension DictionaryExprSyntax {
    public static func makeBlank() -> DictionaryExprSyntax {
        SyntaxFactory
            .makeDictionaryExpr(
                leftSquare: SyntaxFactory
                    .makeLeftSquareBracketToken(),
                content: Syntax(DictionaryElementListSyntax.makeBlank()),
                rightSquare: SyntaxFactory
                    .makeRightSquareBracketToken())
    }
}


