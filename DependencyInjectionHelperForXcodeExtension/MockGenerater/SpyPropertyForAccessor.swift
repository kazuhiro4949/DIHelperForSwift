//
//  SpyPropertyForAccessor.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

struct SpyPropertyForAccessor {
    var members: [MemberDeclListItemSyntax] = []
    var accessor: AccessorDeclSyntax
    
    mutating func appendCodeBlockItem(_ codeBlock: CodeBlockItemSyntax) {
        var statements = accessor.body?.statements.map { $0 } ?? []
        statements.append(codeBlock)
        accessor = accessor.makeAccessorDeclForMock(statements)
            .withLeadingTrivia(.indent(2))
    }
}

