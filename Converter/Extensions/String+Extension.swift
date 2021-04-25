//
//  String+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//
//

import Foundation

extension String {
    public func wasCalled(_ mockType: MockType) -> String {
        String(format: (mockType.wasCalledFormat ?? "%@_wasCalled"), self)
    }
    
    public func callCount(_ mockType: MockType) -> String {
        String(format: (mockType.callCountFormat ?? "%@_callCount"), self)
    }
    
    public func args(_ mockType: MockType) -> String {
        String(format: (mockType.argsFormat ??  "%@_args"), self)
    }
    
    public func val(_ mockType: MockType) -> String {
        String(format: (mockType.returnValueFormat ??  "%@_val"), self)
    }
}

extension String {
    public var nsString: NSString {
        self as NSString
    }
    
    public func replacingToVariableAllowedString() -> String {
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
