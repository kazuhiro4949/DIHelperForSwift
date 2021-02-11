//
//  InitializerDeclSyntax.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

extension InitializerDeclSyntax {
    var interface: InitializerDeclSyntax {
        SyntaxFactory.makeInitializerDecl(
            attributes: nil,
            modifiers: nil,
            initKeyword: SyntaxFactory.makeInitKeyword(
                leadingTrivia: .zero
            ),
            optionalMark: optionalMark,
            genericParameterClause: nil,
            parameters: parameters,
            throwsOrRethrowsKeyword: throwsOrRethrowsKeyword,
            genericWhereClause: nil,
            body: nil
        )
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

extension InitializerDeclSyntax {
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
            switch parameters.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                memberDeclListItems.append(makeSingleTypeArgsValForMock())
            case .tuple:
                memberDeclListItems.append(makeTupleArgsValForMock())
            }
        }
        
        let codeBlockItems = generateCodeBlockItemsForSpy()
        memberDeclListItems.append(.makeInitForMock(self, codeBlockItems))
        return memberDeclListItems
    }
    
    func generateMemberDeclItemsFormStub() -> [MemberDeclListItemSyntax] {
        return [.makeInitForMock(self, [])]
    }
    
    var signatureAddedIdentifier: String {
        let paramListText = parameters.description
        let encodedParamListText = paramListText.replacingToVariableAllowedString()
        if !encodedParamListText.isEmpty {
            return "init_\(encodedParamListText)"
        } else {
            return "init"
        }
    }
    
    func makeSingleTypeArgsValForMock() -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier.args,
            parameters.parameterList.first!.type!.unwrapped.withTrailingTrivia(.zero)
        )
    }
    
    func makeTupleArgsValForMock() -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier.args,
            TypeSyntax(TupleTypeSyntax.make(with: parameters.parameterList.makeTupleForMemberDecl()))
        )
    }
    
    func generateCodeBlockItemsForSpy() -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            codeBlockItems.append(.makeTrueSubstitutionExpr(to: signatureAddedIdentifier.wasCalled))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            codeBlockItems.append(.makeIncrementExpr(to: signatureAddedIdentifier.callCount))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch parameters.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                codeBlockItems.append(makeSingleTypeArgsExprForMock())
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForMock())
            }
        }
        return codeBlockItems
    }
    
    func makeSingleTypeArgsExprForMock() -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier.args,
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            parameters.parameterList.first!.tokenForMockProperty
                        )
            )
        )
    }
    
    func makeTupleArgsExprForMock() -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier.args,
            ExprSyntax(TupleExprSyntax.make(with: parameters.parameterList.makeTupleForCodeBlockItem()))
        )
    }
}
