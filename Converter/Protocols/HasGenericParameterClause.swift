//
//  HasGenericParameterClause.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

protocol HasGenericParameterClause {
    var genericParameterClause: GenericParameterClauseSyntax? { get }
}

extension HasGenericParameterClause {
    func hasGenerics() -> Bool {
        genericParameterClause != nil
    }
}

extension ClassDeclSyntax: HasGenericParameterClause {}
extension StructDeclSyntax: HasGenericParameterClause {}
extension FunctionDeclSyntax: HasGenericParameterClause {}
extension InitializerDeclSyntax: HasGenericParameterClause {}
