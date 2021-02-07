//
//  ClassDeclSyntax.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension ClassDeclSyntax {
    static func makeForMock(identifier: TokenSyntax, protocolNameHandler: ProtocolNameHandler, members: [[MemberDeclListItemSyntax]]) -> ClassDeclSyntax  {
        SyntaxFactory.makeClassDecl(
            attributes: nil,
            modifiers: nil,//ModifierListSyntax?,
            classKeyword: .makeFormattedClassKeyword(),
            identifier: identifier,
            genericParameterClause: nil,
            inheritanceClause: .makeFormattedProtocol(protocolNameHandler),
            genericWhereClause: nil,
            members: .makeFormatted(with: members)
        )
    }
}
