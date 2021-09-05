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
    case mock
    
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
        case .mock:
            return Settings
                .shared
                .mockSettings
                .nameFormat ?? "%@Mock"
        }
    }
    
    public var wasCalledFormat: String? {
        switch self {
        case .dummy:
            return nil
        case .stub:
            return nil
        case .mock:
            return Settings
                .shared
                .mockSettings
                .wasCalledFormat
        }
    }
    
    public var callCountFormat: String? {
        switch self {
        case .dummy:
            return nil
        case .stub:
            return nil
        case .mock:
            return Settings
                .shared
                .mockSettings
                .callCountFormat
        }
    }
    
    public var argsFormat: String? {
        switch self {
        case .dummy:
            return nil
        case .stub:
            return nil
        case .mock:
            return Settings
                .shared
                .mockSettings
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
        case .mock:
            return Settings
                .shared
                .mockSettings
                .returnValueFormat
        }
    }
    
    public var supportingKVC: Bool {
        switch self {
        case .dummy:
            return false
        case .stub:
            return false
        case .mock:
            return !Settings
                .shared
                .mockSettings
                .getScene(scene: .kvc)
        }
    }
}
