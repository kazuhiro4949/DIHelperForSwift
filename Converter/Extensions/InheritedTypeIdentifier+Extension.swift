//
//  InheritedTypeIdentifier+Extension.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/04/03.
//  
//

import Foundation
import SwiftSyntax

extension InheritedTypeSyntax {
    public static var formattedNSObject: InheritedTypeSyntax {
        SyntaxFactory.makeInheritedType(
            typeName: SyntaxFactory.makeTypeIdentifier("NSObject"),
            trailingComma: SyntaxFactory.makeCommaToken())
            .withTrailingTrivia(.spaces(1))
    }
    
    public static func formattedProtocol(_ name: String) -> InheritedTypeSyntax {
        SyntaxFactory
        .makeInheritedType(
            typeName: SyntaxFactory
                .makeTypeIdentifier(name),
            trailingComma: nil
        )
    }
}
