//
//  FunctionParameterSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

extension FunctionParameterSyntax {
    var tokenForMockProperty: TokenSyntax {
        if let secondName = secondName {
            return secondName
        } else if let firstName = firstName {
            return firstName
        } else {
            return SyntaxFactory.makeIdentifier("")
        }
    }

    var signatureStringForMockProperty: TokenSyntax {
        if let secondName = secondName, secondName.text != "_" {
            return secondName
        } else if let firstName = firstName, firstName.text != "_" {
            return firstName
        } else {
            return SyntaxFactory.makeIdentifier("")
        }
    }
}

