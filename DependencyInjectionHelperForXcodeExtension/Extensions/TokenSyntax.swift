//
//  TokenSyntax.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

extension TokenSyntax {
    func makeStringLiteral(with suffixText: String) -> TokenSyntax {
        return withKind(.stringLiteral(text + suffixText))
    }
}

