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
                
                let sourceFile = try SyntaxParser.parse(source: selectedLines.joined())
                
                let extracter = ProtocolExtractor(
                    selection: selection
                )
                extracter.walk(sourceFile)

                let protocolFunctionDecls = extracter.functions.map { (funcDeclSyntax) in
                    SyntaxFactory.makeFunctionDecl(
                        attributes: nil,
                        modifiers: nil,
                        funcKeyword: funcDeclSyntax.funcKeyword
                            .withLeadingTrivia(.zero)
                            .withTrailingTrivia(.spaces(1)),
                        identifier: funcDeclSyntax.identifier
                            .withTrailingTrivia(.spaces(1)),
                        genericParameterClause: nil,
                        signature: funcDeclSyntax.signature,
                        genericWhereClause: nil,
                        body: nil)
                }
                
                var variables = [VariableDeclSyntax]()
                extracter.variables.forEach { (variableDeclSyntax) in
                    if variableDeclSyntax.bindings.count == 1 {
                        let binding = variableDeclSyntax.bindings.first!
                        
                        if let accessorBlock = binding.accessor?.as(AccessorBlockSyntax.self) { // setter, getter
                            var contextualKeyword: PatternBindingSyntax.ContextualKeyword = []
                            accessorBlock.accessors.forEach { (accessor) in
                                if accessor.accessorKind.text == "get" {
                                    contextualKeyword.insert(.get)
                                } else if accessor.accessorKind.text == "set" {
                                    contextualKeyword.insert(.set)
                                }
                            }
                            let protocolVariable = binding.convertForProtocol(with: contextualKeyword)
                            variables.append(protocolVariable)
                        } else if binding.accessor?.is(CodeBlockSyntax.self) == true { // computed
                            let protocolVariable = binding.convertForProtocol(with: .get)
                            variables.append(protocolVariable)
                        } else {
                            let contextualKeyword: PatternBindingSyntax.ContextualKeyword
                            if variableDeclSyntax.letOrVarKeyword.tokenKind == .letKeyword {
                                contextualKeyword = .get
                            } else {
                                contextualKeyword = [.get, .set]
                            }
                            let protocolVariable = binding.convertForProtocol(with: contextualKeyword)
                            variables.append(protocolVariable)
                        }
                    } else {
                        // let, var
                        let contextualKeyword: PatternBindingSyntax.ContextualKeyword
                        if variableDeclSyntax.letOrVarKeyword.tokenKind == .letKeyword {
                            contextualKeyword = .get
                        } else {
                            contextualKeyword = [.get, .set]
                        }
                        
                        let reversedBinding = variableDeclSyntax.bindings.reversed()
                        var currentTypeAnnotation: TypeAnnotationSyntax?
                        let protocolVariables = reversedBinding.map { (binidng) -> VariableDeclSyntax in
                            if let typeAnnotation = binidng.typeAnnotation {
                                currentTypeAnnotation = typeAnnotation
                            }
                            
                            let bindingWithTypeAnnotation = binidng.withTypeAnnotation(currentTypeAnnotation)
                            return bindingWithTypeAnnotation.convertForProtocol(with: contextualKeyword)
                        }
                        variables.append(contentsOf: protocolVariables)
                    }
                }

                

                let meberDeclList = SyntaxFactory.makeMemberDeclList(
                    variables.map {
                        SyntaxFactory.makeMemberDeclListItem(
                            decl: DeclSyntax($0)
                                .withLeadingTrivia(.spaces(4))
                                .withTrailingTrivia(.newlines(1)),
                            semicolon: nil)
                    } +
                    protocolFunctionDecls.map {
                    SyntaxFactory.makeMemberDeclListItem(
                        decl: DeclSyntax($0)
                            .withLeadingTrivia(.spaces(4))
                            .withTrailingTrivia(.newlines(1)),
                        semicolon: nil)
                    }
                )
                
                let memberDeclBlock = SyntaxFactory.makeMemberDeclBlock(
                    leftBrace: SyntaxFactory.makeLeftBraceToken()
                        .withTrailingTrivia(.newlines(1)),
                    members: meberDeclList
                        .withTrailingTrivia(.newlines(1)),
                    rightBrace: SyntaxFactory.makeRightBraceToken())
                
                let protocolDecl = SyntaxFactory.makeProtocolDecl(
                    attributes: nil,
                    modifiers: nil,
                    protocolKeyword: SyntaxFactory.makeProtocolKeyword()
                        .withTrailingTrivia(.spaces(1)),
                    identifier: extracter.identifier!
                        .withTrailingTrivia(.spaces(1)),
                    inheritanceClause: nil, // Anyobject if class
                    genericWhereClause: nil,
                    members: memberDeclBlock)
                
                print(protocolDecl.description)
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
    var variables = [VariableDeclSyntax]()
    var initilizers = [InitializerDeclSyntax]()
    
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        keyword = node.classKeyword
        identifier = node.identifier
        functions = node.members.members.compactMap { (member) -> FunctionDeclSyntax? in
            member.decl.as(FunctionDeclSyntax.self)
        }
        variables = node.members.members.compactMap { (member) -> VariableDeclSyntax? in
            member.decl.as(VariableDeclSyntax.self)
        }
        initilizers = node.members.members.compactMap { (member) -> InitializerDeclSyntax? in
            member.decl.as(InitializerDeclSyntax.self)
        }
        
        return .skipChildren
    }
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        .visitChildren
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

