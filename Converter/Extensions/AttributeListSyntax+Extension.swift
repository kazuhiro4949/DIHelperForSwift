//
//  AttributeListSyntax+Extension.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/16.
//  
//

import Foundation
import SwiftSyntax

extension AttributeListSyntax {
    var protocolExclusiveRemoved: AttributeListSyntax? {
        let attributes = filter {
            let attribute = $0.as(AttributeSyntax.self)
            return (attribute?.attributeName.text == "available")
        }
        if attributes.isEmpty {
            return nil
        } else {
            return SyntaxFactory
                .makeAttributeList(attributes)
                .withTrailingTrivia(.newlines(1))
        }
    }
    
    static var formattedObjc: AttributeListSyntax? {
        SyntaxFactory.makeAttributeList([
            Syntax(
                SyntaxFactory.makeCustomAttribute(
                    atSignToken: SyntaxFactory.makeAtSignToken(),
                    attributeName: SyntaxFactory.makeTypeIdentifier("objc"),
                    leftParen: nil,
                    argumentList: nil,
                    rightParen: nil)
            )
        ])
        .withTrailingTrivia(.spaces(1))
    }
}
