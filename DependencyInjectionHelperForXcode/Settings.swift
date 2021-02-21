//
//  Settings.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/24.
//  
//

import Foundation

class Settings {
    enum Target: Int {
        case property
        case function
        case initilizer
    }
    
    class ProtocolSetting {
        enum Ignorance: Int {
            case storedProperty
            case computedGetterSetterProperty
            case function
            case initializer
            case internalMember
            case override
        }
        
        var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "nameFormat")
            }
        }
        
        func setIgnorance(ignorance: Ignorance, value: Bool) {
            UserDefaults.group.set(value, forKey: "ignorance\(ignorance.rawValue)")
        }
        
        func getIgnorance(ignorance: Ignorance) -> Bool {
            return UserDefaults.group.bool(forKey: "ignorance\(ignorance.rawValue)")
        }
    }
    
    class SpySetting: TargetProvider, NameProvider {

        enum Capture: Int {
            case calledOrNot
            case callCount
            case passedArgument
        }
        
        var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.nameFormat")
            }
        }
        
        var wasCalledFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.wasCalledFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.wasCalledFormat")
            }
        }
        
        var callCountFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.callCountFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.callCountFormat")
            }
        }
        
        var passedArgumentFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.passedArgumentFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.passedArgumentFormat")
            }
        }
        
        var returnValueFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.returnValueFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.returnValueFormat")
            }
        }
        
        func setTarget(target: Target, value: Bool) {
            UserDefaults.group.set(value, forKey: "SpySettings.target\(target.rawValue)")
        }
        
        func getTarget(target: Target) -> Bool {
            return UserDefaults.group.bool(forKey: "SpySettings.target\(target.rawValue)")
        }
        
        func setCapture(capture: Capture, value: Bool) {
            UserDefaults.group.set(value, forKey: "SpySettings.capture\(capture.rawValue)")
        }
        
        func getCapture(capture: Capture) -> Bool {
            return UserDefaults.group.bool(forKey: "SpySettings.capture\(capture.rawValue)")
        }
    }
    
    class DummySetting: NameProvider {
        var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "DummySettings.nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "DummySettings.nameFormat")
            }
        }
    }
    
    class StubSetting: NameProvider {
        var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "StubSettings.nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "StubSettings.nameFormat")
            }
        }
        
        
        var returnValueFormat: String? {
            get {
                UserDefaults.group.string(forKey: "StubSettings.returnValueFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "StubSettings.returnValueFormat")
            }
        }
    }
    
    static let shared = Settings()
    let protocolSettings = ProtocolSetting()
    let spySettings = SpySetting()
    let dummySettings = DummySetting()
    let stubSettings = StubSetting()
    
    func target(from mockType: MockType) -> TargetProvider? {
        switch mockType {
        case .spy:
            return SpySetting()
        case .stub:
            return DefaultFalseTarget()
        case .dummy:
            return DefaultFalseTarget()
        }
    }
    
    var indentationValue: Int {
        4
    }
}

struct DefaultFalseTarget: TargetProvider {
    func setTarget(target: Settings.Target, value: Bool) {
        
    }
    
    func getTarget(target: Settings.Target) -> Bool {
        false
    }
}

protocol NameProvider {
    var nameFormat: String? { get }
}

protocol TargetProvider {
    func setTarget(target: Settings.Target, value: Bool)
    func getTarget(target: Settings.Target) -> Bool
}
