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
    enum MockParameter {
        case none
        case singleType
        case tuple
    }
    
    var mockParameter: MockParameter {
        if isEmpty {
            return .none
        } else if count == 1 {
            return .singleType
        } else {
            return .tuple
        }
    }
    
    func makeTupleForMemberDecl() -> [TupleTypeElementSyntax] {
        compactMap { paramter -> TupleTypeElementSyntax? in
            return SyntaxFactory.makeTupleTypeElement(
                name: paramter.tokenForMockProperty,
                colon: paramter.colon,
                type: paramter.type!,
                trailingComma: paramter.trailingComma)
        }
    }
    
    func makeTupleForCodeBlockItem() -> [TupleExprElementSyntax] {
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

