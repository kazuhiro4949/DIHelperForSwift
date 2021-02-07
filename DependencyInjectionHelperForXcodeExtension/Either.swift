//
//  Either.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation

enum Either<First, Second> {
    case first(First), second(Second)
    
    init(_ first: First) {
        self = .first(first)
    }
    
    init(_ second: Second) {
        self = .second(second)
    }
}
