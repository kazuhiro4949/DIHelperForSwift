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
    static func makeFormattedProtocol(mockType: MockType, handler: ProtocolNameHandler) -> TypeInheritanceClauseSyntax {
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
    
    static func make(with elements: [InheritedTypeSyntax]) -> TypeInheritanceClauseSyntax {
        SyntaxFactory.makeTypeInheritanceClause(
            colon: SyntaxFactory
                .makeColonToken()
                .withTrailingTrivia(.spaces(1)),
            inheritedTypeCollection: SyntaxFactory
                .makeInheritedTypeList(elements)
        )
    }
}

extension Array where Element == InheritedTypeSyntax {
    static var anyObject: [InheritedTypeSyntax] {
        [SyntaxFactory
            .makeInheritedType(
                typeName: SyntaxFactory
                    .makeTypeIdentifier("AnyObject"),
                trailingComma: nil
            )
        ]
    }
}
