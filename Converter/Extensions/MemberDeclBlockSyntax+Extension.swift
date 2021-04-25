//
//  MemberDeclBlockSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension MemberDeclBlockSyntax {
    public static func makeFormatted(with decls: [[MemberDeclListItemSyntax]]) -> MemberDeclBlockSyntax {
        SyntaxFactory.makeMemberDeclBlock(
            leftBrace: .makeCleanFormattedLeftBrance(),
            members: .makeFormattedMemberDeclList(decls),
            rightBrace: .makeCleanFormattedRightBrance()
        )
    }
}
