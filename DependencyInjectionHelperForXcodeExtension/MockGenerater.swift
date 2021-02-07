//
//  MockGenerater.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/27.
//  
//

import Foundation
import SwiftSyntax
class MockGenerater: SyntaxVisitor {
    internal init(mockType: MockType) {
        self.mockType = mockType
    }
    
    let mockType: MockType
    var mockClasses = [ClassDeclSyntax]()
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        mockClasses.append(node.generateMockClass(mockType))
        
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        dump(node)
        return .skipChildren
    }
}
