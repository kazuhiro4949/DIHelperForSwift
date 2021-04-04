//
//  MockGeneratorTests.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/27.
//  
//

import XCTest
import SwiftSyntax

class MockGeneratorTests: XCTestCase {
    override func setUp() {
        Settings.shared.spySettings.setScene(scene: .kvc, value: true)
    }
    
    override func tearDown() {
        Settings.shared.spySettings.setScene(scene: .kvc, value: true)
    }
    
    // MARK:- SPY
    func test_ViewControllerPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol ViewControllerProtocol {
                var textField: NSTextField { get set }
                func buttonDidClick(_ sender: NSButton)
            }
            """),
            """
            class ViewControllerSpy: ViewControllerProtocol {
                var textField_get_wasCalled = false
                var textField_get_callCount = 0
                var textField_get_val: NSTextField = <#T##NSTextField#>
                var textField_set_wasCalled = false
                var textField_set_callCount = 0
                var textField_set_args: NSTextField?
                var textField: NSTextField {
                    get {
                        textField_get_wasCalled = true
                        textField_get_callCount += 1
                        return textField_get_val
                    }
                    set {
                        textField_set_wasCalled = true
                        textField_set_callCount += 1
                        textField_set_args = newValue
                    }
                }
                var buttonDidClick_wasCalled = false
                var buttonDidClick_callCount = 0
                var buttonDidClick_args: NSButton?
                func buttonDidClick(_ sender: NSButton) {
                    buttonDidClick_wasCalled = true
                    buttonDidClick_callCount += 1
                    buttonDidClick_args = sender
                }
            }

