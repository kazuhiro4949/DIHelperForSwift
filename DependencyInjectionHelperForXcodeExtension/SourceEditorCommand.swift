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

class ProtocolExtractor: SyntaxVisitor {
    
    var protocolDeclSyntaxes = [ProtocolDeclSyntax]()
    
    var keyword: TokenSyntax?
    var identifier: TokenSyntax?
    var functions = [FunctionDeclSyntax]()
    var variables = [VariableDeclSyntax]()
    var initilizers = [InitializerDeclSyntax]()
    
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        guard !node.hasGenerics() else {
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
        guard !node.hasGenerics() else {
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
        guard !node.hasGenerics() else {
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
    
    static func makeProtocolMemberDeclBlock(members: MemberDeclListSyntax) -> MemberDeclBlockSyntax {
        SyntaxFactory.makeMemberDeclBlock(
            leftBrace: SyntaxFactory.makeLeftBraceToken(
                leadingTrivia: .zero,
                trailingTrivia: .newlines(1)
            ),
            members: members
                .withTrailingTrivia(.newlines(1)),
            rightBrace: SyntaxFactory.makeRightBraceToken()
        )
    }
    
    static func makeProtocolForDependencyInjection(
        identifier: TokenSyntax,
        members: MemberDeclListSyntax) -> ProtocolDeclSyntax {
        
        SyntaxFactory.makeProtocolDecl(
            attributes: nil,
            modifiers: nil,
            protocolKeyword: SyntaxFactory
                .makeProtocolKeyword()
                .withTrailingTrivia(.spaces(1)),
            identifier: identifier
                .withTrailingTrivia(.spaces(1)),
            inheritanceClause: nil, // Anyobject if class
            genericWhereClause: nil,
            members: makeProtocolMemberDeclBlock(members: members))
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

// MARK:-

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

// MARK:-

extension VariableDeclSyntax {
    var toMemberDeclListItem: MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(self)
                .withLeadingTrivia(.spaces(4))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}

extension FunctionDeclSyntax {
    var interface: FunctionDeclSyntax {
        SyntaxFactory.makeFunctionDecl(
            attributes: nil,
            modifiers: nil,
            funcKeyword: funcKeyword
                .withLeadingTrivia(.zero)
                .withTrailingTrivia(.spaces(1)),
            identifier: identifier,
            genericParameterClause: nil,
            signature: signature,
            genericWhereClause: nil,
            body: nil)
    }
    
    var toMemberDeclListItem: MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(self)
                .withLeadingTrivia(.spaces(4))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}

extension InitializerDeclSyntax {
    var interface: InitializerDeclSyntax {
        SyntaxFactory.makeInitializerDecl(
            attributes: nil,
            modifiers: nil,
            initKeyword: SyntaxFactory.makeInitKeyword(
                leadingTrivia: .zero
            ),
            optionalMark: optionalMark,
            genericParameterClause: nil,
            parameters: parameters,
            throwsOrRethrowsKeyword: throwsOrRethrowsKeyword,
            genericWhereClause: nil,
            body: nil
        )
    }
    
    var toMemberDeclListItem: MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(self)
                .withLeadingTrivia(.spaces(4))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}


// MARK:-
extension TokenSyntax {
    func makeStringLiteral(with suffixText: String) -> TokenSyntax {
        return withKind(.stringLiteral(text + suffixText))
    }
}


// MARK:-
extension VariableDeclSyntax {
    func makeInterfaces() -> [VariableDeclSyntax] {
        if hasMultipleProps {
            // comma separated stored properties
            return makeInterfacesFromBindings()
        }
        
        guard let binding = bindings.first else {
            return []
        }
        
        if let accessorBlock = binding.accessor?.as(AccessorBlockSyntax.self),
           accessorBlock.hasGetter {
            // getter or getter,setter
            let keywordsFromAccessor = accessorBlock.contextualKeywords
            let keywordsFromVariable = contextualKeywords
            let protocolVariable = binding.convertForProtocol(
                with: keywordsFromAccessor.intersection(keywordsFromVariable)
            )
            return [protocolVariable]
        } else if isComputedProperty {
            // computed property
            return [binding.convertForProtocol(with: .get)]
        } else {
            // stored property
            return makeInterfacesFromBindings()
        }
    }
    
    func makeInterfacesFromBindings() -> [VariableDeclSyntax] {
        makeTypeAnnotatedBindings()
            .map {
                $0.convertForProtocol(with: contextualKeywords)
            }
    }
    
    func makeTypeAnnotatedBindings() -> [PatternBindingSyntax] {
        typealias ReducedResult = (syntaxList: [PatternBindingSyntax], curreontTypeAnno: TypeAnnotationSyntax?)
        return bindings.reversed().reduce(ReducedResult([], nil)) { (result, binding) in
            let typeAnnotation = binding.typeAnnotation ?? result.curreontTypeAnno
            let bindingWithTypeAnnotation = binding.withTypeAnnotation(typeAnnotation)
            return (result.syntaxList + [bindingWithTypeAnnotation], typeAnnotation)
        }
        .syntaxList
    }
    
    var contextualKeywords: PatternBindingSyntax.ContextualKeyword {
        if letOrVarKeyword.tokenKind == .letKeyword || hasPrivateSetter {
            return .get
        } else {
            return [.get, .set]
        }
    }
    
    var hasMultipleProps: Bool {
        bindings.count != 1
    }
    
    var hasPrivateGetterSetter: Bool {
        modifiers?.contains(where: { (modifier) -> Bool in
            modifier.name.text == "private" && modifier.detail == nil
        }) ?? false
    }
    
    var hasPrivateSetter: Bool {
        modifiers?.contains(where: { (modifier) -> Bool in
            modifier.name.text == "private" && modifier.detail?.text == "set"
        }) ?? false
    }
    
    var notHasPrivateGetterSetter: Bool {
        !hasPrivateGetterSetter
    }
    
    var isComputedProperty: Bool {
        guard bindings.count == 1 else {
            return false
        }
        
        let binding = bindings.first!
        
        return binding.accessor?.is(CodeBlockSyntax.self) == true
    }
}

extension AccessorBlockSyntax {
    var hasGetter: Bool {
        accessors.contains {
            $0.accessorKind.text == "get"
        }
    }
    
    var contextualKeywords: PatternBindingSyntax.ContextualKeyword {
        accessors.reduce(into: PatternBindingSyntax.ContextualKeyword()) { (result, accessor) in
            if accessor.accessorKind.text == "get" {
                result.insert(.get)
            } else if accessor.accessorKind.text == "set" {
                result.insert(.set)
            }
        }
    }
}
