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
        FunctionSignatureDuplication.shared.list = checkSignatureDuplication()
        
        return members.members.compactMap { (item) -> [MemberDeclListItemSyntax]? in
            if let funcDecl = item.decl.as(FunctionDeclSyntax.self),
               !Settings.shared.target(from: mockType).getTarget(target: .function) {
                return funcDecl.generateMemberDeclItemsForMock(mockType: mockType)
            } else if let variableDecl = item.decl.as(VariableDeclSyntax.self),
                      !Settings.shared.target(from: mockType).getTarget(target: .property) {
                return variableDecl.generateMemberDeclItemsForMock(mockType: mockType)
            } else if let initDecl = item.decl.as(InitializerDeclSyntax.self),
                      !Settings.shared.target(from: mockType).getTarget(target: .initilizer) {
                return initDecl.generateMemberDeclItemsForMock(mockType: mockType)
            } else {
                return nil
            }
        }
    }
    
    func checkSignatureDuplication() -> [String: Counter] {
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
}

extension ProtocolDeclSyntax {
    func generateMockClass(_ mockType: MockType) -> MockClassDeclSyntax {
        let classDecl = SyntaxFactory.makeClassDecl(
            attributes: self.attributes,
            modifiers: self.modifiers,
            classKeyword: .makeFormattedClassKeyword(),
            identifier: mockIdentifier(mockType: mockType),
            genericParameterClause: nil,
            inheritanceClause: .makeFormattedProtocol(ProtocolNameHandler(self)),
            genericWhereClause: nil,
            members: .makeFormatted(with: makeMemberDeclListItems(mockType: mockType))
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
