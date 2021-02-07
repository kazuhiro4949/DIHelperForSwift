//
//  String+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation

extension String {
    var wasCalled: String {
        self + "_wasCalled"
    }
    
    var callCount: String {
        self + "_callCount"
    }
    
    var args: String {
        self + "_args"
    }
    
    var val: String {
        self + "_val"
    }
}

extension String {
    var nsString: NSString {
        self as NSString
    }
    
    func replacingToVariableAllowedString() -> String {
        let trivialsRemovedParamListText = replacingOccurrences(
                of: "[\\n\\s\\t]",
                with: "",
                options: .regularExpression,
                range: self.range(of: self)
            )
        let encodedString = trivialsRemovedParamListText.replacingOccurrences(
            of: "[\\(\\)]",
            with: "$p",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        ).replacingOccurrences(
            of: "[\\[\\]]",
            with: "$b",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        ).replacingOccurrences(
            of: "[:]",
            with: "$k",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        ).replacingOccurrences(
            of: "[,]",
            with: "$c",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        )
        .replacingOccurrences(
            of: "[_]",
            with: "$u",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText))
        .replacingOccurrences(
            of: "[\\.]",
            with: "$d",
            options: .regularExpression,
            range: trivialsRemovedParamListText.range(of: trivialsRemovedParamListText)
        )
        return encodedString
    }
}
