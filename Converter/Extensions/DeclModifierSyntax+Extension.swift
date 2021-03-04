//
//  DeclModifierSyntax+Extension.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/04.
//  
//

import Foundation
import SwiftSyntax

extension DeclModifierSyntax {
    func replaceClassModifierToStaticIfNeeded() -> DeclModifierSyntax {
        if name.text == "class" {
            return withName(
                    SyntaxFactory
                        .makeIdentifier("static")
                        .withTrailingTrivia(.spaces(1))
                )
        } else {
            return self
        }
    }
}
