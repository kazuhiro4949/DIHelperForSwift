//
//  MemberDeclListSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension MemberDeclListSyntax {
    public static func makeFormattedMemberDeclList(_ decls: [[MemberDeclListItemSyntax]]) -> MemberDeclListSyntax {
        SyntaxFactory
            .makeMemberDeclList(decls.flatMap { $0 })
            .withLeadingTrivia(.indent)
            .withTrailingTrivia(.newlines(1))
    }
}

