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
    public static func makeAccessorDecl(with contextualKeywordString: String) -> AccessorDeclSyntax {
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
    
    public static func makeProtocolMemberDeclBlock(members: MemberDeclListSyntax) -> MemberDeclBlockSyntax {
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
    
    public static func makeProtocolForDependencyInjection(
        attributes: AttributeListSyntax?,
        identifier: TokenSyntax,
        inheritanceClause: TypeInheritanceClauseSyntax?,
        members: MemberDeclListSyntax) -> ProtocolDeclSyntax {
        
        SyntaxFactory.makeProtocolDecl(
            attributes: attributes?
                .protocolExclusiveRemoved,
            modifiers: nil,
            protocolKeyword: SyntaxFactory
                .makeProtocolKeyword()
                .withTrailingTrivia(.spaces(1)),
            identifier: identifier,
            inheritanceClause: inheritanceClause,
            genericWhereClause: nil,
            members: makeProtocolMemberDeclBlock(members: members))
    }
}

extension SyntaxFactory {
    public func makeIdentifier(_ text: String) -> TokenSyntax {
        SyntaxFactory
            .makeToken(.identifier(text), presence: .present)
    }
}

extension SyntaxFactory {
    public static func makeCleanFormattedLeftBrance() -> TokenSyntax {
        SyntaxFactory
            .makeLeftBraceToken()
            .withLeadingTrivia(.zero)
            .withTrailingTrivia(.newlines(1))
    }
    
    
    public static func makeCleanFormattedRightBrance() -> TokenSyntax {
        SyntaxFactory
            .makeRightBraceToken()
            .withLeadingTrivia(.zero)
            .withTrailingTrivia(.newlines(1))
    }
}
