//
//  MockGenerater.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/27.
//  
//

import Foundation
import SwiftSyntax

public struct MockClassDeclSyntax {
    public let classDeclSyntax: ClassDeclSyntax
    public let prefixComment: String
}

public class MockGenerater: SyntaxVisitor {
    public init(mockType: MockType) {
        self.mockType = mockType
    }
    
    public let mockType: MockType
    public var mockClasses = [MockClassDeclSyntax]()
    
    public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        mockClasses.append(node.generateMockClass(mockType))
        
        return .skipChildren
    }

    public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        dump(node)
        return .skipChildren
    }
}
