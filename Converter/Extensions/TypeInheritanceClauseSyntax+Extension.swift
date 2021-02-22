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
    static func makeFormattedProtocol(_ handler: ProtocolNameHandler) -> TypeInheritanceClauseSyntax {
        SyntaxFactory.makeTypeInheritanceClause(
            colon: SyntaxFactory
                .makeColonToken()
                .withTrailingTrivia(.spaces(1)),
            inheritedTypeCollection: SyntaxFactory
                .makeInheritedTypeList(
                    [SyntaxFactory
                        .makeInheritedType(
                            typeName: SyntaxFactory
                                .makeTypeIdentifier(handler.originalName),
                            trailingComma: nil
                        )
                    ]
                )
        )
        .withTrailingTrivia(.spaces(1))
    }
}
