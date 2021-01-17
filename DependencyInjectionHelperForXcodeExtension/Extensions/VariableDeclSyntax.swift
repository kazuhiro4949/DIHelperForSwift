//
//  VariableDeclSyntax.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/17.
//  
//

import Foundation
import SwiftSyntax

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
    
    var toMemberDeclListItem: MemberDeclListItemSyntax {
        SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(self)
                .withLeadingTrivia(.spaces(4))
                .withTrailingTrivia(.newlines(1)),
            semicolon: nil
        )
    }
}


