//
//  MockGenerater.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/27.
//  
//

import Foundation
import SwiftSyntax

enum MockType {
    case stub
    
    var format: String {
        switch self {
        case .stub:
            return "%@Stub"
        }
    }
}

class MockGenerater: SyntaxVisitor {
    internal init(mockType: MockType) {
        self.mockType = mockType
    }
    
    let mockType: MockType
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let nameFormat = Settings.shared.protocolSettings.nameFormat
        let regexString = nameFormat.replacingOccurrences(of: "%@", with: "(.+)")
        let regex = try? NSRegularExpression(pattern: "^\(regexString)$", options: [])
        let protocolName = node.identifier.text
        
        
        guard let match = regex?.firstMatch(in: protocolName, options: .anchored, range: protocolName.nsString.range(of: protocolName)) else {
            return .skipChildren
        }
        
        let baseName = protocolName.nsString.substring(with: match.range(at: 1))
        let title = String(format: mockType.format, baseName)
        
        let identifier = SyntaxFactory
            .makeToken(.identifier(title), presence: .present)
        
        let decls = node.members.members.compactMap { (item) -> MemberDeclListItemSyntax? in
            if let funcDeclSyntax = item.decl.as(FunctionDeclSyntax.self) {
                
                let indentationTrivia = funcDeclSyntax.leadingTrivia?.first(where: { (piece) -> Bool in
                    if case .spaces = piece {
                        return true
                    } else {
                        return false
                    }
                }) ?? .spaces(0)
                
                

                let block = SyntaxFactory.makeCodeBlock(
                    leftBrace: SyntaxFactory.makeLeftBraceToken(
                        leadingTrivia: .spaces(1),
                        trailingTrivia: [.spaces(1), .newlines(1)]
                    ),
                    statements: SyntaxFactory.makeCodeBlockItemList([CodeBlockItemSyntax]()),
                    rightBrace: SyntaxFactory.makeRightBraceToken(
                        leadingTrivia: Trivia(pieces: [indentationTrivia]),
                        trailingTrivia: .newlines(1)
                    )
                )
                
                let declSyntax = DeclSyntax(funcDeclSyntax.withBody(block))
                
                return SyntaxFactory
                    .makeMemberDeclListItem(
                        decl: declSyntax,
                        semicolon: nil
                    )
            } else {
                return nil
            }
        }
        
        let mockClassDecl = SyntaxFactory.makeClassDecl(
            attributes: nil,
            modifiers: nil,//ModifierListSyntax?,
            classKeyword: SyntaxFactory
                .makeClassKeyword(
                    leadingTrivia: .zero,
                    trailingTrivia: .spaces(1)
                ),
            identifier: identifier,
            genericParameterClause: nil,
            inheritanceClause: SyntaxFactory.makeTypeInheritanceClause(
                colon: SyntaxFactory
                    .makeColonToken()
                    .withTrailingTrivia(.spaces(1)),
                inheritedTypeCollection: SyntaxFactory
                    .makeInheritedTypeList(
                        [SyntaxFactory
                            .makeInheritedType(
                                typeName: SyntaxFactory.makeTypeIdentifier(protocolName), trailingComma: nil)]
                    )
            )
            .withTrailingTrivia(.spaces(1)),
            genericWhereClause: nil,
            members: SyntaxFactory.makeMemberDeclBlock(
                leftBrace: SyntaxFactory
                    .makeLeftBraceToken()
                    .withTrailingTrivia(.newlines(1)),
                members: SyntaxFactory
                    .makeMemberDeclList(decls)
                    .withTrailingTrivia(.newlines(1)),
                rightBrace: SyntaxFactory
                    .makeRightBraceToken()
                    .withTrailingTrivia(.newlines(1))
            )
        )

        
        print(mockClassDecl.description)
        
        return .skipChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        dump(node)
        return .skipChildren
    }
}

extension String {
    var nsString: NSString {
        self as NSString
    }
}
