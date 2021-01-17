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

            for selection in selections {
                let selectedLines = lines[selection.start.line..<selection.end.line]
                let sourceFile = try SyntaxParser.parse(source: selectedLines.joined())
                
                let extracter = ProtocolExtractor()
                extracter.walk(sourceFile)

                let varInterfaces = Array(
                    extracter
                        .variables
                        .filter(\.notHasPrivateGetterSetter)
                        .map { $0.makeInterfaces() }
                        .joined()
                )
                .map(\.toMemberDeclListItem)
                let initInterfaces = extracter.initilizers.map(\.interface).map(\.toMemberDeclListItem)
                let funcInterfaces = extracter.functions.map(\.interface).map(\.toMemberDeclListItem)
                let membersInterfaces = varInterfaces + initInterfaces + funcInterfaces
                
               let protocolDecl = SyntaxFactory.makeProtocolForDependencyInjection(
                    identifier: extracter.identifier!.makeStringLiteral(with: "Protocol"),
                    members: SyntaxFactory.makeMemberDeclList(membersInterfaces)
                )
                
                print(protocolDecl.description)
            }
        } catch let e {
            print(e)
        }

        completionHandler(nil)
    }
    
}
