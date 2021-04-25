//
//  ImplicitlyUnwrappedOptionalTypeSyntax+Extensions.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//
//

import Foundation
import SwiftSyntax

extension ImplicitlyUnwrappedOptionalTypeSyntax {
    public static func make(_ unwrappedTypeSyntax: TypeSyntax) -> ImplicitlyUnwrappedOptionalTypeSyntax {
        SyntaxFactory
            .makeImplicitlyUnwrappedOptionalType(
                wrappedType: unwrappedTypeSyntax,
                exclamationMark: SyntaxFactory
                    .makeExclamationMarkToken()
            )
    }
}
