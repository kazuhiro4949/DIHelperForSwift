//
//  GenerateMockCommand.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/27.
//  
//

import Foundation
import XcodeKit
import SwiftSyntax
import SwiftSyntaxParser
import Converter

// [Test Mock](http://xunitpatterns.com/Test%20Mock.html)
class GenerateMockCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        do {
            let buffer = invocation.buffer
            guard let selections = buffer.selections as? [XCSourceTextRange] else {
                completionHandler(nil)
                return
            }
            
            guard let lines = buffer.lines as? [String] else {
                completionHandler(nil)
                return
            }

            for selection in selections {
                let selectedLines = lines[selection.start.line..<selection.end.line]
                let sourceFile = try SyntaxParser.parse(source: selectedLines.joined())
                
                let generater = MockGenerater(mockType: .mock)
                generater.walk(sourceFile)
                
                let generatedLines: [String] = generater.mockClasses.map { mockDecl in
                    let leadingTrivia = mockDecl.classDeclSyntax.leadingTrivia?.appending(.newlines(1)) ?? .newlines(1)
                    let newlineAppdingProtocolDecl = mockDecl.classDeclSyntax.withLeadingTrivia(leadingTrivia)
                    return mockDecl.prefixComment + newlineAppdingProtocolDecl.description
                }
                
                buffer.lines.addObjects(from: generatedLines)
            }
        } catch let e {
            print(e)
        }

        completionHandler(nil)
    }
    
}
