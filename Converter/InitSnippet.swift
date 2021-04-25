//
//  InitSnippet.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/04/25.
//  
//

import Cocoa

public struct InitSnippet: Codable {
    public init(name: String, body: String) {
        self.name = name
        self.body = body
    }
    
    public var name: String
    public var body: String
}
