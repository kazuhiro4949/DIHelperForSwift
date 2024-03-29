//
//  FunctionParameterListSyntax+Extensions.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//
//

import Foundation
import SwiftSyntax

extension FunctionParameterListSyntax {
    public enum MockParameter {
        case none
        case singleType
        case tuple
    }
    
    public var mockParameter: MockParameter {
        if isEmpty {
            return .none
        } else if count == 1 {
            return .singleType
        } else {
            return .tuple
        }
    }
    
    public func makeTupleForMemberDecl() -> [TupleTypeElementSyntax] {
        compactMap { paramter -> TupleTypeElementSyntax? in
            guard let type = paramter.type else { return nil }
            
            return SyntaxFactory.makeTupleTypeElement(
                name: paramter.tokenForMockProperty,
                colon: paramter.colon,
                type: type.removingAttributes,
                trailingComma: paramter.trailingComma)
        }
    }
    
    public func makeTupleForCodeBlockItem() -> [TupleExprElementSyntax] {
        compactMap { paramter -> TupleExprElementSyntax? in
            return SyntaxFactory.makeTupleExprElement(
                label: nil,
                colon: nil,
                expression: ExprSyntax(
                    SyntaxFactory
                        .makeVariableExpr(paramter.tokenForMockProperty.text)
                ),
                trailingComma: paramter.trailingComma)
        }
    }
}

