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
            return Settings
                .shared
                .dummySettings
                .nameFormat ?? "%@Dummy"
        case .stub:
            return Settings
                .shared
                .stubSettings
                .nameFormat ?? "%@Stub"
        case .spy:
            return Settings
                .shared
                .spySettings
                .nameFormat ?? "%@Spy"
        }
    }
    
    var wasCalledFormat: String? {
        switch self {
        case .dummy:
            return nil
        case .stub:
            return nil
        case .spy:
            return Settings
                .shared
                .spySettings
                .wasCalledFormat
        }
    }
    
    var callCountFormat: String? {
        switch self {
        case .dummy:
            return nil
        case .stub:
            return nil
        case .spy:
            return Settings
                .shared
                .spySettings
                .callCountFormat
        }
    }
    
    var argsFormat: String? {
        switch self {
        case .dummy:
            return nil
        case .stub:
            return nil
        case .spy:
            return Settings
                .shared
                .spySettings
                .passedArgumentFormat
        }
    }
    
    var returnValueFormat: String? {
        switch self {
        case .dummy:
            return nil
        case .stub:
            return Settings
                .shared
                .stubSettings
                .returnValueFormat
        case .spy:
            return Settings
                .shared
                .spySettings
                .returnValueFormat
        }
    }
}
