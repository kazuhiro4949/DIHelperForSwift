//
//  PatternSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension PatternSyntax {
    static func makeIdentifierPatternSyntax(with name: String) -> PatternSyntax {
        PatternSyntax(SyntaxFactory
            .makeIdentifierPattern(
                identifier: SyntaxFactory.makeIdentifier(
                    name
                )
            )
        )
    }
}

