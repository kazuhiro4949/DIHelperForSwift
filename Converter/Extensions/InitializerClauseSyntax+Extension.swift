//
//  InitializerClauseSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension InitializerClauseSyntax {
    public static func makeFormatted(_ valueExpr: ExprSyntax?) -> InitializerClauseSyntax? {
        valueExpr.flatMap {
            SyntaxFactory.makeInitializerClause(
                equal: .makeFormattedEqual(),
                value: $0)
        }
    }

    public static func makeInitialiizer(
        for mockType: MockType,
        identifier: TokenSyntax,
        binding: PatternBindingSyntax) -> InitializerClauseSyntax? {
        switch mockType {
        case .mock:
            return nil
        case .dummy:
            return nil
        case .stub:
            guard let typeAnnotation = binding.typeAnnotation else { return nil }
            
            return .makeFormatted(
                ExprSyntax.makeReturnedValForMock(identifier.text, typeAnnotation.type)
            )
        }
    }
}
