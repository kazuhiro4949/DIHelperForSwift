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
    static func makeInitForMock(_ initDecl:  InitializerDeclSyntax, _ codeBlockItems: [CodeBlockItemSyntax]) -> MemberDeclListItemSyntax {
        let codeBlockAddedFuncDecl = DeclSyntax(
            initDecl
                .withLeadingTrivia(.spaces(1))
                .withModifiers(SyntaxFactory.makeModifierList([SyntaxFactory.makeDeclModifier(name: SyntaxFactory.makeIdentifier("required"), detailLeftParen: nil, detail: nil, detailRightParen: nil)]))
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
    
    static func makeArgsValForMock(_ identifier: String, _ typeSyntax: TypeSyntax, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax {
        makeFormattedAssign(
            to: identifier,
            typeAnnotation: .makeFormatted(
                TypeSyntax(SyntaxFactory
                    .makeOptionalType(
                        wrappedType: typeSyntax,
                        questionMark: SyntaxFactory.makePostfixQuestionMarkToken()
                    )
                )
            ),
            modifiers: modifiers,
            attributes: attributes
        )
    }
    
    static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax {
        SyntaxFactory
            .makeMemberDeclListItem(
                decl: DeclSyntax(
                    VariableDeclSyntax
                        .makeReturnedValForMock(
                            identifier,
                            typeSyntax,
                            modifiers: modifiers,
                            attributes: attributes
                        )
                ),
                semicolon: nil
        )
    }
    
    static func makeFormattedZeroAssign(
        to identifier: String,
        modifiers: ModifierListSyntax?)  -> MemberDeclListItemSyntax {
        .makeFormattedAssign(
            to: identifier,
            from: .makeZeroKeyword(),
            modifiers: modifiers
        )
    }
    
    static func makeFormattedFalseAssign(to identifier: String, modifiers: ModifierListSyntax?)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        from: .makeFalseKeyword(),
                        attributes: nil,
                        modifiers: modifiers
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
    
    static func makeFormattedDynamicFalseAssign(
        to identifier: String,
        attributes: AttributeListSyntax?,
        modifiers: ModifierListSyntax?)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        from: .makeFalseKeyword(),
                        attributes: attributes,
                        modifiers: modifiers
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
    
    static func makeFormattedAssign(to identifier: String, from expr: ExprSyntax, modifiers: ModifierListSyntax?)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        from: expr,
                        attributes: nil,
                        modifiers: modifiers
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
    
    static func makeFormattedAssign(to identifier: String, typeAnnotation: TypeAnnotationSyntax, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?)  -> MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        typeAnnotation: typeAnnotation,
                        modifiers: modifiers,
                        attributes: attributes
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}
