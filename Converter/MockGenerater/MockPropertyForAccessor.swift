//
//  MockPropertyForAccessor.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

public struct MockPropertyForAccessor {
    public var members: [MemberDeclListItemSyntax] = []
    public var accessor: AccessorDeclSyntax
    
    public init(accessor: AccessorDeclSyntax) {
        self.accessor = accessor.makeAccessorDeclForMock([])
            .withLeadingTrivia(.indent(2))
    }
    
    public mutating func appendCodeBlockItem(_ codeBlock: CodeBlockItemSyntax) {
        var statements = accessor.body?.statements.map { $0 } ?? []
        statements.append(codeBlock)
        accessor = accessor.makeAccessorDeclForMock(statements)
            .withLeadingTrivia(.indent(2))
    }
}

