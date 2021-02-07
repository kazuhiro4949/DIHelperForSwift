//
//  TypeSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension TypeSyntax {
    var unwrapped: TypeSyntax {
        if let optionalType = self.as(OptionalTypeSyntax.self) {
            return optionalType
                .wrappedType
        } else {
            return self
        }
    }
}
