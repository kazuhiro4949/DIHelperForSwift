//
//  ProtocolExtractor.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

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
