//
//  CodeBlockSyntax+Extensioin.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax


extension CodeBlockSyntax {
    static func makeFormattedCodeBlock(_ codeBlockItems: [CodeBlockItemSyntax]) -> CodeBlockSyntax {
        SyntaxFactory.makeCodeBlock(
            leftBrace: SyntaxFactory.makeLeftBraceToken(
                leadingTrivia: .spaces(1),
                trailingTrivia: [.spaces(1), .newlines(1)]
            ),
            statements: SyntaxFactory
                .makeCodeBlockItemList(codeBlockItems),
            rightBrace: SyntaxFactory.makeRightBraceToken(
                leadingTrivia: .indent,
                trailingTrivia: .newlines(1)
            )
        )
    }
}
