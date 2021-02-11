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
    func makeMemberDeclListItems(mockType: MockType) -> [[MemberDeclListItemSyntax]] {
        members.members.compactMap { (item) -> [MemberDeclListItemSyntax]? in
            if let funcDeclSyntax = item.decl.as(FunctionDeclSyntax.self),
               !Settings.shared.spySettings.getTarget(target: .function) {
                return funcDeclSyntax.generateMemberDeclItemsForMock(mockType: mockType)
            } else if let variableDecl = item.decl.as(VariableDeclSyntax.self),
                      !Settings.shared.spySettings.getTarget(target: .property) {
                return variableDecl.generateMemberDeclItemsForMock(mockType: mockType)
            } else {
                return nil
            }
        }
    }
}

extension ProtocolDeclSyntax {
    func generateMockClass(_ mockType: MockType) -> ClassDeclSyntax {
        SyntaxFactory.makeClassDecl(
            attributes: self.attributes,
            modifiers: self.modifiers,
            classKeyword: .makeFormattedClassKeyword(),
            identifier: mockIdentifier(mockType: mockType),
            genericParameterClause: nil,
            inheritanceClause: .makeFormattedProtocol(ProtocolNameHandler(self)),
            genericWhereClause: nil,
            members: .makeFormatted(with: makeMemberDeclListItems(mockType: mockType))
        )
    }
    
    func mockIdentifier(mockType: MockType) -> TokenSyntax {
        SyntaxFactory
            .makeIdentifier(
                .init(
                    format: mockType.format,
                    ProtocolNameHandler(self).getBaseName()
                )
            )
    }
}
