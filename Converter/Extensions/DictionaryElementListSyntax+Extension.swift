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
    public static func makeBlank() -> DictionaryElementListSyntax {
        SyntaxFactory
            .makeDictionaryElementList(
                [.makeBlank()]
            )
    }
}
