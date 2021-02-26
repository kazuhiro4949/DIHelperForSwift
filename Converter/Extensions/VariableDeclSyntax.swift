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
                with: keywordsFromAccessor.intersection(keywordsFromVariable), modifiers: modifiers?.protocolEnabled
            )
            return [protocolVariable]
        } else if isComputedProperty {
            // computed property
            return [binding.convertForProtocol(with: .get, modifiers: modifiers?.protocolEnabled)]
        } else {
            // stored property
            return makeInterfacesFromBindings()
        }
    }
    
    func makeInterfacesFromBindings() -> [VariableDeclSyntax] {
        makeTypeAnnotatedBindings()
            .map {
                $0.convertForProtocol(with: contextualKeywords, modifiers: modifiers?.protocolEnabled)
            }
    }
    
    func makeTypeAnnotatedBindings() -> [PatternBindingSyntax] {
        typealias ReducedResult = (syntaxList: [PatternBindingSyntax], currentValue: Either<TypeAnnotationSyntax, ExprSyntax>?)
        return bindings.reversed().reduce(ReducedResult([], nil)) { (result, binding) in
            let either: Either<TypeAnnotationSyntax, ExprSyntax>?
            if let typeAnnotation = binding.typeAnnotation {
                either = Either(typeAnnotation)
            } else if let initializer = binding.initializer {
                either = Either(initializer.value)
            } else {
                either = result.currentValue
            }
            
            let bindingWithTypeAnnotation: PatternBindingSyntax
            switch either {
            case .first(let typeAnnotation):
                bindingWithTypeAnnotation = binding.withTypeAnnotation(typeAnnotation)
            case .second(let value):
                
                let typeString: String
                if value.is(StringLiteralExprSyntax.self) {
                    typeString = "String"
                } else if value.is(FloatLiteralExprSyntax.self) {
                    typeString = "Double"
                } else if value.is(IntegerLiteralExprSyntax.self) {
                    typeString = "Int"
                } else if value.is(BooleanLiteralExprSyntax.self) {
                    typeString = "Bool"
                } else {
                    typeString = "<#T##Any#>"
                }
                
                bindingWithTypeAnnotation = binding.withTypeAnnotation(
                    SyntaxFactory.makeTypeAnnotation(
                    colon: SyntaxFactory.makeColonToken(),
                    type: SyntaxFactory.makeTypeIdentifier(
                        typeString,
                        leadingTrivia: .spaces(1),
                        trailingTrivia: .spaces(1))
                    )
                )
            case .none:
                bindingWithTypeAnnotation = binding
            }
            return (result.syntaxList + [bindingWithTypeAnnotation], either)
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
            (modifier.name.text == "private" || modifier.name.text == "fileprivate")
                && modifier.detail == nil
        }) ?? false
    }
    
    var hasPrivateSetter: Bool {
        modifiers?.contains(where: { (modifier) -> Bool in
            (modifier.name.text == "private" || modifier.name.text == "fileprivate")
                && modifier.detail?.text == "set"
        }) ?? false
    }
    
    var hasOverrdie: Bool {
        modifiers?.contains(where: { (modifier) -> Bool in
            modifier.name.text == "override"
        }) ?? false
    }
    
    var hasPublic: Bool {
        modifiers?.contains(where: { (modifier) -> Bool in
            modifier.name.text == "public"
        }) ?? false
    }
    
    var notHasOverrdie: Bool {
        !hasOverrdie
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

extension VariableDeclSyntax {
    func generateMemberDeclItemsForMock(mockType: MockType) -> [MemberDeclListItemSyntax] {
        guard let binding = bindings.first,
              let accessorBlock = binding.accessor?.as(AccessorBlockSyntax.self),
              let identifier =  binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            return []
        }
        
        let mockProperties = accessorBlock.makeMockPropertyForAccessors(
            for: mockType,
            identifier: identifier,
            binding: binding
        )
        
        let accessors = mockProperties?.map { $0.accessor }
        let patternList = SyntaxFactory.makePatternBindingList([
            binding.makeAccessorForMock(
                accessors: accessors,
                initializer: .makeInitialiizer(
                    for: mockType,
                    identifier: identifier,
                    binding: binding
                )
            )
        ])
        .withTrailingTrivia(.newlines(1))
        
        let propDeclListItems = mockProperties?.map { $0.members }.flatMap { $0 } ?? []
        
        let variable = SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: .makeFormattedVarKeyword(),
            bindings: patternList)
        let declListItem = SyntaxFactory.makeMemberDeclListItem(
            decl: DeclSyntax(variable),
            semicolon: nil
        )
        return propDeclListItems + [declListItem]
    }
    
    static func makeReturnedValForMock(_ identifier: String, _ typeSyntax: TypeSyntax) -> VariableDeclSyntax {
        SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: .makeFormattedVarKeyword(),
            bindings: .makeReturnedValForMock(identifier, typeSyntax)
        ).withTrailingTrivia(.newlines(1))
    }
    
    static func makeDeclWithAssign(to identifier: String, from expr: ExprSyntax) -> VariableDeclSyntax {
        SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: .makeFormattedVarKeyword(),
            bindings: SyntaxFactory
                .makePatternBindingList([
                    .makeAssign(to: identifier,
                                from: expr
                    )
                ]))
    }
    
    static func makeDeclWithAssign(to identifier: String,
                                   typeAnnotation: TypeAnnotationSyntax) -> VariableDeclSyntax {
        
        SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: .makeFormattedVarKeyword(),
            bindings: SyntaxFactory
                .makePatternBindingList([
                    .makeAssign(to: identifier,
                                typeAnnotation: typeAnnotation
                    )
                ]))
    }
}
