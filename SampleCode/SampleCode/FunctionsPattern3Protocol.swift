//
//  FunctionsPattern3Protocol.swift
//  SampleCode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Foundation


protocol FunctionsPattern3Protocol {
    func func1(arg: Int8) -> Int8
    func func3(arg: Int32) -> Int32
    func func4(arg: Int64) -> Int64
    func func5(arg: Float) -> Float
    func func7(arg: Float64) -> Float64
    func func8(arg: Double) -> Double
    func func9(arg: CGFloat) -> CGFloat
}


protocol FunctionsPattern6Protocol {
    func func2(arg: Int16) -> Int16
    func func6(arg: Float32) -> Float32
}

protocol FunctionsPattern7Protocol {
    func func10(arg: [String]) -> [String]
    func func11(arg: [String: String]) -> [String: String]
    func func12(arg: (String, String)) -> (String, String)
    func func13(arg: SomeClass) -> SomeClass
}
