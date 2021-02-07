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
    static var indent: Trivia {
        .spaces(Settings.shared.indentationValue)
    }
    
    static func indent(_ level: Int) -> Trivia {
        .spaces(Settings.shared.indentationValue * level)
    }
}

