//
//  PropClass1.swift
//  SampleCode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Foundation

class PropClass1 {
    public var prop1: String?
    let prop2 = ""
    var prop3: Int {
        get {
            return 1
        }
        set {
            
        }
    }
    var prop4: Double {
        return 1
    }
    var prop5: Float = 1 {
        didSet {
            
        }
    }
}
