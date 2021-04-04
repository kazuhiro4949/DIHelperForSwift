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
            attributes: attributes?
                .protocolExclusiveRemoved?
                .withTrailingTrivia(.newlineAndIndent),
            modifiers: modifiers?.protocolEnabled,
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
    func generateMemberDeclItemsForMock(
        mockType: MockType) -> [MemberDeclListItemSyntax] {
        switch mockType {
        case .spy:
            FunctionSignatureDuplication.shared.list[initKeyword.text]?.count += 1
            return generateMemberDeclItemsFormSpy(
                counter: FunctionSignatureDuplication
                    .shared
                    .list[initKeyword.text],
                modifiers: modifiers,
                attributes: attributes)
        case .dummy, .stub:
            return generateMemberDeclItemsFormDummy()
        }
    }
    
    func generateMemberDeclItemsFormSpy(
        counter: Counter?,
        modifiers: ModifierListSyntax?,
        attributes: AttributeListSyntax?) -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if !Settings.shared.spySettings.getCapture(capture: .calledOrNot) {
            memberDeclListItems.append(
                .makeCalledOrNot(
                    identifier: signatureAddedIdentifier(counter: counter).wasCalled(.spy),
                    modifiers: modifiers,
                    attributes: attributes)
            )
        }
        if !Settings.shared.spySettings.getCapture(capture: .callCount) {
            memberDeclListItems.append(
                .makeFormattedCallCount(
                    identifier: signatureAddedIdentifier(counter: counter).callCount(.spy),
                    modifiers: modifiers
                )
            )
        }
        if !Settings.shared.spySettings.getCapture(capture: .passedArgument) {
            switch parameters.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                if let memberDeclListItem = makeSingleTypeArgsValForMock(
                    counter: counter,
                    modifiers: modifiers,
                    attributes: attributes) {
                    memberDeclListItems.append(memberDeclListItem)
                }
            case .tuple:
                memberDeclListItems.append(makeTupleArgsValForMock(
                                            counter: counter,
                                            modifiers: modifiers,
                                            attributes: attributes)
                )
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
    
    func makeSingleTypeArgsValForMock(counter: Counter?, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax? {
        guard let type = parameters.parameterList.first?
                .type else { return nil }
        
        return .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            type.removingAttributes
                .unwrapped
                .tparenthesizedIfNeeded
                .withTrailingTrivia(.zero),
            modifiers: modifiers,
            attributes: attributes
        )
    }
    
    func makeTupleArgsValForMock(counter: Counter?, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            TypeSyntax(TupleTypeSyntax.make(with: parameters.parameterList.makeTupleForMemberDecl())),
            modifiers: modifiers,
            attributes: attributes
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
                if let singleTypeArgsExpr = makeSingleTypeArgsExprForMock(counter: counter) {
                    codeBlockItems.append(singleTypeArgsExpr)
                }
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForSpy(counter: counter))
            }
        }
        return codeBlockItems
    }
    
    func makeSingleTypeArgsExprForMock(counter: Counter?) -> CodeBlockItemSyntax? {
        guard let tokenForMockProperty = parameters.parameterList.first?.tokenForMockProperty else {
            return nil
        }
        
        return .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args(.spy),
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            tokenForMockProperty
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
