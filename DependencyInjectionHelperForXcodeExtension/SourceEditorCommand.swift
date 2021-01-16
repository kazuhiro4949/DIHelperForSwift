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
                // SwiftSyntax
                
                let sourceFile = try SyntaxParser.parse(source: selectedLines.joined())
                
                let extracter = ProtocolExtractor(
                    selection: selection
                )
                extracter.walk(sourceFile)
                dump(extracter.keyword)
                dump(extracter.members)
                dump(extracter.identifier)
                
                // make protocol
                // wirte buffer first line ater import
                
//                let incremented = AddPublicToKeywords().visit(sourceFile)
//
//                let incrementedLines = incremented.description.lines
//
//                let selectedRange = NSRange(
//                    location: selection.start.line,
//                    length: selection.end.line - selection.start.line
//                )
//                buffer.lines.replaceObjects(
//                    in: selectedRange,
//                    withObjectsFrom: incrementedLines
//                )
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
    
    var keyword: TokenSyntax?
    var identifier: TokenSyntax?
    var members = [MemberDeclListItemSyntax]()
    
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        keyword = node.classKeyword
        identifier = node.identifier
        members = node.members.members.compactMap { (member) -> MemberDeclListItemSyntax? in
            if member.decl.is(VariableDeclSyntax.self)
               || member.decl.is(FunctionDeclSyntax.self) {
                return member
            } else {
                return nil
            }
        }
        
        return .skipChildren
    }
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        keyword = node.structKeyword
        identifier = node.identifier
        members = node.members.members.compactMap { (member) -> MemberDeclListItemSyntax? in
            if member.decl.is(VariableDeclSyntax.self)
               || member.decl.is(FunctionDeclSyntax.self) {
                return member
            } else {
                return nil
            }
        }
        
        return .skipChildren
    }
    
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        keyword = node.enumKeyword
        identifier = node.identifier
        members = node.members.members.compactMap { (member) -> MemberDeclListItemSyntax? in
            if member.decl.is(VariableDeclSyntax.self)
               || member.decl.is(FunctionDeclSyntax.self) {
                return member
            } else {
                return nil
            }
        }
        
        return .skipChildren
    }
}

class TargetDecl {
    init(decl: DeclSyntaxProtocol) {
        self.decl = decl
    }
    
    let decl: DeclSyntaxProtocol
}
