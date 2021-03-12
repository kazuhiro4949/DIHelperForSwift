//
//  SampleParsedSource.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/20.
//  
//

import Foundation

enum SampleParsedSource {
    static let classSample = """
                class SampleClass {
                    let prop1: String

                    init() {
                        prop1 = "prop1"
                    }

                    func func1() {
                      print(prop1)
                    }
                }
                """
    
    static let protocolSample = """
    protocol SampleProtocol {
        var prop1: String { get }
        func func1(arg1: String) -> Int
        func func2(arg1: String) -> UIViewController
        init()
    }
    """
}
