//
//  Settings.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/24.
//  
//

import Foundation

public class Settings {
    public enum Target: Int {
        case property
        case function
        case initilizer
    }
    
    public class ProtocolSetting {
        public enum Ignorance: Int {
            case storedProperty
            case computedGetterSetterProperty
            case function
            case initializer
            case internalMember
            case override
        }
        
        public var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "nameFormat")
            }
        }
        
        public func setIgnorance(ignorance: Ignorance, value: Bool) {
            UserDefaults.group.set(value, forKey: "ignorance\(ignorance.rawValue)")
        }
        
        public func getIgnorance(ignorance: Ignorance) -> Bool {
            return UserDefaults.group.bool(forKey: "ignorance\(ignorance.rawValue)")
        }
    }
    
    public class SpySetting: TargetProvider, NameProvider {
        public enum Scene: Int {
            case kvc
        }
        
        public enum Capture: Int {
            case calledOrNot
            case callCount
            case passedArgument
        }
        
        public var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.nameFormat")
            }
        }
        
        public var wasCalledFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.wasCalledFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.wasCalledFormat")
            }
        }
        
        public var callCountFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.callCountFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.callCountFormat")
            }
        }
        
        public var passedArgumentFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.passedArgumentFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.passedArgumentFormat")
            }
        }
        
        public var returnValueFormat: String? {
            get {
                UserDefaults.group.string(forKey: "SpySettings.returnValueFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "SpySettings.returnValueFormat")
            }
        }
        
        public func setTarget(target: Target, value: Bool) {
            UserDefaults.group.set(value, forKey: "SpySettings.target\(target.rawValue)")
        }
        
        public func getTarget(target: Target) -> Bool {
            return UserDefaults.group.bool(forKey: "SpySettings.target\(target.rawValue)")
        }
        
        public func setCapture(capture: Capture, value: Bool) {
            UserDefaults.group.set(value, forKey: "SpySettings.capture\(capture.rawValue)")
        }
        
        public func getCapture(capture: Capture) -> Bool {
            return UserDefaults.group.bool(forKey: "SpySettings.capture\(capture.rawValue)")
        }
        
        public func setScene(scene: Scene, value: Bool) {
            UserDefaults.group.set(value, forKey: "SpySettings.scene\(scene.rawValue)")
        }
        
        public func getScene(scene: Scene) -> Bool {
            return UserDefaults.group.bool(forKey: "SpySettings.scene\(scene.rawValue)")
        }
    }
    
    public class DummySetting: NameProvider {
        public var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "DummySettings.nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "DummySettings.nameFormat")
            }
        }
    }
    
    public class StubSetting: NameProvider {
        public var nameFormat: String? {
            get {
                UserDefaults.group.string(forKey: "StubSettings.nameFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "StubSettings.nameFormat")
            }
        }
        
        
        public var returnValueFormat: String? {
            get {
                UserDefaults.group.string(forKey: "StubSettings.returnValueFormat")
            }
            set {
                UserDefaults.group.set(newValue, forKey: "StubSettings.returnValueFormat")
            }
        }
    }
    
    public static let shared = Settings()
    public let protocolSettings = ProtocolSetting()
    public let spySettings = SpySetting()
    public let dummySettings = DummySetting()
    public let stubSettings = StubSetting()
    
    public func target(from mockType: MockType) -> TargetProvider? {
        switch mockType {
        case .spy:
            return SpySetting()
        case .stub:
            return DefaultFalseTarget()
        case .dummy:
            return DefaultFalseTarget()
        }
    }
    
    public var indentationValue: Int {
        4
    }
}

public struct DefaultFalseTarget: TargetProvider {
    public func setTarget(target: Settings.Target, value: Bool) {
        
    }
    
    public func getTarget(target: Settings.Target) -> Bool {
        false
    }
}

public protocol NameProvider {
    var nameFormat: String? { get }
}

public protocol TargetProvider {
    func setTarget(target: Settings.Target, value: Bool)
    func getTarget(target: Settings.Target) -> Bool
}
