//
//  TypeAnnotationSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension TypeAnnotationSyntax {
    public static func makeFormatted(_ typeSyntax: TypeSyntax) -> TypeAnnotationSyntax {
        SyntaxFactory
            .makeTypeAnnotation(
                colon: SyntaxFactory
                    .makeColonToken()
                    .withTrailingTrivia(.spaces(1)),
                type: typeSyntax
            )
    }
}

