//
//  MemberDeclListItemSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension MemberDeclListItemSyntax {
    static func makeFunctionForMock(_ funcDecl:  FunctionDeclSyntax, _ codeBlockItems: [CodeBlockItemSyntax]) -> MemberDeclListItemSyntax {
        let codeBlockAddedFuncDecl = DeclSyntax(
            funcDecl
                .withBody(.makeFormattedCodeBlock(codeBlockItems))
                .withLeadingTrivia(.indent)
                .withTrailingTrivia(.newlines(2))
        )
        return SyntaxFactory
            .makeMemberDeclListItem(
                decl: codeBlockAddedFuncDecl,
                semicolon: nil
            )
    }
    
    static func makeArgsValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> MemberDeclListItemSyntax {
        makeFormattedAssign(
            to: identifier,
            typeAnnotation: .makeFormatted(
                TypeSyntax(SyntaxFactory
                    .makeOptionalType(
                        wrappedType: typeSyntax,
                        questionMark: SyntaxFactory.makePostfixQuestionMarkToken()
                    )
                )
            )
        )
    }
    
    static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> MemberDeclListItemSyntax {
        SyntaxFactory
            .makeMemberDeclListItem(
                decl: DeclSyntax(
                    VariableDeclSyntax
                        .makeReturnedValForMock(identifier, typeSyntax)
                ),
                semicolon: nil
        )
    }
    
    static func makeFormattedZeroAssign(to identifier: String)  -> MemberDeclListItemSyntax {
        .makeFormattedAssign(
            to: identifier,
            from: .makeZeroKeyword()
        )
    }
    
    static func makeFormattedFalseAssign(to identifier: String)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        from: .makeFalseKeyword()
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
    
    static func makeFormattedAssign(to identifier: String, from expr: ExprSyntax)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        from: expr
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
    
    static func makeFormattedAssign(to identifier: String, typeAnnotation: TypeAnnotationSyntax)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        typeAnnotation: typeAnnotation
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}
