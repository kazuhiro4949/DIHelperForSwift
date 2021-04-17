//
//  ProtocolDeclSyntax+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation
import SwiftSyntax


struct Counter {
    var count: Int
    var max: Int
}

class FunctionSignatureDuplication {
    static let shared = FunctionSignatureDuplication()
    var list = [String: Counter]()

}

extension ProtocolDeclSyntax {
    func makeMemberDeclListItems(mockType: MockType) -> [[MemberDeclListItemSyntax]] {
        FunctionSignatureDuplication.shared.list = checkSignatureDuplication(mockType: mockType)
        
        return members.members.compactMap { (item) -> [MemberDeclListItemSyntax]? in
            if let funcDecl = item.decl.as(FunctionDeclSyntax.self),
               Settings.shared.target(from: mockType)?.getTarget(target: .function) == false {
                return funcDecl.generateMemberDeclItemsForMock(mockType: mockType)
            } else if let variableDecl = item.decl.as(VariableDeclSyntax.self),
                      Settings.shared.target(from: mockType)?.getTarget(target: .property) == false {
                return variableDecl.generateMemberDeclItemsForMock(mockType: mockType)
            } else if let initDecl = item.decl.as(InitializerDeclSyntax.self),
                      Settings.shared.target(from: mockType)?.getTarget(target: .initilizer) == false {
                return initDecl.generateMemberDeclItemsForMock(mockType: mockType)
            } else {
                return nil
            }
        }
    }
    
    func checkSignatureDuplication(mockType: MockType) -> [String: Counter] {
        switch mockType {
        case .dummy:
            return [:]
        case .spy:
            return checkSignatureDuplicationForSpy()
        case .stub:
            return checkSignatureDuplicationForStub()
        }
    }
    
    func checkSignatureDuplicationForSpy() -> [String: Counter] {
        let counter = members.members.reduce(into: [String: Counter]()) { (result, item) in
            if let funcDecl = item.decl.as(FunctionDeclSyntax.self) {
                var counter = result[funcDecl.identifier.text] ?? Counter(count: 0, max: 0)
                counter.max += 1
                result[funcDecl.identifier.text] = counter
            } else if let initDecl = item.decl.as(InitializerDeclSyntax.self) {
                var counter = result[initDecl.initKeyword.text] ?? Counter(count: 0, max: 0)
                counter.max += 1
                result[initDecl.initKeyword.text] = counter
            }
        }
        return counter.filter({ 1 < $0.value.max })
    }
    
    func checkSignatureDuplicationForStub() -> [String: Counter] {
        let counter = members.members.reduce(into: [String: Counter]()) { (result, item) in
            if let funcDecl = item.decl.as(FunctionDeclSyntax.self), !funcDecl.signature.isReturnedVoid {
                var counter = result[funcDecl.identifier.text] ?? Counter(count: 0, max: 0)
                counter.max += 1
                result[funcDecl.identifier.text] = counter
            }
        }
        return counter.filter({ 1 < $0.value.max })
    }
}

extension FunctionSignatureSyntax {
    var isReturnedVoid: Bool {
        guard let output = output else {
            return true // func f()
        }
        
        if let simpleType = output.returnType.as(SimpleTypeIdentifierSyntax.self) {
            return simpleType.name.text == "Void" // func f() -> Void
        } else if let tupleType = output.returnType.as(TupleTypeSyntax.self) {
            return tupleType.elements.count == 0 // func f() -> ()
        } else {
            return false
        }
    }
}

extension ProtocolDeclSyntax {
    func generateMockClass(_ mockType: MockType) -> MockClassDeclSyntax {
        let decls: [[MemberDeclListItemSyntax]] = makeMemberDeclListItems(
            mockType: mockType
        )
        
        // MARK: - TODO
        var processedDecls = [[MemberDeclListItemSyntax]]()
        var hasAvailable = false
        decls.forEach { declList in
            var processedDeclList = [MemberDeclListItemSyntax]()
            declList.forEach { decl in
                if let variableDecl = decl.decl.as(VariableDeclSyntax.self) {
                    var processedAttributes = [Syntax]()
                    variableDecl.attributes?.forEach { syntax in
                        if let attribute = syntax.as(AttributeSyntax.self) {
                            if attribute.attributeName.text == "available" {
                                hasAvailable = true
                            } else {
                                processedAttributes.append(Syntax(attribute))
                            }
                        }
                    }
                    let processedVariableDecl = variableDecl
                        .withAttributes(
                            SyntaxFactory
                                .makeAttributeList(
                                    processedAttributes
                                )
                        )
                    processedDeclList.append(
                        decl.withDecl(DeclSyntax(processedVariableDecl))
                    )
                } else {
                    processedDeclList.append(decl)
                }
            }
            processedDecls.append(processedDeclList)
        }
        // MARK: - TODO
        
        let classDecl = SyntaxFactory.makeClassDecl(
            attributes: attributes?.protocolExclusiveRemoved,
            modifiers: nil,
            classKeyword: .makeFormattedClassKeyword(),
            identifier: mockIdentifier(mockType: mockType),
            genericParameterClause: nil,
            inheritanceClause: .makeFormattedProtocol(
                mockType: mockType,
                handler: .init(self)
            ),
            genericWhereClause: nil,
            members: .makeFormatted(with: processedDecls)
        )
        
        let document = """

        /// \(mockType.rawValue.capitalized) for \(identifier.text)
        ///
        /// It is generated by [Dependeny Injection Helper for Xcode](https://git.io/JtPLf)
        """
        
        return MockClassDeclSyntax(classDeclSyntax: classDecl, prefixComment: document)
    }
    
    func mockIdentifier(mockType: MockType) -> TokenSyntax {
        SyntaxFactory
            .makeIdentifier(
                .init(
                    format: mockType.format,
                    ProtocolNameHandler(self).getBaseName()
                )
            )
    }
}