extension SyntaxFactory {
    static func makeAccessorDecl(with contextualKeywordString: String) -> AccessorDeclSyntax {
        makeAccessorDecl(
            attributes: nil,
            modifier: nil,
            accessorKind: SyntaxFactory.makeToken(
                .contextualKeyword(contextualKeywordString),
                presence: .present
            ),
            parameter: nil,
            body: nil)
    }
}

extension PatternBindingSyntax {
    struct ContextualKeyword : OptionSet {
        let rawValue: UInt
        
        static let get = ContextualKeyword(rawValue: 1 << 0)
        static let set   = ContextualKeyword(rawValue: 1 << 1)
    }
    
    func convertForProtocol(with contextualKeyword: ContextualKeyword) -> VariableDeclSyntax {
        let accessorDeclSyntaxes: [AccessorDeclSyntax]
        if contextualKeyword == [.get, .set] {
            accessorDeclSyntaxes = [
                SyntaxFactory.makeAccessorDecl(with: "get")
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1)),
                SyntaxFactory.makeAccessorDecl(with: "set")
                    .withTrailingTrivia(.spaces(1))
            ]
        } else if contextualKeyword == .get {
            accessorDeclSyntaxes = [
                SyntaxFactory.makeAccessorDecl(with: "get")
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1))
            ]
        } else if contextualKeyword == .set {
            accessorDeclSyntaxes = [
                SyntaxFactory.makeAccessorDecl(with: "set")
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1))
            ]
        } else {
            accessorDeclSyntaxes = []
        }
        
        let accessorBlock = SyntaxFactory.makeAccessorBlock(
            leftBrace: SyntaxFactory.makeLeftBraceToken(),
            accessors: SyntaxFactory.makeAccessorList(accessorDeclSyntaxes),
            rightBrace: SyntaxFactory.makeRightBraceToken()
        )
        
        let patternBinding = SyntaxFactory.makePatternBinding(
            pattern: pattern,
            typeAnnotation: typeAnnotation,
            initializer: nil,
            accessor: Syntax(accessorBlock),
            trailingComma: nil)
        
        let variableDecl = SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: SyntaxFactory.makeToken(
                .varKeyword,
                presence: .present
            ),
            bindings: SyntaxFactory.makePatternBindingList([
                patternBinding
                    .withLeadingTrivia(.spaces(1))
                    .withTrailingTrivia(.spaces(1))
            ])
        )
        return variableDecl
    }
}
