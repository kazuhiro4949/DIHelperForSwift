//
//  GenerateStubCommand.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/11.
//  
//

import Foundation
import XcodeKit
import SwiftSyntax

// https://docs.swift.org/swift-book/LanguageGuide/Protocols.html
class GenerateStubCommand: NSObject, XCSourceEditorCommand {
    
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
                
                let generater = MockGenerater(mockType: .stub)
                generater.walk(sourceFile)
                
                let generatedLines: [String] = generater.mockClasses.map {
                    let leadingTrivia = $0.leadingTrivia?.appending(.newlines(1)) ?? .newlines(1)
                    let newlineAppdingProtocolDecl = $0.withLeadingTrivia(leadingTrivia)
                    return newlineAppdingProtocolDecl.description
                }
                
                buffer.lines.addObjects(from: generatedLines)
            }
        } catch let e {
            print(e)
        }

        completionHandler(nil)
    }
    
}
