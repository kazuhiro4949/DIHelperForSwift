//
//  SourceEditorCommand.swift
//  DependencyInjectionHelperForXcodeExtension
//
//  Created by Kazuhiro Hayashi on 2021/01/10.
//

import Foundation
import XcodeKit
import SwiftSyntax

// https://docs.swift.org/swift-book/LanguageGuide/Protocols.html
class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
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
            
            let sourceFileText = lines.joined()
            let sourceFile = try SyntaxParser.parse(
                source: sourceFileText
            )
            
            for selection in selections {
                _ = ProtocolExtractor(
                    selection: selection
                )
                .visit(sourceFile)
                // replace slection range
            }
            
   
            
        } catch let e {
            print(e)
        }

        completionHandler(nil)
    }
    
}



class ProtocolExtractor: SyntaxVisitor {
    let selection: XCSourceTextRange
    init(selection: XCSourceTextRange) {
        self.selection = selection
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        .visitChildren
    }
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        .visitChildren
    }
}
