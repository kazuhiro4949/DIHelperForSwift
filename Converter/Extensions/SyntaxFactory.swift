//
//  SyntaxFactory.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

extension SyntaxFactory {
    static func makeAccessorDecl(with contextualKeywordString: String) -> AccessorDeclSyntax {
        makeAccessorDecl(
            attributes: nil,
            modifier: nil,
            accessorKind: SyntaxFactory.makeToken(
                .contextualKeyword(contextualKeywordString),
                presence: .present
            ),
            parameter: nil,
            body: nil)
    }
    
    static func makeProtocolMemberDeclBlock(members: MemberDeclListSyntax) -> MemberDeclBlockSyntax {
        SyntaxFactory.makeMemberDeclBlock(
            leftBrace: SyntaxFactory.makeLeftBraceToken(
                leadingTrivia: .zero,
                trailingTrivia: .newlines(1)
            ),
            members: members
                .withTrailingTrivia(.newlines(1)),
            rightBrace: SyntaxFactory.makeRightBraceToken()
        )
    }
    
    static func makeProtocolForDependencyInjection(
        identifier: TokenSyntax,
        members: MemberDeclListSyntax) -> ProtocolDeclSyntax {
        
        SyntaxFactory.makeProtocolDecl(
            attributes: nil,
            modifiers: nil,
            protocolKeyword: SyntaxFactory
                .makeProtocolKeyword()
                .withTrailingTrivia(.spaces(1)),
            identifier: identifier
                .withTrailingTrivia(.spaces(1)),
            inheritanceClause: nil, // Anyobject if class
            genericWhereClause: nil,
            members: makeProtocolMemberDeclBlock(members: members))
    }
}

extension SyntaxFactory {
    func makeIdentifier(_ text: String) -> TokenSyntax {
        SyntaxFactory
            .makeToken(.identifier(text), presence: .present)
    }
}

extension SyntaxFactory {
    static func makeCleanFormattedLeftBrance() -> TokenSyntax {
        SyntaxFactory
            .makeLeftBraceToken()
            .withLeadingTrivia(.zero)
            .withTrailingTrivia(.newlines(1))
    }
    
    
    static func makeCleanFormattedRightBrance() -> TokenSyntax {
        SyntaxFactory
            .makeRightBraceToken()
            .withLeadingTrivia(.zero)
            .withTrailingTrivia(.newlines(1))
    }
}
