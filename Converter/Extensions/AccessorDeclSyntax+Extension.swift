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
    public var isSet: Bool {
        accessorKind.text == "set"
    }
    
    public var isGet: Bool {
        accessorKind.text == "get"
    }
    
    public func makeMockProperty(_ identifier: TokenSyntax, _ binding: PatternBindingSyntax, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MockPropertyForAccessor {
        let identifierByAccessor = "\(identifier.text)_\(accessorKind.text)"
        var mockProperty = MockPropertyForAccessor(accessor: self)
        
        if !Settings.shared.mockSettings.getCapture(capture: .calledOrNot) {
            mockProperty.members.append(
                .makeCalledOrNot(
                    identifier: identifierByAccessor.wasCalled(.mock),
                    modifiers: modifiers,
                    attributes: attributes)
            )
            mockProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeTrueSubstitutionExpr(to: identifierByAccessor.wasCalled(.mock)).withLeadingTrivia(.indent(3)))
        }
        if !Settings.shared.mockSettings.getCapture(capture: . callCount) {
            mockProperty.members.append(
                .makeFormattedCallCount(
                    identifier: identifierByAccessor.callCount(.mock),
                    attributes: attributes,
                    modifiers: modifiers
                )
            )
            mockProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeIncrementExpr(to: identifierByAccessor.callCount(.mock)).withLeadingTrivia(.indent(3)))
        }
        if isSet,
           let unwrappedType = binding
            .typeAnnotation?
            .type
            .unwrapped
            .withTrailingTrivia(.zero),
           !Settings
            .shared
            .mockSettings
            .getCapture(capture: .passedArgument) {
            
            mockProperty.members.append(
                .makeArgsValForMock(
                    identifierByAccessor.args(.mock),
                    unwrappedType,
                    modifiers: modifiers,
                    attributes: attributes
                )
            )
            mockProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeNewValueArgsExprForMock(identifierByAccessor.args(.mock)).withLeadingTrivia(.indent(3)))
        }
        if isGet,
           let typeSyntax = binding
            .typeAnnotation?
            .type
            .withTrailingTrivia(.zero) {
            
            mockProperty.members.append(.makeReturnedValForMock(
                                        identifierByAccessor.val(.mock),
                                        typeSyntax,
                                        modifiers: modifiers,
                                        attributes: attributes))
            mockProperty.appendCodeBlockItem(.makeReturnExpr(identifierByAccessor.val(.mock), .indent(3)))
        }
        return mockProperty
    }
    
    public func makeDummyPropery(_ identifier: TokenSyntax, _ binding: PatternBindingSyntax)  -> MockPropertyForAccessor {
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
    
    public func makeAccessorDeclForMock(_ codeBlockItems: [CodeBlockItemSyntax]) -> AccessorDeclSyntax {
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

