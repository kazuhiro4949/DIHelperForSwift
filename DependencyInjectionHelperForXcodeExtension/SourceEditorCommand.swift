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
                        identifier: funcDeclSyntax.identifier,
                        genericParameterClause: nil,
                        signature: funcDeclSyntax.signature,
                        genericWhereClause: nil,
                        body: nil)
                }
                
                let protocolInitializerDecls = extracter.initilizers.map { (initilizerDeclSyntax) in
                    SyntaxFactory.makeInitializerDecl(
                        attributes: nil,
                        modifiers: nil,
                        initKeyword: SyntaxFactory.makeInitKeyword(
                            leadingTrivia: .zero
                        ),
                        optionalMark: initilizerDeclSyntax.optionalMark,
                        genericParameterClause: nil,
                        parameters: initilizerDeclSyntax.parameters,
                        throwsOrRethrowsKeyword: initilizerDeclSyntax.throwsOrRethrowsKeyword,
                        genericWhereClause: nil,
                        body: nil
                    )
                }
                
                var variables = [VariableDeclSyntax]()
                extracter.variables
                    .filter {
                        let hasPrivate = $0.modifiers?.contains(where: { (modifier) -> Bool in
                            modifier.name.text == "private" && modifier.detail == nil
                        }) ?? false
                        return !hasPrivate
                    }
                    .forEach { (variableDeclSyntax) in
                    if variableDeclSyntax.bindings.count == 1 {
                        let binding = variableDeclSyntax.bindings.first!
                        
                        if let accessorBlock = binding.accessor?.as(AccessorBlockSyntax.self) { // setter, getter, didSet
                            var contextualKeyword: PatternBindingSyntax.ContextualKeyword = []
                            accessorBlock.accessors.forEach { (accessor) in
                                if accessor.accessorKind.text == "get" {
                                    contextualKeyword.insert(.get)
                                } else if accessor.accessorKind.text == "set" {
                                    contextualKeyword.insert(.set)
                                }
                            }
                            
                            let hasPrivateSetter = variableDeclSyntax.modifiers?.contains(where: { (modifier) -> Bool in
                                modifier.name.text == "private" && modifier.detail?.text == "set"
                            }) ?? false
                            if hasPrivateSetter {
                                contextualKeyword.remove(.set)
                            }
                            
                            let protocolVariable = binding.convertForProtocol(with: contextualKeyword)
                            variables.append(protocolVariable)
                        } else if binding.accessor?.is(CodeBlockSyntax.self) == true { // computed
                            let protocolVariable = binding.convertForProtocol(with: .get)
                            variables.append(protocolVariable)
                        } else {
                            let hasPrivateSetter = variableDeclSyntax.modifiers?.contains(where: { (modifier) -> Bool in
                                modifier.name.text == "private" && modifier.detail?.text == "set"
                            }) ?? false
                            
                            let contextualKeyword: PatternBindingSyntax.ContextualKeyword
                            if variableDeclSyntax.letOrVarKeyword.tokenKind == .letKeyword || hasPrivateSetter {
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
                    protocolInitializerDecls.map {
                        SyntaxFactory.makeMemberDeclListItem(
                            decl: DeclSyntax($0)
                                .withLeadingTrivia(.spaces(4))
                                .withTrailingTrivia(.newlines(1)),
                            semicolon: nil
                        )
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
                    leftBrace: SyntaxFactory.makeLeftBraceToken(
                        leadingTrivia: .zero,
                        trailingTrivia: .newlines(1)
                    ),
                    members: meberDeclList
                        .withTrailingTrivia(.newlines(1)),
                    rightBrace: SyntaxFactory.makeRightBraceToken()
                )
                
                
                let protocolIdentifier = extracter
                    .identifier!
                    .withKind(.stringLiteral(extracter.identifier!.text + "Protocol"))
                let protocolDecl = SyntaxFactory.makeProtocolDecl(
                    attributes: nil,
                    modifiers: nil,
                    protocolKeyword: SyntaxFactory
                        .makeProtocolKeyword()
                        .withTrailingTrivia(.spaces(1)),
                    identifier: protocolIdentifier
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
        guard node.hasGenerics() else {
            return .skipChildren
        }
        
        keyword = node.classKeyword
        identifier = node.identifier
        functions = node.members.members.compactMap { (member) -> FunctionDeclSyntax? in
            guard let functionDecl = member.decl.as(FunctionDeclSyntax.self) else {
                return nil
            }
            
            if functionDecl.hasGenerics() {
                return nil
            }
            
            let hasPrivate = functionDecl.modifiers?.contains(where: {
                $0.name.text == "private"
            }) ?? false
            
            if hasPrivate {
                return nil
            }
            
            return functionDecl
        }
        variables = node.members.members.compactMap { (member) -> VariableDeclSyntax? in
            member.decl.as(VariableDeclSyntax.self)
        }
        initilizers = node.members.members.compactMap { (member) -> InitializerDeclSyntax? in
            guard let initializerDecl = member.decl.as(InitializerDeclSyntax.self) else {
                return nil
            }
            
            if initializerDecl.genericParameterClause != nil {
                return nil
            }
            
            let hasPrivate = initializerDecl.modifiers?.contains(where: {
                $0.name.text == "private"
            }) ?? false
            
            if hasPrivate {
                return nil
            }
            
            return initializerDecl
        }
        
        return .skipChildren
    }
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        .visitChildren
    }
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        guard node.hasGenerics() else {
            return .skipChildren
        }
        
        keyword = node.structKeyword
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

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        guard node.hasGenerics() else {
            return .skipChildren
        }
        
        keyword = node.enumKeyword
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


protocol HasGenericParameterClause {
    var genericParameterClause: GenericParameterClauseSyntax? { get }
}

extension HasGenericParameterClause {
    func hasGenerics() -> Bool {
        genericParameterClause != nil
    }
}

protocol HasGenericParameter {
    var genericParameters: GenericParameterClauseSyntax? { get }
}

extension HasGenericParameter {
    func hasGenerics() -> Bool {
        genericParameters != nil
    }
}

extension ClassDeclSyntax: HasGenericParameterClause {}
extension StructDeclSyntax: HasGenericParameterClause {}
extension EnumDeclSyntax: HasGenericParameter {}
extension FunctionDeclSyntax: HasGenericParameterClause {}
extension InitializerDeclSyntax: HasGenericParameterClause {}
