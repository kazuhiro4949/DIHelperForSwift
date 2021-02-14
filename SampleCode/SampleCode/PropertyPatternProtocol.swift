//
//  PropertyPatternProtocol.swift
//  SampleCode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//
//

import Foundation

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



