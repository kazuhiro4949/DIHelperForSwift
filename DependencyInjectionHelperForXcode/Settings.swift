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
        }
        
        var nameFormat: String {
            get {
                UserDefaults.group.string(forKey: "nameFormat") ?? "%@Protocol"
            }
            set {
                UserDefaults.group.set(newValue, forKey: "nameFormat")
            }
        }
        
        var ignorance: Ignorance? {
            get {
                let rawValue = UserDefaults.group.integer(forKey: "ignorance")
                return Ignorance(rawValue: rawValue)
            }
            set {
                UserDefaults.group.set(newValue?.rawValue, forKey: "ignorance")
            }
        }
    }
    
    static let shared = Settings()
    let protocolSettings = ProtocolSetting()
}
