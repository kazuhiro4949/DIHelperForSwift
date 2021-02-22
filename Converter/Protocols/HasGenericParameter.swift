//
//  HasGenericParameter.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

protocol HasGenericParameter {
    var genericParameters: GenericParameterClauseSyntax? { get }
}

extension HasGenericParameter {
    func hasGenerics() -> Bool {
        genericParameters != nil
    }
}
extension EnumDeclSyntax: HasGenericParameter {}
