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
    
    class DummySetting: NameProvider, TargetProvider {
        var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "StubSettings.nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "DummySettings.nameFormat")
            }
        }
        
        func getTarget(target: Settings.Target) -> Bool {
            false
        }
        
        func setTarget(target: Settings.Target, value: Bool) {}
    }
    
    static let shared = Settings()
    let protocolSettings = ProtocolSetting()
    let spySettings = SpySetting()
    let dummySettings = DummySetting()
    
    func target(from mockType: MockType) -> TargetProvider {
        switch mockType {
        case .spy:
            return SpySetting()
        case .stub:
            return DummySetting()
        case .dummy:
            return DummySetting()
        }
    }
    
    var indentationValue: Int {
        4
    }
}

protocol NameProvider {
    var nameFormat: String? { get }
}

protocol TargetProvider {
    func setTarget(target: Settings.Target, value: Bool)
    func getTarget(target: Settings.Target) -> Bool
}
