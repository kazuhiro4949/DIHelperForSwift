//
//  MockType.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/07.
//  
//

import Foundation

public enum MockType: String {
    case dummy
    case stub
    case spy
    
    public var format: String {
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
    
    public var wasCalledFormat: String? {
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
    
    public var callCountFormat: String? {
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
    
    public var argsFormat: String? {
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
    
    public var returnValueFormat: String? {
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
    
    public var supportingKVC: Bool {
        switch self {
        case .dummy:
            return false
        case .stub:
            return false
        case .spy:
            return !Settings
                .shared
                .spySettings
                .getScene(scene: .kvc)
        }
    }
}
