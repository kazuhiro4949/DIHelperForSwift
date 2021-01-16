//
//  SourceEditorCommand.swift
//  DependencyInjectionHelperForXcodeExtension
//
//  Created by Kazuhiro Hayashi on 2021/01/10.
//

import Foundation
import XcodeKit
import SwiftSyntax
import Stencil

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

                var functionTokens = [[String: Any?]]()
                extracter.functions.forEach { (funcDeclSyntax) in
                    let identifier = funcDeclSyntax.identifier.text
//                    let parameterList = funcDeclSyntax.signature.input.parameterList.compactMap { param -> (String, [String])? in
//                        guard let type = param.type?.as(TypeSyntax.self)?.tokens.map({ $0.text }) else {
//                            return nil
//                        }
//
//                        let label: String
//                        switch (param.firstToken?.text, param.secondName?.text) {
//                        case let (firstText?, secondText?):
//                            label = "\(firstText) \(secondText)"
//                        case let (firstText?, nil):
//                            label = firstText
//                        case let (nil, secondText?):
//                            label = secondText
//                        case (nil, nil):
//                            label = ""
//                        }
//
//                        return (label, type)
//                    }
                    let inputValue = funcDeclSyntax.signature.input.description
                    let outputValue = funcDeclSyntax.signature.output?.description
                    
                    let functionToken: [String: Any?] = [
                        "identifier": identifier,
                        "params": inputValue,
                        "return": outputValue
                    ]
                    functionTokens.append(functionToken)
                }
                
                let templateText = """
                protocol {{ identifier }}Protocol {
                    {%for f in functionList %}
                    func {{ f.identifier }}{{f.params}}{{f.return}}
                    {% endfor %}
                }
                """
                let template = Template(templateString: templateText)
                let text = try? template.render([
                    "identifier" : extracter.identifier!.text,
                    "functionList": functionTokens
                ])
                print(text!)
                
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
    var functions = [FunctionDeclSyntax]()
    var variables = [MemberDeclListItemSyntax]()
    var initilizers = [MemberDeclListItemSyntax]()
    
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        keyword = node.classKeyword
        identifier = node.identifier
        functions = node.members.members.compactMap { (member) -> FunctionDeclSyntax? in
            member.decl.as(FunctionDeclSyntax.self)
        }
        variables = node.members.members.compactMap { (member) -> MemberDeclListItemSyntax? in
            if member.decl.is(VariableDeclSyntax.self) {
                return member
            } else {
                return nil
            }
        }
        initilizers = node.members.members.compactMap { (member) -> MemberDeclListItemSyntax? in
            if member.decl.is(InitializerDeclSyntax.self) {
                return member
            } else {
                return nil
            }
        }
        
        return .skipChildren
    }
    
//    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
//        keyword = node.structKeyword
//        identifier = node.identifier
//        members = node.members.members.compactMap { (member) -> MemberDeclListItemSyntax? in
//            if member.decl.is(VariableDeclSyntax.self)
//               || member.decl.is(FunctionDeclSyntax.self) {
//                return member
//            } else {
//                return nil
//            }
//        }
//
//        return .skipChildren
//    }
//
//    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
//        keyword = node.enumKeyword
//        identifier = node.identifier
//        members = node.members.members.compactMap { (member) -> MemberDeclListItemSyntax? in
//            if member.decl.is(VariableDeclSyntax.self)
//               || member.decl.is(FunctionDeclSyntax.self) {
//                return member
//            } else {
//                return nil
//            }
//        }
        
//        return .skipChildren
//    }
}
