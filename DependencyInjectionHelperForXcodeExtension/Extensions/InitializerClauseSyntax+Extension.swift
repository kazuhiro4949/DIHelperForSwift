//
//  InitializerClauseSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension InitializerClauseSyntax {
    static func makeFormatted(_ valueExpr: ExprSyntax?) -> InitializerClauseSyntax? {
        valueExpr.flatMap {
            SyntaxFactory.makeInitializerClause(
                equal: .makeFormattedEqual(),
                value: $0)
        }
    }
}
