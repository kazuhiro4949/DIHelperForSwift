//
//  Samples.swift
//  SampleCode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Foundation
class SomeClass {}

protocol FunctionsPattern1Protocol {
    func func1()
    func func2() -> Int
    func func3(_ arg1: String, arg2: Int) -> Int
    func func4() throws -> String
}

protocol FunctionsPattern2Protocol {
    func func1() -> String
    func func2(arg: String)
    func func3(arg: Int) -> String
    func func4(_ arg: Int) -> String
    func func5(for arg1: String, arg2: Int) -> Int
}

protocol FunctionsPattern3Protocol {
    func func1(arg: Int8) -> Int8
    func func2(arg: Int16) -> Int16
    func func3(arg: Int32) -> Int32
    func func4(arg: Int64) -> Int64
    func func5(arg: Float) -> Float
    func func6(arg: Float32) -> Float32
    func func7(arg: Float64) -> Float64
    func func8(arg: Double) -> Double
    func func9(arg: CGFloat) -> CGFloat
    func func10(arg: [String]) -> [String]
    func func11(arg: [String: String]) -> [String: String]
    func func12(arg: (String, String)) -> (String, String)
    func func13(arg: SomeClass) -> SomeClass
}

protocol FunctionsPattern4Protocol {
    func func1()
    func func1() -> Int
    func func1(_ arg1: String, arg2: Int) -> Int
    func func1() throws -> String
}

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

protocol ClosurePattenProtocol {
    var arg1: (() -> Void)? { get }
    func func1(complesion: @escaping () -> Void)
    func func1(complesion: (() -> Void)?)
    func func1() -> (() -> Void)?
}

protocol InitPatternProtocol {
    init()
    init(arg1: (() -> Void)?)
    init(arg1: @escaping () -> Void)
    init?(arg2: String)
    init?(arg2: (() -> Void, String))
    init?(arg3: String) throws
}






