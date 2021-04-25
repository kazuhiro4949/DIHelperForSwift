//
//  Trivia+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//
//

import Foundation
import SwiftSyntax

extension Trivia {
    public static var indent: Trivia {
        .spaces(Settings.shared.indentationValue)
    }
    
    public static var newlineAndIndent: Trivia {
        [
            .newlines(1),
            .spaces(Settings.shared.indentationValue)
        ]
    }
    
    public static func indent(_ level: Int) -> Trivia {
        .spaces(Settings.shared.indentationValue * level)
    }
}

