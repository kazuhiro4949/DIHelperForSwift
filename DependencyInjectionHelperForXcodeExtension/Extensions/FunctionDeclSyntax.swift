//
//  FunctionDeclSyntax.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

extension FunctionDeclSyntax {
    var interface: FunctionDeclSyntax {
        SyntaxFactory.makeFunctionDecl(
            attributes: nil,
            modifiers: nil,
            funcKeyword: funcKeyword
                .withLeadingTrivia(.zero)
                .withTrailingTrivia(.spaces(1)),
            identifier: identifier,
            genericParameterClause: nil,
            signature: signature,
            genericWhereClause: nil,
            body: nil)
    }
    
    var toMemberDeclListItem: MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(self)
                .withLeadingTrivia(.spaces(4))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}

extension FunctionDeclSyntax {
    func generateCodeBlockItemsForSpy() -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            codeBlockItems.append(.makeTrueSubstitutionExpr(to: signatureAddedIdentifier.wasCalled))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            codeBlockItems.append(.makeIncrementExpr(to: signatureAddedIdentifier.callCount))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                codeBlockItems.append(makeSingleTypeArgsExprForMock())
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForMock())
            }
        }
        if let _ = signature.output {
            codeBlockItems.append(.makeReturnExpr(signatureAddedIdentifier.val, .indent(2)))
        }
        return codeBlockItems
    }
    
    func generateMemberDeclItemsForMock(mockType: MockType) -> [MemberDeclListItemSyntax] {
        switch mockType {
        case .spy:
            return generateMemberDeclItemsFormSpy()
        case .stub:
            return generateMemberDeclItemsFormStub()
        }
    }
    
    func generateMemberDeclItemsFormSpy() -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            memberDeclListItems.append(.makeFormattedFalseAssign(to: signatureAddedIdentifier.wasCalled))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            memberDeclListItems.append(.makeFormattedZeroAssign(to: signatureAddedIdentifier.callCount))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                memberDeclListItems.append(makeSingleTypeArgsValForMock())
            case .tuple:
                memberDeclListItems.append(makeTupleArgsValForMock())
            }
        }
        if let output = signature.output {
            memberDeclListItems.append(.makeReturnedValForMock(signatureAddedIdentifier.val, output.returnType))
        }
        let codeBlockItems = generateCodeBlockItemsForSpy()
        memberDeclListItems.append(.makeFunctionForMock(self, codeBlockItems))
        return memberDeclListItems
    }
    
    func generateMemberDeclItemsFormStub() -> [MemberDeclListItemSyntax] {
        if let output = signature.output {
            return [
                .makeFunctionForMock(
                    self,
                    [.makeReturnForStub(
                        identifier: signatureAddedIdentifier.val,
                        typeSyntax: output.returnType)
                    ]
                )
            ]
        } else {
            return [.makeFunctionForMock(self, [])]
        }
    }
    
    var signatureAddedIdentifier: String {
        var identifierBaseText = identifier.text
        
        if FunctionSignatureDuplication.shared.list.contains(identifierBaseText) {
            identifierBaseText = "\(identifierBaseText)_<#T##name#>"
        }
        
        return identifierBaseText
    }
    
    func makeSingleTypeArgsValForMock() -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier.args,
            signature.input.parameterList.first!.type!.unwrapped.withTrailingTrivia(.zero)
        )
    }
    
    func makeSingleTypeArgsExprForMock() -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier.args,
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            signature.input.parameterList.first!.tokenForMockProperty
                        )
            )
        )
    }
    
    func makeTupleArgsValForMock() -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier.args,
            TypeSyntax(TupleTypeSyntax.make(with: signature.input.parameterList.makeTupleForMemberDecl()))
        )
    }
    
    func makeTupleArgsExprForMock() -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier.args,
            ExprSyntax(TupleExprSyntax.make(with: signature.input.parameterList.makeTupleForCodeBlockItem()))
        )
    }
}
