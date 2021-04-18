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
    
    // stored property cannot have availability
    var storedPropertyRemoved: AttributeListSyntax? {
        let attributes = filter {
            let attribute = $0.as(AttributeSyntax.self)
            return (attribute?.attributeName.text != "available")
        }
        if attributes.isEmpty {
            return nil
        } else {
            return SyntaxFactory
                .makeAttributeList(attributes)
                .withTrailingTrivia(.newlines(1))
        }
    }
    
    func appending(attribute: Syntax) -> AttributeListSyntax {
        var attributeElements = enumerated().map { offset, elem -> Syntax in
            if offset + 1 == count {
                return elem.withTrailingTrivia(.spaces(1))
            } else {
                return elem
            }
        }
        
        attributeElements.append(attribute)
        return SyntaxFactory.makeAttributeList(attributeElements)
    }
}

extension CustomAttributeSyntax {

    
    static var objc: CustomAttributeSyntax {
        SyntaxFactory.makeCustomAttribute(
            atSignToken: SyntaxFactory.makeAtSignToken(),
            attributeName: SyntaxFactory.makeTypeIdentifier("objc"),
            leftParen: nil,
            argumentList: nil,
            rightParen: nil)
    }
}
