//
//  TypeSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension TypeSyntax {
    var unwrapped: TypeSyntax {
        if let optionalType = self.as(OptionalTypeSyntax.self) {
            return optionalType
                .wrappedType
        } else {
            return self
        }
    }
    
    var removingAttributes: TypeSyntax {
        if let attributedTypSyntax = self.as(AttributedTypeSyntax.self) {
            return attributedTypSyntax.baseType
        } else {
            return self
        }
    }
    
    var tparenthesizedIfNeeded: TypeSyntax {
        if self.is(FunctionTypeSyntax.self) {
            return TypeSyntax(SyntaxFactory.makeTupleType(
                leftParen: SyntaxFactory.makeLeftParenToken(),
                elements: SyntaxFactory.makeTupleTypeElementList(
                    [
                        SyntaxFactory.makeTupleTypeElement(
                            type: self,
                            trailingComma: nil
                        )
                    ]
                ),
                rightParen: SyntaxFactory.makeRightParenToken()
            ))
        } else {
            return self
        }
    }
}
