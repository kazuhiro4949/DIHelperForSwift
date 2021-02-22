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
        let withoutDefaultArgs = parameters.withParameterList(
            SyntaxFactory
                .makeFunctionParameterList(
                    parameters
                        .parameterList
                        .map { (paramSyntax) in
                            paramSyntax.withDefaultArgument(nil)
                        }
                )
        )
        
        return SyntaxFactory.makeInitializerDecl(
            attributes: nil,
            modifiers: nil,
            initKeyword: SyntaxFactory.makeInitKeyword(
                leadingTrivia: .zero
            ),
            optionalMark: optionalMark,
            genericParameterClause: nil,
            parameters: withoutDefaultArgs,
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
            FunctionSignatureDuplication.shared.list[initKeyword.text]?.count += 1
            return generateMemberDeclItemsFormSpy(counter: FunctionSignatureDuplication.shared.list[initKeyword.text])
        case .dummy, .stub:
            return generateMemberDeclItemsFormDummy()
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
            switch parameters.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                memberDeclListItems.append(makeSingleTypeArgsValForMock(counter: counter))
            case .tuple:
                memberDeclListItems.append(makeTupleArgsValForMock(counter: counter))
            }
        }
        
        let codeBlockItems = generateCodeBlockItemsForSpy(counter: counter)
        memberDeclListItems.append(.makeInitForMock(self, codeBlockItems))
        return memberDeclListItems
    }
    
    func generateMemberDeclItemsFormDummy() -> [MemberDeclListItemSyntax] {
        return [.makeInitForMock(self, [])]
    }
    
    func signatureAddedIdentifier(counter: Counter? = nil) -> String {
        var _initKeyword = initKeyword.text
        
        if let counter = counter {
            let digit = Int(log10(Double(counter.max)))
            let zeroPaddingCount = String(format: "%0\(digit)d", counter.count)
            _initKeyword = "\(_initKeyword)_<#T##identifier\(zeroPaddingCount)##identifier\(zeroPaddingCount)#>"
        }
        
        return _initKeyword
    }
    
    func makeSingleTypeArgsValForMock(counter: Counter?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            parameters.parameterList.first!
                .type!
                .removingAttributes
                .unwrapped
                .tparenthesizedIfNeeded
                .withTrailingTrivia(.zero)
        )
    }
    
    func makeTupleArgsValForMock(counter: Counter?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            TypeSyntax(TupleTypeSyntax.make(with: parameters.parameterList.makeTupleForMemberDecl()))
        )
    }
    
    func generateCodeBlockItemsForSpy(counter: Counter?) -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            codeBlockItems.append(.makeTrueSubstitutionExpr(to: signatureAddedIdentifier(counter: counter).wasCalled(.spy)))
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            codeBlockItems.append(.makeIncrementExpr(to: signatureAddedIdentifier(counter: counter).callCount(.spy)))
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch parameters.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                codeBlockItems.append(makeSingleTypeArgsExprForMock(counter: counter))
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForSpy(counter: counter))
            }
        }
        return codeBlockItems
    }
    
    func makeSingleTypeArgsExprForMock(counter: Counter?) -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            parameters.parameterList.first!.tokenForMockProperty
                        )
            )
        )
    }
    
    func makeTupleArgsExprForSpy(counter: Counter?) -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            ExprSyntax(TupleExprSyntax.make(with: parameters.parameterList.makeTupleForCodeBlockItem()))
        )
    }
}