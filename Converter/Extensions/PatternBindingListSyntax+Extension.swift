//
//  PatternBindingListSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension PatternBindingListSyntax {
    public static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> PatternBindingListSyntax {
        SyntaxFactory
            .makePatternBindingList([
                .makeReturnedValForMock(identifier, typeSyntax)
            ])
    }
}
