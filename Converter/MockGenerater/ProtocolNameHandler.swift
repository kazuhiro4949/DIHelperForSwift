//
//  ProtocolNameHandler.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax

public class ProtocolNameHandler {
    public let node: ProtocolDeclSyntax
    public init(_ node: ProtocolDeclSyntax) {
        self.node = node
    }
    
    public var originalName: String {
        node.identifier.text
    }
    
    public func getBaseName() -> String {
        let nameFormat = Settings
            .shared
            .protocolSettings
            .nameFormat ?? "%@Protocol"
        
        let regexString = nameFormat
            .replacingOccurrences(
                of: "%@",
                with: "(.+)"
            )
        let regex = try? NSRegularExpression(
            pattern: "^\(regexString)$",
            options: []
        )
        
        let firstMatch = regex?.firstMatch(
            in: originalName,
            options: .anchored,
            range: originalName
                .nsString
                .range(of: originalName)
        )
        
        if let _firstMatch = firstMatch {
            return originalName.nsString
                .substring(with: _firstMatch.range(at: 1))
        } else {
            return originalName
        }
    }
}
