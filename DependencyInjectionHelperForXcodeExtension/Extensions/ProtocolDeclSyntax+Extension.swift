//
//  ProtocolDeclSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension ProtocolDeclSyntax {
    func makeMemberDeclListItems() -> [[MemberDeclListItemSyntax]] {
        members.members.compactMap { (item) -> [MemberDeclListItemSyntax]? in
            if let funcDeclSyntax = item.decl.as(FunctionDeclSyntax.self),
               !Settings.shared.spySettings.getTarget(target: .function) {
                return funcDeclSyntax.generateMemberDeclItemsForSpy()
            } else if let variableDecl = item.decl.as(VariableDeclSyntax.self),
                      !Settings.shared.spySettings.getTarget(target: .property) {
                return variableDecl.generateMemberDeclItemsForSpy()
            } else {
                return nil
            }
        }
    }
}
