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
    public static func makeInitForMock(_ initDecl:  InitializerDeclSyntax, _ codeBlockItems: [CodeBlockItemSyntax]) -> MemberDeclListItemSyntax {
        let notOptionalAttributes = initDecl.attributes ?? SyntaxFactory.makeBlankAttributeList()
        let codeBlockAddedFuncDecl = DeclSyntax(
            initDecl
                .withInitKeyword(
                    initDecl.initKeyword.withLeadingTrivia(.zero)
                )
                .withModifiers(
                    SyntaxFactory.makeModifierList(
                        [
                            SyntaxFactory
                                .makeDeclModifier(
                                    name: SyntaxFactory
                                        .makeIdentifier("required"),
                                    detailLeftParen: nil,
                                    detail: nil,
                                    detailRightParen: nil
                                )
                        ]
                    )
                    .withLeadingTrivia(.indent)
                    .withTrailingTrivia(.spaces(1))
                )
                .withAttributes(
                    notOptionalAttributes
                        .withLeadingTrivia(.indent)
                        .withTrailingTrivia(.newlines(1))
                )
                .withBody(.makeFormattedCodeBlock(codeBlockItems))
                .withTrailingTrivia(.newlines(2))
        )
        return SyntaxFactory
            .makeMemberDeclListItem(
                decl: codeBlockAddedFuncDecl,
                semicolon: nil
            )
    }
    
    public static func makeFunctionForMock(_ funcDecl:  FunctionDeclSyntax, _ codeBlockItems: [CodeBlockItemSyntax]) -> MemberDeclListItemSyntax {
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
    
    public static func makeArgsValForMock(_ identifier: String, _ typeSyntax: TypeSyntax, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax {
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
            attributes: attributes?.storedPropertyRemoved
        )
    }
    
    public static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax {
        SyntaxFactory
            .makeMemberDeclListItem(
                decl: DeclSyntax(
                    VariableDeclSyntax
                        .makeReturnedValForMock(
                            identifier,
                            typeSyntax,
                            modifiers: modifiers,
                            attributes: attributes?.storedPropertyRemoved
                        )
                ),
                semicolon: nil
        )
    }
    
    public static func makeFormattedZeroAssign(
        to identifier: String,
        attributes: AttributeListSyntax?,
        modifiers: ModifierListSyntax?)  -> MemberDeclListItemSyntax {
        .makeFormattedAssign(
            to: identifier,
            from: .makeZeroKeyword(),
            attributes: attributes,
            modifiers: modifiers
        )
    }

    
    public static func makeFormattedFalseAssign(
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
    
    public static func makeFormattedAssign(
        to identifier: String,
        from expr: ExprSyntax,
        attributes: AttributeListSyntax?,
        modifiers: ModifierListSyntax?)  -> MemberDeclListItemSyntax {
        
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(VariableDeclSyntax
                    .makeDeclWithAssign(
                        to: identifier,
                        from: expr,
                        attributes: attributes,
                        modifiers: modifiers
                    ))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
    
    public static func makeFormattedAssign(to identifier: String, typeAnnotation: TypeAnnotationSyntax, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?)  -> MemberDeclListItemSyntax {
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
    
    public static func makeCalledOrNot(
        identifier: String,
        modifiers: ModifierListSyntax?,
        attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax {

        if !Settings.shared.mockSettings.getScene(scene: .kvc) {
            let notOptionalModifiers = modifiers ?? SyntaxFactory.makeBlankModifierList()
            let notOptionalAttributes = attributes ?? SyntaxFactory.makeBlankAttributeList()
            return .makeFormattedFalseAssign(
                to: identifier,
                attributes: notOptionalAttributes
                    .appending(attribute: Syntax(CustomAttributeSyntax.objc))
                    .storedPropertyRemoved,
                modifiers: notOptionalModifiers.inserting(modifier: .formattedDynamic, at: 0)
            )
        } else {
            return MemberDeclListItemSyntax.makeFormattedFalseAssign(
                to: identifier,
                attributes: attributes?
                    .storedPropertyRemoved,
                modifiers: modifiers
            )
        }
    }
    
    public static func makeFormattedCallCount(
        identifier: String,
        attributes: AttributeListSyntax?,
        modifiers: ModifierListSyntax?) -> MemberDeclListItemSyntax {
        
        if !Settings.shared.mockSettings.getScene(scene: .kvc) {
            let notOptionalAttributes = attributes ?? SyntaxFactory.makeBlankAttributeList()
            let notOptionalModifiers = modifiers ?? SyntaxFactory.makeBlankModifierList()
            return .makeFormattedZeroAssign(
                to: identifier,
                attributes: notOptionalAttributes
                    .appending(attribute: Syntax(CustomAttributeSyntax.objc))
                    .storedPropertyRemoved,
                modifiers: notOptionalModifiers.inserting(modifier: .formattedDynamic, at: 0)
            )
        } else {
            return .makeFormattedZeroAssign(
                to: identifier,
                attributes: attributes?.storedPropertyRemoved,
                modifiers: modifiers
            )
        }
    }
}
