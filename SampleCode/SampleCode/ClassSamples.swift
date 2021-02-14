//
//  ClassSamples.swift
//  SampleCode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Foundation

class PropClass1 {
    var prop1: String?
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

class FunctionClass {
    func func1() {
        
    }
    
    func func2(arg: Int) {
        
    }
    
    
    func func3(arg: Int, arg2: String, arg3: () -> Void, arg4: (String, String)) {
        
    }
    
    
    func func4() -> String {
        ""
    }
    
    
    func func5() throws -> String {
        ""
    }
}

class InheritedClass: NSObject {
    
}

@objc class ObjcClass: NSObject {
    
}
