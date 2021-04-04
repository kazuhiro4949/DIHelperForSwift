//
//  AccessorDeclSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension AccessorDeclSyntax {
    var isSet: Bool {
        accessorKind.text == "set"
    }
    
    var isGet: Bool {
        accessorKind.text == "get"
    }
    
    func makeSpyProperty(_ identifier: TokenSyntax, _ binding: PatternBindingSyntax, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MockPropertyForAccessor {
        let identifierByAccessor = "\(identifier.text)_\(accessorKind.text)"
        var spyProperty = MockPropertyForAccessor(accessor: self)
        
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            spyProperty.members.append(
                .makeCalledOrNot(
                    identifier: identifierByAccessor.wasCalled(.spy),
                    modifiers: modifiers,
                    attributes: attributes)
            )
            spyProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeTrueSubstitutionExpr(to: identifierByAccessor.wasCalled(.spy)).withLeadingTrivia(.indent(3)))
        }
        if !Settings.shared.spySettings.getCapture(capture: . callCount) {
            spyProperty.members.append(
                .makeFormattedCallCount(
                    identifier: identifierByAccessor.callCount(.spy),
                    attributes: attributes,
                    modifiers: modifiers
                )
            )
            spyProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeIncrementExpr(to: identifierByAccessor.callCount(.spy)).withLeadingTrivia(.indent(3)))
        }
        if isSet,
           let unwrappedType = binding
            .typeAnnotation?
            .type
            .unwrapped
            .withTrailingTrivia(.zero),
           !Settings
            .shared
            .spySettings
            .getCapture(capture: .passedArgument) {
            
            spyProperty.members.append(
                .makeArgsValForMock(
                    identifierByAccessor.args(.spy),
                    unwrappedType,
                    modifiers: modifiers,
                    attributes: attributes
                )
            )
            spyProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeNewValueArgsExprForMock(identifierByAccessor.args(.spy)).withLeadingTrivia(.indent(3)))
        }
        if isGet,
           let typeSyntax = binding
            .typeAnnotation?
            .type
            .withTrailingTrivia(.zero) {
            
            spyProperty.members.append(.makeReturnedValForMock(
                                        identifierByAccessor.val(.spy),
                                        typeSyntax,
                                        modifiers: modifiers,
                                        attributes: attributes))
            spyProperty.appendCodeBlockItem(.makeReturnExpr(identifierByAccessor.val(.spy), .indent(3)))
        }
        return spyProperty
    }
    
    func makeDummyPropery(_ identifier: TokenSyntax, _ binding: PatternBindingSyntax)  -> MockPropertyForAccessor {
        let identifierByAccessor = "\(identifier.text)_\(accessorKind.text)"
        var mockProperty = MockPropertyForAccessor(accessor: self)

        if isGet,
           let typeSyntax = binding
            .typeAnnotation?
            .type
            .withTrailingTrivia(.zero) {
                        
            mockProperty.appendCodeBlockItem(CodeBlockItemSyntax
                                                .makeFormattedExpr(
                                                    expr: SyntaxFactory.makeReturnKeyword(),
                                                    right: .makeReturnedValForMock(identifierByAccessor, typeSyntax)
                                                ).withLeadingTrivia(.indent(3))
            )
        }
        return mockProperty
    }
    
    func makeAccessorDeclForMock(_ codeBlockItems: [CodeBlockItemSyntax]) -> AccessorDeclSyntax {
        SyntaxFactory.makeAccessorDecl(
            attributes: attributes,
            modifier: modifier,
            accessorKind: accessorKind
                .withLeadingTrivia(.indent(3))
                .withTrailingTrivia(.zero),
            parameter: parameter,
            body: SyntaxFactory.makeCodeBlock(
                leftBrace: .makeCleanFormattedLeftBrance(.spaces(1)),
                statements: SyntaxFactory
                    .makeCodeBlockItemList(codeBlockItems),
                rightBrace: .makeCleanFormattedRightBrance(.indent(2))
            ))
    }
}

