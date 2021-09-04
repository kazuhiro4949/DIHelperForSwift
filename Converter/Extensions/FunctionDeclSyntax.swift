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
    public var interface: FunctionDeclSyntax? {
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
            attributes: attributes?
                .protocolExclusiveRemoved?
                .withTrailingTrivia(.newlineAndIndent),
            modifiers: modifiers?.protocolEnabled,
            funcKeyword: funcKeyword
                .withLeadingTrivia(.zero)
                .withTrailingTrivia(.spaces(1)),
            identifier: identifier,
            genericParameterClause: nil,
            signature: signature.withInput(withoutDefaultArgs),
            genericWhereClause: nil,
            body: nil)
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

extension FunctionDeclSyntax {
    public func generateCodeBlockItemsForMock(counter: Counter?) -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !Settings.shared.mockSettings.getCapture(capture: .calledOrNot) {
            codeBlockItems.append(.makeTrueSubstitutionExpr(to: identifier.signatureAddedIdentifier(counter: counter).wasCalled(.mock)))
        }
        if !Settings.shared.mockSettings.getCapture(capture: .callCount) {
            codeBlockItems.append(.makeIncrementExpr(to: identifier.signatureAddedIdentifier(counter: counter).callCount(.mock)))
        }
        if !Settings.shared.mockSettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                if let codeBlock = makeSingleTypeArgsExprForMock(counter: counter) {
                    codeBlockItems.append(codeBlock)
                }
            case .tuple:
                codeBlockItems.append(makeTupleArgsExprForMock(counter: counter))
            }
        }
        if !signature.isReturnedVoid {
            codeBlockItems.append(.makeReturnExpr(identifier.signatureAddedIdentifier(counter: counter).val(.mock), .indent(2)))
        }
        return codeBlockItems
    }
    
    public func generateCodeBlockItemsForStub(counter: Counter?) -> [CodeBlockItemSyntax] {
        var codeBlockItems = [CodeBlockItemSyntax]()
        if !signature.isReturnedVoid {
            codeBlockItems.append(.makeReturnExpr(identifier.signatureAddedIdentifier(counter: counter).val(.mock), .indent(2)))
        }
        return codeBlockItems
    }
    
    public func generateMemberDeclItemsForMock(mockType: MockType) -> [MemberDeclListItemSyntax] {
        switch mockType {
        case .mock:
            FunctionSignatureDuplication.shared.list[identifier.text]?.count += 1
            return generateMemberDeclItemsFormMock(
                counter: FunctionSignatureDuplication
                    .shared
                    .list[identifier.text],
                modifiers: modifiers,
                attributes: attributes)
        case .dummy:
            return generateMemberDeclItemsFormDummy()
        case .stub:
            FunctionSignatureDuplication.shared.list[identifier.text]?.count += 1
            return generateMemberDeclItemsFormStub(counter: FunctionSignatureDuplication.shared.list[identifier.text])
        }
    }
    
    public func generateMemberDeclItemsFormMock(counter: Counter?, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if !Settings.shared.mockSettings.getCapture(capture: .calledOrNot) {
            memberDeclListItems.append(
                .makeCalledOrNot(
                    identifier: identifier.signatureAddedIdentifier(counter: counter).wasCalled(.mock),
                    modifiers: modifiers,
                    attributes: attributes)
            )
        }
        if !Settings.shared.mockSettings.getCapture(capture: .callCount) {
            memberDeclListItems.append(
                .makeFormattedCallCount(
                    identifier: identifier
                        .signatureAddedIdentifier(counter: counter).callCount(.mock),
                    attributes: attributes,
                    modifiers: modifiers
                )
            )
        }
        if !Settings.shared.mockSettings.getCapture(capture: .passedArgument) {
            switch signature.input.parameterList.mockParameter {
            case .none:
                break
            case .singleType:
                if let singleTypeArgs = makeSingleTypeArgsValForMock(counter: counter) {
                    memberDeclListItems.append(singleTypeArgs)
                }
            case .tuple:
                memberDeclListItems.append(makeTupleArgsValForMock(
                                            counter: counter,
                                            modifiers: modifiers,
                                            attributes: attributes)
                )
            }
        }
        if let output = signature.output, !signature.isReturnedVoid {
            memberDeclListItems.append(
                .makeReturnedValForMock(
                    identifier.signatureAddedIdentifier(counter: counter).val(.mock),
                    output.returnType,
                    modifiers: modifiers,
                    attributes: attributes
                )
            )
        }
        let codeBlockItems = generateCodeBlockItemsForMock(counter: counter)
        memberDeclListItems.append(.makeFunctionForMock(self, codeBlockItems))
        return memberDeclListItems
    }
    
    public func generateMemberDeclItemsFormDummy() -> [MemberDeclListItemSyntax] {
        if let output = signature.output {
            return [
                .makeFunctionForMock(
                    self,
                    [.makeReturnForDummy(
                        identifier: identifier.signatureAddedIdentifier().val(.stub),
                        typeSyntax: output.returnType)
                    ]
                )
            ]
        } else {
            return [.makeFunctionForMock(self, [])]
        }
    }
    
    public func generateMemberDeclItemsFormStub(counter: Counter?) -> [MemberDeclListItemSyntax] {
        var memberDeclListItems = [MemberDeclListItemSyntax]()
        if let output = signature.output, !signature.isReturnedVoid {
            memberDeclListItems.append(.makeReturnedValForMock(identifier.signatureAddedIdentifier(counter: counter).val(.stub), output.returnType, modifiers: modifiers, attributes: attributes))
        }
        let codeBlockItems = generateCodeBlockItemsForStub(counter: counter)
        memberDeclListItems.append(.makeFunctionForMock(self, codeBlockItems))
        return memberDeclListItems
    }
    
    public func makeSingleTypeArgsValForMock(counter: Counter?) -> MemberDeclListItemSyntax? {
        guard let type = signature.input.parameterList.first?
            .type else {
            return nil
        }
        
        return .makeArgsValForMock(
            identifier.signatureAddedIdentifier(counter: counter).args(.mock),
            type.removingAttributes
                .unwrapped
                .tparenthesizedIfNeeded
                .withTrailingTrivia(.zero),
            modifiers: modifiers,
            attributes: attributes?.storedPropertyRemoved
        )
    }
    
    public func makeSingleTypeArgsExprForMock(counter: Counter?) -> CodeBlockItemSyntax? {
        guard let parameter = signature.input.parameterList.first else {
            return nil
        }
        
        return .makeArgsExprForMock(
            identifier.signatureAddedIdentifier(counter: counter).args(.mock),
            ExprSyntax(IdentifierExprSyntax
                        .makeFormattedVariableExpr(
                            parameter.tokenForMockProperty
                        )
            )
        )
    }
    
    public func makeTupleArgsValForMock(counter: Counter?, modifiers: ModifierListSyntax?, attributes: AttributeListSyntax?) -> MemberDeclListItemSyntax {
        .makeArgsValForMock(
            identifier.signatureAddedIdentifier(counter: counter).args(.mock),
            TypeSyntax(TupleTypeSyntax.make(with: signature.input.parameterList.makeTupleForMemberDecl())),
            modifiers: modifiers,
            attributes: attributes?.storedPropertyRemoved
        )
    }
    
    public func makeTupleArgsExprForMock(counter: Counter?) -> CodeBlockItemSyntax {
        .makeArgsExprForMock(
            identifier.signatureAddedIdentifier(counter: counter).args(.mock),
            ExprSyntax(TupleExprSyntax.make(with: signature.input.parameterList.makeTupleForCodeBlockItem()))
        )
    }
}
