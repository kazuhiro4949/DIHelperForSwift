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
    
    func makeSpyProperty(_ identifier: TokenSyntax, _ binding: PatternBindingSyntax) -> MockPropertyForAccessor {
        let identifierByAccessor = "\(identifier.text)_\(accessorKind.text)"
        var spyProperty = MockPropertyForAccessor(accessor: self)
        
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            spyProperty.members.append(.makeFormattedFalseAssign(to: identifierByAccessor.wasCalled))
            spyProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeTrueSubstitutionExpr(to: identifierByAccessor.wasCalled).withLeadingTrivia(.indent(3)))
        }
        if !Settings.shared.spySettings.getCapture(capture: . callCount) {
            spyProperty.members.append(.makeFormattedZeroAssign(to: identifierByAccessor.callCount))
            spyProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeIncrementExpr(to: identifierByAccessor.callCount).withLeadingTrivia(.indent(3)))
        }
        if isSet, !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            spyProperty.members.append(.makeArgsValForMock(identifierByAccessor.args, binding.typeAnnotation!.type.unwrapped.withTrailingTrivia(.zero)))
            spyProperty.appendCodeBlockItem(CodeBlockItemSyntax.makeNewValueArgsExprForMock(identifierByAccessor.args).withLeadingTrivia(.indent(3)))
        }
        if isGet {
            let typeSyntax = binding.typeAnnotation!.type.withTrailingTrivia(.zero)
            spyProperty.members.append(.makeReturnedValForMock(identifierByAccessor.val, typeSyntax))
            spyProperty.appendCodeBlockItem(.makeReturnExpr(identifierByAccessor.val, .indent(3)))
        }
        return spyProperty
    }
    
    func makeStubPropery(_ identifier: TokenSyntax, _ binding: PatternBindingSyntax)  -> MockPropertyForAccessor {
        let identifierByAccessor = "\(identifier.text)_\(accessorKind.text)"
        var mockProperty = MockPropertyForAccessor(accessor: self)

        if isGet {
            let typeSyntax = binding.typeAnnotation!.type.withTrailingTrivia(.zero)            
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

