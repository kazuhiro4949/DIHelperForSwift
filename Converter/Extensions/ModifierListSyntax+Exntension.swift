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
        let protocolEnabledModifiers = filter({ (declModifier) in
            declModifier.name.text == "static"
        })
        
        if protocolEnabledModifiers.isEmpty {
            return nil
        } else {
            return SyntaxFactory.makeModifierList(protocolEnabledModifiers)
        }
        
    }
}
