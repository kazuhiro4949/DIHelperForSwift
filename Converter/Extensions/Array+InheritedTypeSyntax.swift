//
//  Array+InheritedTypeSyntax.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/04/03.
//  
//

import Foundation
import SwiftSyntax

extension Array where Element == InheritedTypeSyntax {
    static func nsObject(with protocolName: String) -> [InheritedTypeSyntax] {
        [
            .formattedNSObject,
            .formattedProtocol(protocolName)
        ]
    }
}
