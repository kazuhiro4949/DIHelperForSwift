//
//  TupleExprSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension TupleExprSyntax {
    public static func make(with elements: [TupleExprElementSyntax]) -> TupleExprSyntax {
        SyntaxFactory.makeTupleExpr(
            leftParen: SyntaxFactory.makeLeftParenToken(),
            elementList: SyntaxFactory
                .makeTupleExprElementList(elements),
            rightParen: SyntaxFactory.makeRightParenToken()
        )
        .withTrailingTrivia(.newlines(1))
    }
}