            """
        )
    }
    
    func test_FactoryPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol SomeFactoryProtocol {
                static func make() -> SomeClassProtocol
            }
            """),
            """
            class SomeFactorySpy: SomeFactoryProtocol {
                static var make_wasCalled = false
                static var make_callCount = 0
                static var make_val: SomeClassProtocol = <#T##SomeClassProtocol#>
                static func make() -> SomeClassProtocol {
                    make_wasCalled = true
                    make_callCount += 1
                    return make_val
                }
            }

            """
        )
    }

    func test_ManagerPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol SomeManagerProtocol {
                static var shared: SomeManagerProtocol { get }
            }
            """),
            """
            class SomeManagerSpy: SomeManagerProtocol {
                static var shared_get_wasCalled = false
                static var shared_get_callCount = 0
                static var shared_get_val: SomeManagerProtocol = <#T##SomeManagerProtocol#>
                static var shared: SomeManagerProtocol {
                    get {
                        shared_get_wasCalled = true
                        shared_get_callCount += 1
                        return shared_get_val
                    }
                }
            }

            """
        )
    }
    
    func test_FunctionsPattern5Protocol() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol FunctionsPattern5Protocol {
                func func1() -> String
                func func1()
                func func2()
                func func3() -> Void
                func func4() -> ()
            }
            """),
            """
            class FunctionsPattern5Spy: FunctionsPattern5Protocol {
                var func1_<#T##identifier1##identifier1#>_wasCalled = false
                var func1_<#T##identifier1##identifier1#>_callCount = 0
                var func1_<#T##identifier1##identifier1#>_val: String = ""
                func func1() -> String {
                    func1_<#T##identifier1##identifier1#>_wasCalled = true
                    func1_<#T##identifier1##identifier1#>_callCount += 1
                    return func1_<#T##identifier1##identifier1#>_val
                }

                var func1_<#T##identifier2##identifier2#>_wasCalled = false
                var func1_<#T##identifier2##identifier2#>_callCount = 0
                func func1() {
                    func1_<#T##identifier2##identifier2#>_wasCalled = true
                    func1_<#T##identifier2##identifier2#>_callCount += 1
                }

                var func2_wasCalled = false
                var func2_callCount = 0
                func func2() {
                    func2_wasCalled = true
                    func2_callCount += 1
                }

                var func3_wasCalled = false
                var func3_callCount = 0
                func func3() -> Void {
                    func3_wasCalled = true
                    func3_callCount += 1
                }

                var func4_wasCalled = false
                var func4_callCount = 0
                func func4() -> () {
                    func4_wasCalled = true
                    func4_callCount += 1
                }
            }

            """
        )
    }
    
    func test_FunctionsPattern1Protocol() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol FunctionsPattern1Protocol {
                func func1()
                func func2() -> Int
                func func3(_ arg1: String, arg2: Int) -> Int
                func func4() throws -> String
            }
            """),
            """
            class FunctionsPattern1Spy: FunctionsPattern1Protocol {
                var func1_wasCalled = false
                var func1_callCount = 0
                func func1() {
                    func1_wasCalled = true
                    func1_callCount += 1
                }

                var func2_wasCalled = false
                var func2_callCount = 0
                var func2_val: Int = 0
                func func2() -> Int {
                    func2_wasCalled = true
                    func2_callCount += 1
                    return func2_val
                }

                var func3_wasCalled = false
                var func3_callCount = 0
                var func3_args:  (arg1: String, arg2: Int)?
                var func3_val: Int = 0
                func func3(_ arg1: String, arg2: Int) -> Int {
                    func3_wasCalled = true
                    func3_callCount += 1
                    func3_args = (arg1, arg2)
                    return func3_val
                }

                var func4_wasCalled = false
                var func4_callCount = 0
                var func4_val: String = ""
                func func4() throws -> String {
                    func4_wasCalled = true
                    func4_callCount += 1
                    return func4_val
                }
            }

            """
        )
    }
    
    func test_FunctionsProtoco2() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol FunctionsPattern2Protocol {
                func func1() -> String
                func func2(arg: String)
                func func3(arg: Int) -> String
                func func4(_ arg: Int) -> String
                func func5(for arg1: String, arg2: Int) -> Int
            }
            """),
            """
            class FunctionsPattern2Spy: FunctionsPattern2Protocol {
                var func1_wasCalled = false
                var func1_callCount = 0
                var func1_val: String = ""
                func func1() -> String {
                    func1_wasCalled = true
                    func1_callCount += 1
                    return func1_val
                }

                var func2_wasCalled = false
                var func2_callCount = 0
                var func2_args: String?
                func func2(arg: String) {
                    func2_wasCalled = true
                    func2_callCount += 1
                    func2_args = arg
                }

                var func3_wasCalled = false
                var func3_callCount = 0
                var func3_args: Int?
                var func3_val: String = ""
                func func3(arg: Int) -> String {
                    func3_wasCalled = true
                    func3_callCount += 1
                    func3_args = arg
                    return func3_val
                }

                var func4_wasCalled = false
                var func4_callCount = 0
                var func4_args: Int?
                var func4_val: String = ""
                func func4(_ arg: Int) -> String {
                    func4_wasCalled = true
                    func4_callCount += 1
                    func4_args = arg
                    return func4_val
                }

                var func5_wasCalled = false
                var func5_callCount = 0
                var func5_args:  (arg1: String, arg2: Int)?
                var func5_val: Int = 0
                func func5(for arg1: String, arg2: Int) -> Int {
                    func5_wasCalled = true
                    func5_callCount += 1
                    func5_args = (arg1, arg2)
                    return func5_val
                }
            }

            """
        )
    }
    
    func test_FunctionsPattern3() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol FunctionsPattern3Protocol {
                func func1(arg: Int8) -> Int8
                func func3(arg: Int32) -> Int32
                func func4(arg: Int64) -> Int64
                func func5(arg: Float) -> Float
                func func7(arg: Float64) -> Float64
                func func8(arg: Double) -> Double
                func func9(arg: CGFloat) -> CGFloat
            }
            """),
            """
            class FunctionsPattern3Spy: FunctionsPattern3Protocol {
                var func1_wasCalled = false
                var func1_callCount = 0
                var func1_args: Int8?
                var func1_val: Int8 = 0
                func func1(arg: Int8) -> Int8 {
                    func1_wasCalled = true
                    func1_callCount += 1
                    func1_args = arg
                    return func1_val
                }

                var func3_wasCalled = false
                var func3_callCount = 0
                var func3_args: Int32?
                var func3_val: Int32 = 0
                func func3(arg: Int32) -> Int32 {
                    func3_wasCalled = true
                    func3_callCount += 1
                    func3_args = arg
                    return func3_val
                }

                var func4_wasCalled = false
                var func4_callCount = 0
                var func4_args: Int64?
                var func4_val: Int64 = 0
                func func4(arg: Int64) -> Int64 {
                    func4_wasCalled = true
                    func4_callCount += 1
                    func4_args = arg
                    return func4_val
                }

                var func5_wasCalled = false
                var func5_callCount = 0
                var func5_args: Float?
                var func5_val: Float = 0.0
                func func5(arg: Float) -> Float {
                    func5_wasCalled = true
                    func5_callCount += 1
                    func5_args = arg
                    return func5_val
                }

                var func7_wasCalled = false
                var func7_callCount = 0
                var func7_args: Float64?
                var func7_val: Float64 = 0.0
                func func7(arg: Float64) -> Float64 {
                    func7_wasCalled = true
                    func7_callCount += 1
                    func7_args = arg
                    return func7_val
                }

                var func8_wasCalled = false
                var func8_callCount = 0
                var func8_args: Double?
                var func8_val: Double = 0.0
                func func8(arg: Double) -> Double {
                    func8_wasCalled = true
                    func8_callCount += 1
                    func8_args = arg
                    return func8_val
                }

                var func9_wasCalled = false
                var func9_callCount = 0
                var func9_args: CGFloat?
                var func9_val: CGFloat = 0.0
                func func9(arg: CGFloat) -> CGFloat {
                    func9_wasCalled = true
                    func9_callCount += 1
                    func9_args = arg
                    return func9_val
                }
            }

            """
        )
    }
    
    func test_FunctionsPattern6() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol FunctionsPattern6Protocol {
                func func2(arg: Int16) -> Int16
                func func6(arg: Float32) -> Float32
            }
            """),
            """
            class FunctionsPattern6Spy: FunctionsPattern6Protocol {
                var func2_wasCalled = false
                var func2_callCount = 0
                var func2_args: Int16?
                var func2_val: Int16 = 0
                func func2(arg: Int16) -> Int16 {
                    func2_wasCalled = true
                    func2_callCount += 1
                    func2_args = arg
                    return func2_val
                }

                var func6_wasCalled = false
                var func6_callCount = 0
                var func6_args: Float32?
                var func6_val: Float32 = 0.0
                func func6(arg: Float32) -> Float32 {
                    func6_wasCalled = true
                    func6_callCount += 1
                    func6_args = arg
                    return func6_val
                }
            }

            """
        )
    }
    
    func test_FunctionsPattern7() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol FunctionsPattern7Protocol {
                func func10(arg: [String]) -> [String]
                func func11(arg: [String: String]) -> [String: String]
                func func12(arg: (String, String)) -> (String, String)
                func func13(arg: SomeClass) -> SomeClass
            }
            """),
            """
            class FunctionsPattern7Spy: FunctionsPattern7Protocol {
                var func10_wasCalled = false
                var func10_callCount = 0
                var func10_args: [String]?
                var func10_val: [String] = []
                func func10(arg: [String]) -> [String] {
                    func10_wasCalled = true
                    func10_callCount += 1
                    func10_args = arg
                    return func10_val
                }

                var func11_wasCalled = false
                var func11_callCount = 0
                var func11_args: [String: String]?
                var func11_val: [String: String] = [:]
                func func11(arg: [String: String]) -> [String: String] {
                    func11_wasCalled = true
                    func11_callCount += 1
                    func11_args = arg
                    return func11_val
                }

                var func12_wasCalled = false
                var func12_callCount = 0
                var func12_args: (String, String)?
                var func12_val: (String, String)! = <#T##(String, String)#>
                func func12(arg: (String, String)) -> (String, String) {
                    func12_wasCalled = true
                    func12_callCount += 1
                    func12_args = arg
                    return func12_val
                }

                var func13_wasCalled = false
                var func13_callCount = 0
                var func13_args: SomeClass?
                var func13_val: SomeClass = <#T##SomeClass#>
                func func13(arg: SomeClass) -> SomeClass {
                    func13_wasCalled = true
                    func13_callCount += 1
                    func13_args = arg
                    return func13_val
                }
            }

            """
        )
    }
    
    func test_FunctionsPattern4() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol FunctionsPattern4Protocol {
                func func1()
                func func1() -> Int
                func func1(_ arg1: String, arg2: Int) -> Int
                func func1() throws -> String
            }
            """),
            """
            class FunctionsPattern4Spy: FunctionsPattern4Protocol {
                var func1_<#T##identifier1##identifier1#>_wasCalled = false
                var func1_<#T##identifier1##identifier1#>_callCount = 0
                func func1() {
                    func1_<#T##identifier1##identifier1#>_wasCalled = true
                    func1_<#T##identifier1##identifier1#>_callCount += 1
                }

                var func1_<#T##identifier2##identifier2#>_wasCalled = false
                var func1_<#T##identifier2##identifier2#>_callCount = 0
                var func1_<#T##identifier2##identifier2#>_val: Int = 0
                func func1() -> Int {
                    func1_<#T##identifier2##identifier2#>_wasCalled = true
                    func1_<#T##identifier2##identifier2#>_callCount += 1
                    return func1_<#T##identifier2##identifier2#>_val
                }

                var func1_<#T##identifier3##identifier3#>_wasCalled = false
                var func1_<#T##identifier3##identifier3#>_callCount = 0
                var func1_<#T##identifier3##identifier3#>_args:  (arg1: String, arg2: Int)?
                var func1_<#T##identifier3##identifier3#>_val: Int = 0
                func func1(_ arg1: String, arg2: Int) -> Int {
                    func1_<#T##identifier3##identifier3#>_wasCalled = true
                    func1_<#T##identifier3##identifier3#>_callCount += 1
                    func1_<#T##identifier3##identifier3#>_args = (arg1, arg2)
                    return func1_<#T##identifier3##identifier3#>_val
                }

                var func1_<#T##identifier4##identifier4#>_wasCalled = false
                var func1_<#T##identifier4##identifier4#>_callCount = 0
                var func1_<#T##identifier4##identifier4#>_val: String = ""
                func func1() throws -> String {
                    func1_<#T##identifier4##identifier4#>_wasCalled = true
                    func1_<#T##identifier4##identifier4#>_callCount += 1
                    return func1_<#T##identifier4##identifier4#>_val
                }
            }

            """
        )
    }
    
    func test_PropertyPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol PropertyPatternProtocol {
                var prop1: String { get }
                var prop2: String? { get set }
                var prop3: Int { get set }
                var prop4: Int8 { get set }
                var prop5: Int16 { get set }
                var prop6: Int32 { get set }
                var prop7: Int64 { get set }
                var prop8: Float { get set }
                var prop9: Float32 { get set }
                var prop10: Float64 { get set }
                var prop11: Double { get set }
                var prop12: CGFloat { get set }
                var prop13: () -> Void { get }
                var prop14: [String] { get }
                var prop15: [String: String] { get }
                var prop16: (String, String) { get }
                var prop17: SomeClass { get }
            }
            """),
            """
            class PropertyPatternSpy: PropertyPatternProtocol {
                var prop1_get_wasCalled = false
                var prop1_get_callCount = 0
                var prop1_get_val: String = ""
                var prop1: String {
                    get {
                        prop1_get_wasCalled = true
                        prop1_get_callCount += 1
                        return prop1_get_val
                    }
                }
                var prop2_get_wasCalled = false
                var prop2_get_callCount = 0
                var prop2_get_val: String? = ""
                var prop2_set_wasCalled = false
                var prop2_set_callCount = 0
                var prop2_set_args: String?
                var prop2: String? {
                    get {
                        prop2_get_wasCalled = true
                        prop2_get_callCount += 1
                        return prop2_get_val
                    }
                    set {
                        prop2_set_wasCalled = true
                        prop2_set_callCount += 1
                        prop2_set_args = newValue
                    }
                }
                var prop3_get_wasCalled = false
                var prop3_get_callCount = 0
                var prop3_get_val: Int = 0
                var prop3_set_wasCalled = false
                var prop3_set_callCount = 0
                var prop3_set_args: Int?
                var prop3: Int {
                    get {
                        prop3_get_wasCalled = true
                        prop3_get_callCount += 1
                        return prop3_get_val
                    }
                    set {
                        prop3_set_wasCalled = true
                        prop3_set_callCount += 1
                        prop3_set_args = newValue
                    }
                }
                var prop4_get_wasCalled = false
                var prop4_get_callCount = 0
                var prop4_get_val: Int8 = 0
                var prop4_set_wasCalled = false
                var prop4_set_callCount = 0
                var prop4_set_args: Int8?
                var prop4: Int8 {
                    get {
                        prop4_get_wasCalled = true
                        prop4_get_callCount += 1
                        return prop4_get_val
                    }
                    set {
                        prop4_set_wasCalled = true
                        prop4_set_callCount += 1
                        prop4_set_args = newValue
                    }
                }
                var prop5_get_wasCalled = false
                var prop5_get_callCount = 0
                var prop5_get_val: Int16 = 0
                var prop5_set_wasCalled = false
                var prop5_set_callCount = 0
                var prop5_set_args: Int16?
                var prop5: Int16 {
                    get {
                        prop5_get_wasCalled = true
                        prop5_get_callCount += 1
                        return prop5_get_val
                    }
                    set {
                        prop5_set_wasCalled = true
                        prop5_set_callCount += 1
                        prop5_set_args = newValue
                    }
                }
                var prop6_get_wasCalled = false
                var prop6_get_callCount = 0
                var prop6_get_val: Int32 = 0
                var prop6_set_wasCalled = false
                var prop6_set_callCount = 0
                var prop6_set_args: Int32?
                var prop6: Int32 {
                    get {
                        prop6_get_wasCalled = true
                        prop6_get_callCount += 1
                        return prop6_get_val
                    }
                    set {
                        prop6_set_wasCalled = true
                        prop6_set_callCount += 1
                        prop6_set_args = newValue
                    }
                }
                var prop7_get_wasCalled = false
                var prop7_get_callCount = 0
                var prop7_get_val: Int64 = 0
                var prop7_set_wasCalled = false
                var prop7_set_callCount = 0
                var prop7_set_args: Int64?
                var prop7: Int64 {
                    get {
                        prop7_get_wasCalled = true
                        prop7_get_callCount += 1
                        return prop7_get_val
                    }
                    set {
                        prop7_set_wasCalled = true
                        prop7_set_callCount += 1
                        prop7_set_args = newValue
                    }
                }
                var prop8_get_wasCalled = false
                var prop8_get_callCount = 0
                var prop8_get_val: Float = 0.0
                var prop8_set_wasCalled = false
                var prop8_set_callCount = 0
                var prop8_set_args: Float?
                var prop8: Float {
                    get {
                        prop8_get_wasCalled = true
                        prop8_get_callCount += 1
                        return prop8_get_val
                    }
                    set {
                        prop8_set_wasCalled = true
                        prop8_set_callCount += 1
                        prop8_set_args = newValue
                    }
                }
                var prop9_get_wasCalled = false
                var prop9_get_callCount = 0
                var prop9_get_val: Float32 = 0.0
                var prop9_set_wasCalled = false
                var prop9_set_callCount = 0
                var prop9_set_args: Float32?
                var prop9: Float32 {
                    get {
                        prop9_get_wasCalled = true
                        prop9_get_callCount += 1
                        return prop9_get_val
                    }
                    set {
                        prop9_set_wasCalled = true
                        prop9_set_callCount += 1
                        prop9_set_args = newValue
                    }
                }
                var prop10_get_wasCalled = false
                var prop10_get_callCount = 0
                var prop10_get_val: Float64 = 0.0
                var prop10_set_wasCalled = false
                var prop10_set_callCount = 0
                var prop10_set_args: Float64?
                var prop10: Float64 {
                    get {
                        prop10_get_wasCalled = true
                        prop10_get_callCount += 1
                        return prop10_get_val
                    }
                    set {
                        prop10_set_wasCalled = true
                        prop10_set_callCount += 1
                        prop10_set_args = newValue
                    }
                }
                var prop11_get_wasCalled = false
                var prop11_get_callCount = 0
                var prop11_get_val: Double = 0.0
                var prop11_set_wasCalled = false
                var prop11_set_callCount = 0
                var prop11_set_args: Double?
                var prop11: Double {
                    get {
                        prop11_get_wasCalled = true
                        prop11_get_callCount += 1
                        return prop11_get_val
                    }
                    set {
                        prop11_set_wasCalled = true
                        prop11_set_callCount += 1
                        prop11_set_args = newValue
                    }
                }
                var prop12_get_wasCalled = false
                var prop12_get_callCount = 0
                var prop12_get_val: CGFloat = 0.0
                var prop12_set_wasCalled = false
                var prop12_set_callCount = 0
                var prop12_set_args: CGFloat?
                var prop12: CGFloat {
                    get {
                        prop12_get_wasCalled = true
                        prop12_get_callCount += 1
                        return prop12_get_val
                    }
                    set {
                        prop12_set_wasCalled = true
                        prop12_set_callCount += 1
                        prop12_set_args = newValue
                    }
                }
                var prop13_get_wasCalled = false
                var prop13_get_callCount = 0
                var prop13_get_val: (() -> Void)! = <#T##() -> Void#>
                var prop13: () -> Void {
                    get {
                        prop13_get_wasCalled = true
                        prop13_get_callCount += 1
                        return prop13_get_val
                    }
                }
                var prop14_get_wasCalled = false
                var prop14_get_callCount = 0
                var prop14_get_val: [String] = []
                var prop14: [String] {
                    get {
                        prop14_get_wasCalled = true
                        prop14_get_callCount += 1
                        return prop14_get_val
                    }
                }
                var prop15_get_wasCalled = false
                var prop15_get_callCount = 0
                var prop15_get_val: [String: String] = [:]
                var prop15: [String: String] {
                    get {
                        prop15_get_wasCalled = true
                        prop15_get_callCount += 1
                        return prop15_get_val
                    }
                }
                var prop16_get_wasCalled = false
                var prop16_get_callCount = 0
                var prop16_get_val: (String, String)! = <#T##(String, String)#>
                var prop16: (String, String) {
                    get {
                        prop16_get_wasCalled = true
                        prop16_get_callCount += 1
                        return prop16_get_val
                    }
                }
                var prop17_get_wasCalled = false
                var prop17_get_callCount = 0
                var prop17_get_val: SomeClass = <#T##SomeClass#>
                var prop17: SomeClass {
                    get {
                        prop17_get_wasCalled = true
                        prop17_get_callCount += 1
                        return prop17_get_val
                    }
                }
            }

            """
        )
    }
    
    func test_PropertyPattern2() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
                .spy,
            """
            protocol PropertyPattern2Protocol {
                var prop1: SomeClass? { get }
                var prop2: SomeClass! { get }
                var prop3: [SomeClass]? { get set }
                var prop4: [SomeClass]! { get set }
            }
            """),
            """
            class PropertyPattern2Spy: PropertyPattern2Protocol {
                var prop1_get_wasCalled = false
                var prop1_get_callCount = 0
                var prop1_get_val: SomeClass? = nil
                var prop1: SomeClass? {
                    get {
                        prop1_get_wasCalled = true
                        prop1_get_callCount += 1
                        return prop1_get_val
                    }
                }
                var prop2_get_wasCalled = false
                var prop2_get_callCount = 0
                var prop2_get_val: SomeClass! = <#T##SomeClass!#>
                var prop2: SomeClass! {
                    get {
                        prop2_get_wasCalled = true
                        prop2_get_callCount += 1
                        return prop2_get_val
                    }
                }
                var prop3_get_wasCalled = false
                var prop3_get_callCount = 0
                var prop3_get_val: [SomeClass]? = []
                var prop3_set_wasCalled = false
                var prop3_set_callCount = 0
                var prop3_set_args: [SomeClass]?
                var prop3: [SomeClass]? {
                    get {
                        prop3_get_wasCalled = true
                        prop3_get_callCount += 1
                        return prop3_get_val
                    }
                    set {
                        prop3_set_wasCalled = true
                        prop3_set_callCount += 1
                        prop3_set_args = newValue
                    }
                }
                var prop4_get_wasCalled = false
                var prop4_get_callCount = 0
                var prop4_get_val: [SomeClass]! = []
                var prop4_set_wasCalled = false
                var prop4_set_callCount = 0
                var prop4_set_args: [SomeClass]?
                var prop4: [SomeClass]! {
                    get {
                        prop4_get_wasCalled = true
                        prop4_get_callCount += 1
                        return prop4_get_val
                    }
                    set {
                        prop4_set_wasCalled = true
                        prop4_set_callCount += 1
                        prop4_set_args = newValue
                    }
                }
            }

            """
        )
    }
    
    func test_ClosurePatten() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol ClosurePattenProtocol {
                var arg1: (() -> Void)? { get }
                func func1(complesion: @escaping () -> Void)
                func func1(complesion: (() -> Void)?)
                func func1() -> (() -> Void)?
            }
            """),
            """
            class ClosurePattenSpy: ClosurePattenProtocol {
                var arg1_get_wasCalled = false
                var arg1_get_callCount = 0
                var arg1_get_val: (() -> Void)! = nil
                var arg1: (() -> Void)? {
                    get {
                        arg1_get_wasCalled = true
                        arg1_get_callCount += 1
                        return arg1_get_val
                    }
                }
                var func1_<#T##identifier1##identifier1#>_wasCalled = false
                var func1_<#T##identifier1##identifier1#>_callCount = 0
                var func1_<#T##identifier1##identifier1#>_args: (() -> Void)?
                func func1(complesion: @escaping () -> Void) {
                    func1_<#T##identifier1##identifier1#>_wasCalled = true
                    func1_<#T##identifier1##identifier1#>_callCount += 1
                    func1_<#T##identifier1##identifier1#>_args = complesion
                }

                var func1_<#T##identifier2##identifier2#>_wasCalled = false
                var func1_<#T##identifier2##identifier2#>_callCount = 0
                var func1_<#T##identifier2##identifier2#>_args: (() -> Void)?
                func func1(complesion: (() -> Void)?) {
                    func1_<#T##identifier2##identifier2#>_wasCalled = true
                    func1_<#T##identifier2##identifier2#>_callCount += 1
                    func1_<#T##identifier2##identifier2#>_args = complesion
                }

                var func1_<#T##identifier3##identifier3#>_wasCalled = false
                var func1_<#T##identifier3##identifier3#>_callCount = 0
                var func1_<#T##identifier3##identifier3#>_val: (() -> Void)! = nil
                func func1() -> (() -> Void)? {
                    func1_<#T##identifier3##identifier3#>_wasCalled = true
                    func1_<#T##identifier3##identifier3#>_callCount += 1
                    return func1_<#T##identifier3##identifier3#>_val
                }
            }

            """
        )
    }
    
    func test_InitPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol InitPatternProtocol {
                init()
                init(arg1: (() -> Void)?)
                init(arg1: @escaping () -> Void)
                init?(arg2: String)
                init?(arg2: (() -> Void, String))
                init?(arg3: String) throws
            }
            """),
            """
            class InitPatternSpy: InitPatternProtocol {
                var init_<#T##identifier1##identifier1#>_wasCalled = false
                var init_<#T##identifier1##identifier1#>_callCount = 0
                required init() {
                    init_<#T##identifier1##identifier1#>_wasCalled = true
                    init_<#T##identifier1##identifier1#>_callCount += 1
                }

                var init_<#T##identifier2##identifier2#>_wasCalled = false
                var init_<#T##identifier2##identifier2#>_callCount = 0
                var init_<#T##identifier2##identifier2#>_args: (() -> Void)?
                required init(arg1: (() -> Void)?) {
                    init_<#T##identifier2##identifier2#>_wasCalled = true
                    init_<#T##identifier2##identifier2#>_callCount += 1
                    init_<#T##identifier2##identifier2#>_args = arg1
                }

                var init_<#T##identifier3##identifier3#>_wasCalled = false
                var init_<#T##identifier3##identifier3#>_callCount = 0
                var init_<#T##identifier3##identifier3#>_args: (() -> Void)?
                required init(arg1: @escaping () -> Void) {
                    init_<#T##identifier3##identifier3#>_wasCalled = true
                    init_<#T##identifier3##identifier3#>_callCount += 1
                    init_<#T##identifier3##identifier3#>_args = arg1
                }

                var init_<#T##identifier4##identifier4#>_wasCalled = false
                var init_<#T##identifier4##identifier4#>_callCount = 0
                var init_<#T##identifier4##identifier4#>_args: String?
                required init?(arg2: String) {
                    init_<#T##identifier4##identifier4#>_wasCalled = true
                    init_<#T##identifier4##identifier4#>_callCount += 1
                    init_<#T##identifier4##identifier4#>_args = arg2
                }

                var init_<#T##identifier5##identifier5#>_wasCalled = false
                var init_<#T##identifier5##identifier5#>_callCount = 0
                var init_<#T##identifier5##identifier5#>_args: (() -> Void, String)?
                required init?(arg2: (() -> Void, String)) {
                    init_<#T##identifier5##identifier5#>_wasCalled = true
                    init_<#T##identifier5##identifier5#>_callCount += 1
                    init_<#T##identifier5##identifier5#>_args = arg2
                }

                var init_<#T##identifier6##identifier6#>_wasCalled = false
                var init_<#T##identifier6##identifier6#>_callCount = 0
                var init_<#T##identifier6##identifier6#>_args: String?
                required init?(arg3: String) throws {
                    init_<#T##identifier6##identifier6#>_wasCalled = true
                    init_<#T##identifier6##identifier6#>_callCount += 1
                    init_<#T##identifier6##identifier6#>_args = arg3
                }
            }

            """
        )
    }
    
    func test_PublicProtocolPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            public protocol ViewControllerProtocol {
                var textField: NSTextField { get set }
                func buttonDidClick(_ sender: NSButton)
            }
            """),
            """
            class ViewControllerSpy: ViewControllerProtocol {
                var textField_get_wasCalled = false
                var textField_get_callCount = 0
                var textField_get_val: NSTextField = <#T##NSTextField#>
                var textField_set_wasCalled = false
                var textField_set_callCount = 0
                var textField_set_args: NSTextField?
                var textField: NSTextField {
                    get {
                        textField_get_wasCalled = true
                        textField_get_callCount += 1
                        return textField_get_val
                    }
                    set {
                        textField_set_wasCalled = true
                        textField_set_callCount += 1
                        textField_set_args = newValue
                    }
                }
                var buttonDidClick_wasCalled = false
                var buttonDidClick_callCount = 0
                var buttonDidClick_args: NSButton?
                func buttonDidClick(_ sender: NSButton) {
                    buttonDidClick_wasCalled = true
                    buttonDidClick_callCount += 1
                    buttonDidClick_args = sender
                }
            }

            """
        )
    }
    
    func test_AttributeProtocolPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            public protocol AttributeProtocol {
                func exec(completion: @escaping (String) -> Void)
            }
            """),
            """
            class AttributeSpy: AttributeProtocol {
                var exec_wasCalled = false
                var exec_callCount = 0
                var exec_args: ((String) -> Void)?
                func exec(completion: @escaping (String) -> Void) {
                    exec_wasCalled = true
                    exec_callCount += 1
                    exec_args = completion
                }
            }

            """
        )
    }
    
    func test_ClassAvailabilityProtocolPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            @available(iOS 14.0, *)
            public protocol AttributeProtocol {
                func exec(completion: @escaping (String) -> Void)
            }
            """),
            """
            @available(iOS 14.0, *)
            class AttributeSpy: AttributeProtocol {
                var exec_wasCalled = false
                var exec_callCount = 0
                var exec_args: ((String) -> Void)?
                func exec(completion: @escaping (String) -> Void) {
                    exec_wasCalled = true
                    exec_callCount += 1
                    exec_args = completion
                }
            }

            """
        )
    }
    
    func test_MemberAvailabilityProtocolPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            public protocol AttributeProtocol {
                @available(iOS 14.0, *)
                func exec(completion: @escaping (String) -> Void) -> String
                @available(iOS 14.0, *)
                var prop: Int { get set }
            }
            """),
            """
            class AttributeSpy: AttributeProtocol {
                @available(iOS 14.0, *)
                var exec_wasCalled = false
                @available(iOS 14.0, *)
                var exec_callCount = 0
                @available(iOS 14.0, *)
                var exec_args: ((String) -> Void)?
                @available(iOS 14.0, *)
                var exec_val: String = ""
                @available(iOS 14.0, *)
                func exec(completion: @escaping (String) -> Void) -> String {
                    exec_wasCalled = true
                    exec_callCount += 1
                    exec_args = completion
                    return exec_val
                }

                @available(iOS 14.0, *)
                var prop_get_wasCalled = false
                @available(iOS 14.0, *)
                var prop_get_callCount = 0
                @available(iOS 14.0, *)
                var prop_get_val: Int = 0
                @available(iOS 14.0, *)
                var prop_set_wasCalled = false
                @available(iOS 14.0, *)
                var prop_set_callCount = 0
                @available(iOS 14.0, *)
                var prop_set_args: Int?
                @available(iOS 14.0, *)
                var prop: Int {
                    get {
                        prop_get_wasCalled = true
                        prop_get_callCount += 1
                        return prop_get_val
                    }
                    set {
                        prop_set_wasCalled = true
                        prop_set_callCount += 1
                        prop_set_args = newValue
                    }
                }
            }

            """
        )
    }
    
    func test_AttributedTupleArgsProtocolPattern() throws {
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol SampleProtocol {
                func func1(arg1: String, completion: @escaping () -> Void)
            }
            """),
            """
            class SampleSpy: SampleProtocol {
                var func1_wasCalled = false
                var func1_callCount = 0
                var func1_args:  (arg1: String, completion: () -> Void)?
                func func1(arg1: String, completion: @escaping () -> Void) {
                    func1_wasCalled = true
                    func1_callCount += 1
                    func1_args = (arg1, completion)
                }
            }

            """
        )
    }
    
    func test_OjbcDynamicOptionPattern() throws {
        Settings.shared.spySettings.setScene(scene: .kvc, value: false)
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol SampleProtocol {
                var prop1: String { get }
                func func1(arg1: String) -> UIViewController
                init()
            }
            """),
            """
            class SampleSpy: NSObject, SampleProtocol {
                @objc
                dynamic var prop1_get_wasCalled = false
                @objc
                dynamic var prop1_get_callCount = 0
                var prop1_get_val: String = ""
                var prop1: String {
                    get {
                        prop1_get_wasCalled = true
                        prop1_get_callCount += 1
                        return prop1_get_val
                    }
                }
                @objc
                dynamic var func1_wasCalled = false
                @objc
                dynamic var func1_callCount = 0
                var func1_args: String?
                var func1_val: UIViewController = UIViewController(nibName: nil, bundle: nil)
                func func1(arg1: String) -> UIViewController {
                    func1_wasCalled = true
                    func1_callCount += 1
                    func1_args = arg1
                    return func1_val
                }

                @objc
                dynamic var init_wasCalled = false
                @objc
                dynamic var init_callCount = 0
                required init() {
                    init_wasCalled = true
                    init_callCount += 1
                }
            }

            """
        )
    }
    
    func test_MultipleAttributesPattern() throws {
        Settings.shared.spySettings.setScene(scene: .kvc, value: false)
        XCTAssertEqual(
            try MockGenerater.expect(
            .spy,
            """
            protocol SampleProtocol {
                @available(iOS 14.0, *)
                var prop1: String { get }
                @available(iOS 14.0, *)
                func func1(arg1: String) -> UIViewController
                @available(iOS 14.0, *)
                init()
            }
            """),
            """
            class SampleSpy: NSObject, SampleProtocol {
                @available(iOS 14.0, *) @objc
                dynamic var prop1_get_wasCalled = false
                @available(iOS 14.0, *) @objc
                dynamic var prop1_get_callCount = 0
                @available(iOS 14.0, *)
                var prop1_get_val: String = ""
                @available(iOS 14.0, *)
                var prop1: String {
                    get {
                        prop1_get_wasCalled = true
                        prop1_get_callCount += 1
                        return prop1_get_val
                    }
                }
                @available(iOS 14.0, *) @objc
                dynamic var func1_wasCalled = false
                @available(iOS 14.0, *) @objc
                dynamic var func1_callCount = 0
                @available(iOS 14.0, *)
                var func1_args: String?
                @available(iOS 14.0, *)
                var func1_val: UIViewController = UIViewController(nibName: nil, bundle: nil)
                @available(iOS 14.0, *)
                func func1(arg1: String) -> UIViewController {
                    func1_wasCalled = true
                    func1_callCount += 1
                    func1_args = arg1
                    return func1_val
                }

                @available(iOS 14.0, *) @objc
                dynamic var init_wasCalled = false
                @available(iOS 14.0, *) @objc
                dynamic var init_callCount = 0
                @available(iOS 14.0, *)
                required init() {
                    init_wasCalled = true
                    init_callCount += 1
                }
            }

            """
        )
    }
}

extension MockGenerater {
    static func expect(_ mockType: MockType, _ txt: String) throws -> String {
        let sourceFile = try SyntaxParser.parse(source: txt)
        let generator = MockGenerater(mockType: mockType)
        generator.walk(sourceFile)
        return generator.mockClasses.first!.classDeclSyntax.description
    }
}
