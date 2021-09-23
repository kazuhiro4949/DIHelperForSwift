//
//  TypeInheritanceClauseSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension TypeInheritanceClauseSyntax {
    public static func makeFormattedProtocol(mockType: MockType, handler: ProtocolNameHandler) -> TypeInheritanceClauseSyntax {
        let inheritedTypes: [InheritedTypeSyntax]
        if mockType.supportingKVC {
            inheritedTypes = .nsObject(with: handler.originalName)
        } else {
            inheritedTypes = [.formattedProtocol(handler.originalName)]
        }
        
        return SyntaxFactory.makeTypeInheritanceClause(
            colon: SyntaxFactory
                .makeColonToken()
                .withTrailingTrivia(.spaces(1)),
            inheritedTypeCollection:
                SyntaxFactory
                .makeInheritedTypeList(inheritedTypes)
        )
        .withTrailingTrivia(.spaces(1))
    }
    
    public static func make(with elements: [InheritedTypeSyntax]) -> TypeInheritanceClauseSyntax {
        SyntaxFactory.makeTypeInheritanceClause(
            colon: SyntaxFactory
                .makeColonToken()
                .withTrailingTrivia(.spaces(1)),
            inheritedTypeCollection: SyntaxFactory
                .makeInheritedTypeList(elements)
        )
    }
}

// MARK: - make inheritance for class and actor protocol

extension TypeInheritanceClauseSyntax {
    public static func makeProtocol(for decl: ClassDeclSyntax) -> TypeInheritanceClauseSyntax {
        if decl.isClass {
            return .make(with: .anyObject)
        } else if decl.isActor {
            return .make(with: .actorProtocol)
        } else {
            return .make(with: [])
        }
    }
}

// MARK: - for class keyword type

extension Array where Element == InheritedTypeSyntax {
    public static var anyObject: [InheritedTypeSyntax] {
        [SyntaxFactory
            .makeInheritedType(
                typeName: SyntaxFactory
                    .makeTypeIdentifier("AnyObject"),
                trailingComma: nil
            )
        ]
    }
}

// MARK: - for actor keyword type

extension Array where Element == InheritedTypeSyntax {
    public static var actorProtocol: [InheritedTypeSyntax] {
        [SyntaxFactory
            .makeInheritedType(
                typeName: SyntaxFactory
                    .makeTypeIdentifier("Actor"),
                trailingComma: nil
            )
        ]
    }
}
