//
//  TupleTypeSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension TupleTypeSyntax {
    static func make(with elements: [TupleTypeElementSyntax]) -> TupleTypeSyntax {
        SyntaxFactory
            .makeTupleType(
                leftParen: SyntaxFactory.makeLeftParenToken(),
                elements:
                    SyntaxFactory
                        .makeTupleTypeElementList(elements),
                rightParen: SyntaxFactory
                    .makeRightParenToken()
            ).withLeadingTrivia(.spaces(1))
    }
}

extension TupleTypeSyntax {
    static func makeParen(with anonimousFunctionType: FunctionTypeSyntax) -> TupleTypeSyntax {
        SyntaxFactory.makeTupleType(
            leftParen: SyntaxFactory.makeLeftParenToken(),
            elements: SyntaxFactory
                .makeTupleTypeElementList(
                    [
                        SyntaxFactory.makeTupleTypeElement(
                            type: TypeSyntax(anonimousFunctionType),
                            trailingComma: nil)
                    ]
                ),
            rightParen: SyntaxFactory.makeRightParenToken())
    }
}
