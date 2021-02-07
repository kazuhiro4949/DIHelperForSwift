//
//  CodeBlockItemSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension CodeBlockItemSyntax {
    static func makeNewValueArgsExprForMock(_ identifier: String) -> CodeBlockItemSyntax {
        CodeBlockItemSyntax
            .makeArgsExprForMock(
                identifier,
                ExprSyntax(IdentifierExprSyntax.makeFormattedNewValueExpr())
            )
    }
    
    static func makeArgsExprForMock(_ identifier: String, _ exprSyntax: ExprSyntax) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: SyntaxFactory.makeIdentifier(identifier),
            expr: SyntaxFactory.makeEqualToken(),
            right: exprSyntax
        )
    }
    
    static func makeReturnExpr(_ identifier: String, _ indent: Trivia) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            expr: SyntaxFactory.makeReturnKeyword(),
            right: SyntaxFactory.makeIdentifier(identifier)
        )
        .withLeadingTrivia(indent)
    }
    
    static func makeIncrementExpr(to identifier: String) -> CodeBlockItemSyntax {
        .makeFormattedExpr(
            left: SyntaxFactory
                .makeIdentifier(identifier),
            expr: SyntaxFactory.makeIdentifier("+="),
            right: SyntaxFactory.makeIntegerLiteral("1")
        )
    }
    
    static func makeFormattedExpr(expr: TokenSyntax, right: TokenSyntax) -> CodeBlockItemSyntax {
        SyntaxFactory.makeCodeBlockItem(
            item: Syntax(SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory
                    .makeExprList([
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: expr,
                                        declNameArguments: nil
                                    )
                                    .withLeadingTrivia(.indent(2))
                                    .withTrailingTrivia(.spaces(1))
                        ),
                        ExprSyntax(SyntaxFactory
                                    .makeIdentifierExpr(
                                        identifier: right,
                                        declNameArguments: nil
                                    )
                                    .withTrailingTrivia(.newlines(1))
                        )
                    ]))),
            semicolon: nil,
            errorTokens: nil)
    }
    
    static func makeFormattedExpr(left: TokenSyntax, expr: TokenSyntax, right: TokenSyntax) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: left,
                                    declNameArguments: nil
                                )
                                .withLeadingTrivia(.indent(2))
                                .withTrailingTrivia(.spaces(1))
                    ),
            expr: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: expr,
                                    declNameArguments: nil
                                )
                                .withTrailingTrivia(.spaces(1))
                    ),
            right: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: right,
                                    declNameArguments: nil
                                )
                                .withTrailingTrivia(.newlines(1))
                    )
        )
    }
    
    static func makeFormattedExpr(left: TokenSyntax, expr: TokenSyntax, right: ExprSyntax) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: left,
                                    declNameArguments: nil
                                )
                                .withLeadingTrivia(.indent(2))
                                .withTrailingTrivia(.spaces(1))
                    ),
            expr: ExprSyntax(SyntaxFactory
                                .makeIdentifierExpr(
                                    identifier: expr,
                                    declNameArguments: nil
                                )
                                .withTrailingTrivia(.spaces(1))
                    ),
            right: right
        )
    }
    
    static func makeFormattedExpr(left: ExprSyntax, expr: ExprSyntax, right: ExprSyntax) -> CodeBlockItemSyntax {
        SyntaxFactory.makeCodeBlockItem(
            item: Syntax(SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory
                    .makeExprList([
                        left,
                        expr,
                        right
                    ]))),
            semicolon: nil,
            errorTokens: nil)
    }
    
    static func makeTrueSubstitutionExpr(to callIdentifier: String) -> CodeBlockItemSyntax {
        makeFormattedExpr(
            left: SyntaxFactory.makeIdentifier(callIdentifier),
            expr: SyntaxFactory.makeEqualToken(),
            right: SyntaxFactory.makeTrueKeyword()
        )
    }
}

