//
//  DictionaryElementListSyntax.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension DictionaryElementListSyntax {
    static func makeBlank() -> DictionaryElementListSyntax {
        SyntaxFactory
            .makeDictionaryElementList(
                [.makeBlank()]
            )
    }
}
