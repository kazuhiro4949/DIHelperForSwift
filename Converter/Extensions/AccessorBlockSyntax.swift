//
//  AccessorBlockSyntax.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

extension AccessorBlockSyntax {
    var hasGetter: Bool {
        accessors.contains {
            $0.accessorKind.text == "get"
        }
    }
    
    var contextualKeywords: PatternBindingSyntax.ContextualKeyword {
        accessors.reduce(into: PatternBindingSyntax.ContextualKeyword()) { (result, accessor) in
            if accessor.accessorKind.text == "get" {
                result.insert(.get)
            } else if accessor.accessorKind.text == "set" {
                result.insert(.set)
            }
        }
    }
    
    static func makeAccessorBlock(accessors: [AccessorDeclSyntax]?) -> AccessorBlockSyntax? {
        guard let accessors = accessors else {
            return nil
        }
        
        return SyntaxFactory
            .makeAccessorBlock(
                leftBrace: .makeCleanFormattedLeftBrance(),
                accessors: SyntaxFactory.makeAccessorList(
                    accessors
                ),
                rightBrace: .makeCleanFormattedRightBrance(.indent)
            )
    }
    
    func makeMockPropertyForAccessors(
        for mockType: MockType,
        identifier: TokenSyntax,
        binding: PatternBindingSyntax,
        modifiers: ModifierListSyntax?,
        attributes: AttributeListSyntax?) -> [MockPropertyForAccessor]? {
        
        switch mockType {
        case .spy:
            return accessors.map { $0.makeSpyProperty(identifier, binding, modifiers: modifiers, attributes: attributes) }
        case .dummy:
            return accessors.map { $0.makeDummyPropery(identifier, binding) }
        case .stub:
            return nil
        }
    }
}
