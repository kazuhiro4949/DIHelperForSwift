//
//  GenerateProtocolCommand.swift
//  DependencyInjectionHelperForXcodeExtension
//
//  Created by Kazuhiro Hayashi on 2021/01/10.
//

import Foundation
import XcodeKit
import SwiftSyntax
import SwiftSyntaxParser
import Converter

// https://docs.swift.org/swift-book/LanguageGuide/Protocols.html
class GenerateProtocolCommand: NSObject, XCSourceEditorCommand {
    
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
                
                let extracter = ProtocolExtractor()
                extracter.walk(sourceFile)
                let generatedLines: [String] = extracter.protocolDeclSyntaxList.map { generatedProtcolDeclSyntax in
                    let leadingTrivia = generatedProtcolDeclSyntax.protocolDeclSyntax.leadingTrivia?.appending(.newlines(1)) ?? .newlines(1)
                    let newlineAppdingProtocolDecl = generatedProtcolDeclSyntax.protocolDeclSyntax.withLeadingTrivia(leadingTrivia)
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
