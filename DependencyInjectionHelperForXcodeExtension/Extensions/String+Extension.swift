//
//  String+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation

extension String {
    func wasCalled(_ mockType: MockType) -> String {
        String(format: (mockType.wasCalledFormat ?? "%@_wasCalled"), self)
    }
    
    func callCount(_ mockType: MockType) -> String {
        String(format: (mockType.callCountFormat ?? "%@_callCount"), self)
    }
    
    func args(_ mockType: MockType) -> String {
        String(format: (mockType.argsFormat ??  "%@_args"), self)
    }
    
    func val(_ mockType: MockType) -> String {
        String(format: (mockType.returnValueFormat ??  "%@_val"), self)
    }
}

extension String {
    var nsString: NSString {
        self as NSString
    }
    
    func replacingToVariableAllowedString() -> String {
        var encodedString = replacingOccurrences(
                of: "[\\n\\s\\t]",
                with: "",
                options: .regularExpression,
                range: self.range(of: self)
            )
        encodedString = encodedString.replacingOccurrences(
            of: "[\\(\\)]",
            with: "$p",
            options: .regularExpression,
            range: encodedString.range(of: encodedString)
        )
        encodedString = encodedString.replacingOccurrences(
            of: "[\\[\\]]",
            with: "$b",
            options: .regularExpression,
            range: encodedString.range(of: encodedString)
        )
        encodedString = encodedString.replacingOccurrences(
            of: ":",
            with: "$k",
            options: [],
            range: encodedString.range(of: encodedString)
        )
        encodedString = encodedString.replacingOccurrences(
            of: ",",
            with: "$c",
            options: [],
            range: encodedString.range(of: encodedString)
        )
        encodedString = encodedString.replacingOccurrences(
            of: "_",
            with: "$u",
            options: [],
            range: encodedString.range(of: encodedString))
        encodedString = encodedString.replacingOccurrences(
            of: ".",
            with: "$d",
            options: [],
            range: encodedString.range(of: encodedString)
        )
        encodedString = encodedString.replacingOccurrences(
            of: "-",
            with: "$h",
            options: [],
            range: encodedString.range(of: encodedString)
        )
        encodedString = encodedString.replacingOccurrences(
            of: ">",
            with: "$s",
            options: [],
            range: encodedString.range(of: encodedString)
        )
        encodedString = encodedString.replacingOccurrences(
            of: "@",
            with: "$a",
            options: [],
            range: encodedString.range(of: encodedString)
        )
        return encodedString
    }
}
