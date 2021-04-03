//
//  ModifierListSyntax+Exntension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/26.
//  
//

import Foundation
import SwiftSyntax

extension ModifierListSyntax {
    var protocolEnabled: ModifierListSyntax? {
        let classToStaicModifiers = map {
            $0.replaceClassModifierToStaticIfNeeded()
        }
        
        let protocolEnabledModifiers = classToStaicModifiers.filter({ (declModifier) in
            declModifier.name.text == "static"
        })
        
        if protocolEnabledModifiers.isEmpty {
            return nil
        } else {
            return SyntaxFactory.makeModifierList(protocolEnabledModifiers)
        }
    }
    
    func inserting(modifier: DeclModifierSyntax, at index: Int) -> ModifierListSyntax {
        var modifierElements = map { $0 }
        modifierElements.insert(modifier, at: index)
        return SyntaxFactory.makeModifierList(modifierElements)
    }
}

