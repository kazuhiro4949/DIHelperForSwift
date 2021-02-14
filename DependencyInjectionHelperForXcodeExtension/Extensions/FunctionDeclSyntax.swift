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
    func generateCodeBlockItemsForSpy(counter: Counter?) -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            codeBlockItems.append(.makeTrueSubstitutionExpr(to: signatureAddedIdentifier(counter: counter).wasCalled))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            codeBlockItems.append(.makeIncrementExpr(to: signatureAddedIdentifier(counter: counter).callCount))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                codeBlockItems.append(makeSingleTypeArgsExprForMock(counter: counter))
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForMock(counter: counter))
            }
        }
        if let _ = signature.output {
            codeBlockItems.append(.makeReturnExpr(signatureAddedIdentifier(counter: counter).val, .indent(2)))
        }
        return codeBlockItems
    }
    
    func generateMemberDeclItemsForMock(mockType: MockType) -> [MemberDeclListItemSyntax] {
        switch mockType {
        case .spy:
            FunctionSignatureDuplication.shared.list[identifier.text]?.count += 1
            return generateMemberDeclItemsFormSpy(counter: FunctionSignatureDuplication.shared.list[identifier.text])
        case .dummy, .stub:
            return generateMemberDeclItemsFormDummy()
        }
    }
    
    func generateMemberDeclItemsFormSpy(counter: Counter?) -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            memberDeclListItems.append(.makeFormattedFalseAssign(to: signatureAddedIdentifier(counter: counter).wasCalled))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            memberDeclListItems.append(.makeFormattedZeroAssign(to: signatureAddedIdentifier(counter: counter).callCount))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                memberDeclListItems.append(makeSingleTypeArgsValForMock(counter: counter))
            case .tuple:
                memberDeclListItems.append(makeTupleArgsValForMock(counter: counter))
            }
        }
        if let output = signature.output {
            memberDeclListItems.append(.makeReturnedValForMock(signatureAddedIdentifier(counter: counter).val, output.returnType))
        }
        let codeBlockItems = generateCodeBlockItemsForSpy(counter: counter)
        memberDeclListItems.append(.makeFunctionForMock(self, codeBlockItems))
        return memberDeclListItems
    }
    
    func generateMemberDeclItemsFormDummy() -> [MemberDeclListItemSyntax] {
        if let output = signature.output {
            return [
                .makeFunctionForMock(
                    self,
                    [.makeReturnForDummy(
                        identifier: signatureAddedIdentifier().val,
                        typeSyntax: output.returnType)
                    ]
                )
            ]
        } else {
            return [.makeFunctionForMock(self, [])]
        }
    }
    
    func signatureAddedIdentifier(counter: Counter? = nil) -> String {
        var identifierBaseText = identifier.text
        
        if let counter = counter {
            let digit = Int(log10(Double(counter.max)))
            let zeroPaddingCount = String(format: "%0\(digit)d", counter.count)
            identifierBaseText = "\(identifierBaseText)_<#T##identifier\(zeroPaddingCount)##identifier\(zeroPaddingCount)#>"
        }
        
        return identifierBaseText
    }
    
    func makeSingleTypeArgsValForMock(counter: Counter?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args,
            signature.input.parameterList.first!
                .type!
                .removingAttributes
                .unwrapped
                .tparenthesizedIfNeeded
                .withTrailingTrivia(.zero)
        )
    }
    
    func makeSingleTypeArgsExprForMock(counter: Counter?) -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args,
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            signature.input.parameterList.first!.tokenForMockProperty
                        )
            )
        )
    }
    
    func makeTupleArgsValForMock(counter: Counter?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args,
            TypeSyntax(TupleTypeSyntax.make(with: signature.input.parameterList.makeTupleForMemberDecl()))
        )
    }
    
    func makeTupleArgsExprForMock(counter: Counter?) -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args,
            ExprSyntax(TupleExprSyntax.make(with: signature.input.parameterList.makeTupleForCodeBlockItem()))
        )
    }
}
