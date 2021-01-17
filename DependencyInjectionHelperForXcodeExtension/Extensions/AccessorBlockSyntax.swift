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
}
