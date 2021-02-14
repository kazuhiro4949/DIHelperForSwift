//
//  MockType.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation

enum MockType: String {
    case dummy
    case stub
    case spy
    
    var format: String {
        switch self {
        case .dummy:
            return "%@Dummy"
        case .stub:
            return "%@Stub"
        case .spy:
            return Settings
                .shared
                .spySettings
                .nameFormat ?? "%@Spy"
        }
    }
}
