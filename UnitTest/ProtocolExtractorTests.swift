//
//  ProtocolExtractorTests.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/27.
//  
//

import XCTest
import SwiftSyntax

class ProtocolExtractorTests: XCTestCase {
    func test_ViewController() throws {
        XCTAssertEqual(
            try ProtocolExtractor.expect(for: "ViewController"),
            """
            protocol ViewControllerProtocol {
                func viewDidLoad()
                func buttonDidClick(_ sender)
                var titleLabel: UILabel! { get set }
                var representedObject: Any? { get set }
            }
            """
        )
    }

    
    func test_InheritedClass() throws {
        XCTAssertEqual(
            try ProtocolExtractor.expect(
            """
            class InheritedClass: NSObject {
                
            }
            """
            ),
            """
            protocol InheritedClassProtocol {
            }
            """
        )
    }
    
    func test_ObjcClass() throws {
        XCTAssertEqual(
            try ProtocolExtractor.expect(
            """
            @objc class ObjcClass: NSObject {
                
            }
            """
            ),
            """
            protocol ObjcClassProtocol {
            }
            """
        )
    }
    
    func test_PropClass1() throws {
        XCTAssertEqual(
            try ProtocolExtractor.expect(for: "PropClass1"),
            """
            protocol PropClass1Protocol {
                var prop1: String? { get set }
                var prop2 : String { get }
                var prop3: Int { get set }
                var prop4: Double { get }
                var prop5: Float { get set }
            }
            """
        )
    }
    
    func test_FunctionClass() throws {
        XCTAssertEqual(
            try ProtocolExtractor.expect(for: "FunctionClass"),
            """
            protocol FunctionClassProtocol {
                func func1()
                func func2(arg: Int)
                func func3(arg: Int, arg2: String, arg3: () -> Void, arg4: (String, String))
                func func4() -> String
                func func5() throws -> String
            }
            """
        )
    }
    
    func test_SomeManager() throws {
        XCTAssertEqual(
            try ProtocolExtractor.expect(for: "SomeManager"),
            """
            protocol SomeManagerProtocol {
                func exec() -> String
                static var shared: SomeManager { get }
            }
            """
        )
    }
    
    func test_SomeFactory() throws {
        XCTAssertEqual(
            try ProtocolExtractor.expect(for: "SomeFactory"),
            """
            protocol SomeFactoryProtocol {
                static func make() -> SomeClass
            }
            """
        )
    }
}

extension ProtocolExtractor {
    static func expect(_ txt: String) throws -> String {
        let sourceFile = try SyntaxParser.parse(source: txt)
        let extractor = ProtocolExtractor()
        extractor.walk(sourceFile)
        return extractor
            .protocolDeclSyntaxList
            .first!
            .protocolDeclSyntax.description
    }
}

extension ProtocolExtractor {
    static func expect(for resource: String) throws -> String {
        let sourceFile = try SyntaxParser
            .parse(forResource: resource)
        let extractor = ProtocolExtractor()
        extractor.walk(sourceFile)
        return extractor
            .protocolDeclSyntaxList
            .first!
            .protocolDeclSyntax.description
    }
}

extension SyntaxParser {
    static func parse(forResource resource: String) throws -> SourceFileSyntax {
        let sourceURL = Bundle(for: BundleToken.self)
                .url(forResource: resource, withExtension: "txt")!
        let sourceString = try! String(contentsOf: sourceURL)
        return try SyntaxParser.parse(source: sourceString)
    }
}
