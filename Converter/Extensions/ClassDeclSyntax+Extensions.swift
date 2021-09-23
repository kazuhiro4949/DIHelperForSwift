//
//  ClassDeclSyntax+Extensions.swift
//  Converter
//
//  Created by kazuhiro2 on 2021/09/23.
//

import Foundation
import SwiftSyntax

extension ClassDeclSyntax {
    var isClass: Bool {
        classOrActorKeyword.text == "class"
    }
    
    
    var isActor: Bool {
        classOrActorKeyword.text == "actor"
    }
}
