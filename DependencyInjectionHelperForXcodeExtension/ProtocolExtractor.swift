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
    
    var protocolDeclSyntaxList = [ProtocolDeclSyntax]()
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        guard !node.hasGenerics() else {
            return .skipChildren
        }
        
        let functions = node.members.members.compactMap { (member) -> FunctionDeclSyntax? in
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
        let variables = node.members.members.compactMap { (member) -> VariableDeclSyntax? in
            member.decl.as(VariableDeclSyntax.self)
        }
        let initilizers = node.members.members.compactMap { (member) -> InitializerDeclSyntax? in
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
        
        protocolDeclSyntaxList.append(
            makeProtocolDecl(identifier: node.identifier,
                             varDecls: variables,
                             funcDelcs: functions,
                             initDecls: initilizers,
                             isClass: true)
        )
        
        return .skipChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        guard !node.hasGenerics() else {
            return .skipChildren
        }
        
        let functions = node.members.members.compactMap { (member) -> FunctionDeclSyntax? in
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
        let variables = node.members.members.compactMap { (member) -> VariableDeclSyntax? in
            member.decl.as(VariableDeclSyntax.self)
        }
        let initilizers = node.members.members.compactMap { (member) -> InitializerDeclSyntax? in
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
        
        protocolDeclSyntaxList.append(
            makeProtocolDecl(identifier: node.identifier,
                             varDecls: variables,
                             funcDelcs: functions,
                             initDecls: initilizers,
                             isClass: true)
        )
        
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        guard !node.hasGenerics() else {
            return .skipChildren
        }
        
        let functions = node.members.members.compactMap { (member) -> FunctionDeclSyntax? in
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
        let variables = node.members.members.compactMap { (member) -> VariableDeclSyntax? in
            member.decl.as(VariableDeclSyntax.self)
        }
        let initilizers = node.members.members.compactMap { (member) -> InitializerDeclSyntax? in
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
        
        protocolDeclSyntaxList.append(
            makeProtocolDecl(identifier: node.identifier,
                             varDecls: variables,
                             funcDelcs: functions,
                             initDecls: initilizers,
                             isClass: true)
        )
        
        return .skipChildren
    }
    
    private func makeProtocolDecl(
        identifier: TokenSyntax,
        varDecls: [VariableDeclSyntax],
        funcDelcs: [FunctionDeclSyntax],
        initDecls: [InitializerDeclSyntax],
        isClass: Bool) -> ProtocolDeclSyntax {
        
        let varInterfaces = Array(varDecls
                .filter(\.notHasPrivateGetterSetter)
                .map { $0.makeInterfaces() }
                .joined()
        )
        .map(\.toMemberDeclListItem)
        
        let initInterfaces = initDecls.map(\.interface).map(\.toMemberDeclListItem)
        let funcInterfaces = funcDelcs.map(\.interface).map(\.toMemberDeclListItem)
        
        var memberInterfaces = [MemberDeclListItemSyntax]()
        if !Settings.shared.protocolSettings.getIgnorance(ignorance: .function) {
            memberInterfaces.append(contentsOf: funcInterfaces)
        }
        if !Settings.shared.protocolSettings.getIgnorance(ignorance: .storedProperty) {
            //TODO:-
        }
        if !Settings.shared.protocolSettings.getIgnorance(ignorance: .computedGetterSetterProperty) {
            memberInterfaces.append(contentsOf: varInterfaces)
        }
        if !Settings.shared.protocolSettings.getIgnorance(ignorance: .initializer) {
            memberInterfaces.append(contentsOf: initInterfaces)
        }
        
        let format = Settings.shared.protocolSettings.nameFormat
        let formattedString = String(format: format, identifier.text)
        return SyntaxFactory.makeProtocolForDependencyInjection(
            identifier: identifier
                .withKind(
                    .stringLiteral(
                        formattedString
                    )
                ),
            members: SyntaxFactory.makeMemberDeclList(memberInterfaces)
        )
    }
    
}
