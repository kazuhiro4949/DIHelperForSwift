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
    public var interface: InitializerDeclSyntax {
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
    
    public var toMemberDeclListItem: MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(self)
                .withLeadingTrivia(.spaces(4))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}

extension InitializerDeclSyntax {
    public func generateMemberDeclItemsForMock(
        mockType: MockType) -> [MemberDeclListItemSyntax] {
        switch mockType {
        case .mock:
            FunctionSignatureDuplication.shared.list[initKeyword.text]?.count += 1
            return generateMemberDeclItemsFormMock(
                counter: FunctionSignatureDuplication
                    .shared
                    .list[initKeyword.text],
                modifiers: modifiers,
                attributes: attributes)
        case .dummy, .stub:
            return generateMemberDeclItemsFormDummy()
        }
    }
    
    public func generateMemberDeclItemsFormMock(
        counter: Counter?,
        modifiers: ModifierListSyntax?,
        attributes: AttributeListSyntax?) -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if !Settings.shared.mockSettings.getCapture(capture: .calledOrNot) {
            memberDeclListItems.append(
                .makeCalledOrNot(
                    identifier: signatureAddedIdentifier(counter: counter).wasCalled(.mock),
                    modifiers: modifiers,
                    attributes: attributes)
            )
        }
        if !Settings.shared.mockSettings.getCapture(capture: .callCount) {
            memberDeclListItems.append(
                .makeFormattedCallCount(
                    identifier: signatureAddedIdentifier(counter: counter).callCount(.mock),
                    attributes: attributes,
                    modifiers: modifiers
                )
            )
        }
        if !Settings.shared.mockSettings.getCapture(capture: .passedArgument) {
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
        
        let codeBlockItems = generateCodeBlockItemsForMock(counter: counter)
        memberDeclListItems.append(.makeInitForMock(self, codeBlockItems))
        return memberDeclListItems
    }
    
    public func generateMemberDeclItemsFormDummy() -> [MemberDeclListItemSyntax] {
        return [.makeInitForMock(self, [])]
    }
    
    public func signatureAddedIdentifier(counter: Counter? = nil) -> String {
        var _initKeyword = initKeyword.text
        
        if let counter = counter {
            let digit = Int(log10(Double(counter.max)))
            let zeroPaddingCount = String(format: "%0\(digit)d", counter.count)
            _initKeyword = "\(_initKeyword)_<#T##identifier\(zeroPaddingCount)##identifier\(zeroPaddingCount)#>"
        }
        
        return _initKeyword
    }
    
    public func makeSingleTypeArgsValForMock(counter: Counter?, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax? {
        guard let type = parameters.parameterList.first?
                .type else { return nil }
        
        return .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args(.mock),
            type.removingAttributes
                .unwrapped
                .tparenthesizedIfNeeded
                .withTrailingTrivia(.zero),
            modifiers: modifiers,
            attributes: attributes
        )
    }
    
    public func makeTupleArgsValForMock(counter: Counter?, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            signatureAddedIdentifier(counter: counter).args(.mock),
            TypeSyntax(TupleTypeSyntax.make(with: parameters.parameterList.makeTupleForMemberDecl())),
            modifiers: modifiers,
            attributes: attributes
        )
    }
    
    public func generateCodeBlockItemsForMock(counter: Counter?) -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !Settings.shared.mockSettings.getCapture(capture: .calledOrNot) {
            codeBlockItems.append(.makeTrueSubstitutionExpr(to: signatureAddedIdentifier(counter: counter).wasCalled(.mock)))
        }
        if !Settings.shared.mockSettings.getCapture(capture: .callCount) {
            codeBlockItems.append(.makeIncrementExpr(to: signatureAddedIdentifier(counter: counter).callCount(.mock)))
        }
        if !Settings.shared.mockSettings.getCapture(capture: .passedArgument) {
            switch parameters.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                if let singleTypeArgsExpr = makeSingleTypeArgsExprForMock(counter: counter) {
                    codeBlockItems.append(singleTypeArgsExpr)
                }
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForMock(counter: counter))
            }
        }
        return codeBlockItems
    }
    
    public func makeSingleTypeArgsExprForMock(counter: Counter?) -> CodeBlockItemSyntax? {
        guard let tokenForMockProperty = parameters.parameterList.first?.tokenForMockProperty else {
            return nil
        }
        
        return .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args(.mock),
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            tokenForMockProperty
                        )
            )
        )
    }
    
    public func makeTupleArgsExprForMock(counter: Counter?) -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            signatureAddedIdentifier(counter: counter).args(.mock),
            ExprSyntax(TupleExprSyntax.make(with: parameters.parameterList.makeTupleForCodeBlockItem()))
        )
    }
}
