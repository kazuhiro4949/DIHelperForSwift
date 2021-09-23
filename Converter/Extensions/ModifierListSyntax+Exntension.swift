//
//  ModifierListSyntax+Exntension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/26.
//  
//

import Foundation
import SwiftSyntax

//MARK :- for protocol extractor

extension ModifierListSyntax {
    public var protocolEnabled: ModifierListSyntax? {
        let classToStaicModifiers = map {
            $0.replaceClassModifierToStaticIfNeeded()
        }
        
        let protocolEnabledModifiers = classToStaicModifiers.filter({ (declModifier) in
            declModifier.name.text == "static" || declModifier.name.text == "nonisolated"
        })
        
        if protocolEnabledModifiers.isEmpty {
            return nil
        } else {
            return SyntaxFactory.makeModifierList(protocolEnabledModifiers)
        }
    }
    
    public func inserting(modifier: DeclModifierSyntax, at index: Int) -> ModifierListSyntax {
        var modifierElements = map { $0 }
        modifierElements.insert(modifier, at: index)
        return SyntaxFactory.makeModifierList(modifierElements)
    }
}

