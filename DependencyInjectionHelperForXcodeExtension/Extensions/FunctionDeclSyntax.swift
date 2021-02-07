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
    
    func generateMemberDeclItemsForSpy() -> [MemberDeclListItemSyntax] {
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
    
    var signatureAddedIdentifier: String {
        var identifierBaseText = identifier.text
        
        // TODO:- added ignorance and increment option
        let paramListText = signature.input.parameterList.description
        let returnText = signature.output?.returnType.description ?? ""
        let encodedParamListText = paramListText.replacingToVariableAllowedString()
        let encodedReturnText = returnText.replacingToVariableAllowedString()
        if !encodedParamListText.isEmpty {
            identifierBaseText = "\(identifierBaseText)_\(encodedParamListText)"
        }
        if !encodedReturnText.isEmpty {
            identifierBaseText = "\(identifierBaseText)_\(encodedReturnText)"
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
