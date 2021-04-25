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
    public static var formattedDynamic: DeclModifierSyntax {
        SyntaxFactory.makeDeclModifier(
            name: SyntaxFactory.makeIdentifier("dynamic"),
            detailLeftParen: nil,
            detail: nil,
            detailRightParen: nil
        ).withTrailingTrivia(.spaces(1))
    }
    
    
    public func replaceClassModifierToStaticIfNeeded() -> DeclModifierSyntax {
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
