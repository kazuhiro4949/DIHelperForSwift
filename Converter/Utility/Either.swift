//
//  Either.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//
//

import Foundation

public enum Either<First, Second> {
    case first(First), second(Second)
    
    public init(_ first: First) {
        self = .first(first)
    }
    
    public init(_ second: Second) {
        self = .second(second)
    }
}
