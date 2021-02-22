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
        let withoutDefaultArgs = signature.input.withParameterList(
            SyntaxFactory
                .makeFunctionParameterList(
                    signature
                        .input
                        .parameterList
                        .map { (paramSyntax) in
                            paramSyntax.withDefaultArgument(nil)
                        }
                )
        )

        return SyntaxFactory.makeFunctionDecl(
            attributes: nil,
            modifiers: nil,
            funcKeyword: funcKeyword
                .withLeadingTrivia(.zero)
                .withTrailingTrivia(.spaces(1)),
            identifier: identifier,
            genericParameterClause: nil,
            signature: signature.withInput(withoutDefaultArgs),
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
            codeBlockItems.append(.makeTrueSubstitutionExpr(to: signatureAddedIdentifier(counter: counter).wasCalled(.spy)))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            codeBlockItems.append(.makeIncrementExpr(to: signatureAddedIdentifier(counter: counter).callCount(.spy)))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                codeBlockItems.append(makeSingleTypeArgsExprForSpy(counter: counter))
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForSpy(counter: counter))
            }
        }
        if !signature.isReturnedVoid {
            codeBlockItems.append(.makeReturnExpr(signatureAddedIdentifier(counter: counter).val(.spy), .indent(2)))
        }
        return codeBlockItems
    }
    
    func generateCodeBlockItemsForStub(counter: Counter?) -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !signature.isReturnedVoid {
            codeBlockItems.append(.makeReturnExpr(signatureAddedIdentifier(counter: counter).val(.spy), .indent(2)))
        }
        return codeBlockItems
    }
    
    func generateMemberDeclItemsForMock(mockType: MockType) -> [MemberDeclListItemSyntax] {
        switch mockType {
        case .spy:
            FunctionSignatureDuplication.shared.list[identifier.text]?.count += 1
            return generateMemberDeclItemsFormSpy(counter: FunctionSignatureDuplication.shared.list[identifier.text])
        case .dummy:
            return generateMemberDeclItemsFormDummy()
        case .stub:
            FunctionSignatureDuplication.shared.list[identifier.text]?.count += 1
            return generateMemberDeclItemsFormStub(counter: FunctionSignatureDuplication.shared.list[identifier.text])
        }
    }
    
    func generateMemberDeclItemsFormSpy(counter: Counter?) -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            memberDeclListItems.append(.makeFormattedFalseAssign(to: signatureAddedIdentifier(counter: counter).wasCalled(.spy)))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            memberDeclListItems.append(.makeFormattedZeroAssign(to: signatureAddedIdentifier(counter: counter).callCount(.spy)))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                memberDeclListItems.append(makeSingleTypeArgsValForSpy(counter: counter))
            case .tuple:
                memberDeclListItems.append(makeTupleArgsValForSpy(counter: counter))
            }
        }
        if let output = signature.output, !signature.isReturnedVoid {
            memberDeclListItems.append(.makeReturnedValForMock(signatureAddedIdentifier(counter: counter).val(.spy), output.returnType))
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
                        identifier: signatureAddedIdentifier().val(.stub),
                        typeSyntax: output.returnType)
                    ]
                )
            ]
        } else {
            return [.makeFunctionForMock(self, [])]
        }
    }
    
    func generateMemberDeclItemsFormStub(counter: Counter?) -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if let output = signature.output, !signature.isReturnedVoid {
            memberDeclListItems.append(.makeReturnedValForMock(signatureAddedIdentifier(counter: counter).val(.stub), output.returnType))
        }
        let codeBlockItems = generateCodeBlockItemsForStub(counter: counter)
        memberDeclListItems.append(.makeFunctionForMock(self, codeBlockItems))
        return memberDeclListItems
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
    
    func makeSingleTypeArgsValForSpy(counter: Counter?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            signature.input.parameterList.first!
                .type!
                .removingAttributes
                .unwrapped
                .tparenthesizedIfNeeded
                .withTrailingTrivia(.zero)
        )
    }
    
    func makeSingleTypeArgsExprForSpy(counter: Counter?) -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            signature.input.parameterList.first!.tokenForMockProperty
                        )
            )
        )
    }
    
    func makeTupleArgsValForSpy(counter: Counter?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            TypeSyntax(TupleTypeSyntax.make(with: signature.input.parameterList.makeTupleForMemberDecl()))
        )
    }
    
    func makeTupleArgsExprForSpy(counter: Counter?) -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            ExprSyntax(TupleExprSyntax.make(with: signature.input.parameterList.makeTupleForCodeBlockItem()))
        )
    }
}
