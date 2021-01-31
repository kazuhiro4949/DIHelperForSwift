//
//  Settings.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/24.
//  
//

import Foundation

class Settings {
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
    
    class SpySetting {
        enum Target: Int {
            case property
            case function
            case initilizer
        }
        
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
    
    static let shared = Settings()
    let protocolSettings = ProtocolSetting()
    let spySettings = SpySetting()
    var indentationValue: Int {
        4
    }
}
