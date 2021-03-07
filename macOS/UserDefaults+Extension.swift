//
//  UserDefaults+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/24.
//  
//

import Foundation

extension UserDefaults {
    static var group: UserDefaults {
        if ProcessInfo.processInfo.environment["UNIT_TEST"] == "YES" {
            return UserDefaults.standard
        } else {
            return UserDefaults(
            suiteName: "R33Y42SDDR.kazuhiro.hayashi.DependencyInjectionHelperForXcode"
            )!
        }
    }
}

extension UserDefaults {
    var snippets: [InitSnippet] {
        get {
            let snippetData = data(forKey: "snippet") ?? Data()
            let decoder = JSONDecoder()
            return (try? decoder.decode([InitSnippet].self, from: snippetData)) ?? []
        }
        set {
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(newValue)
            set(encoded, forKey: "snippet")
        }
    }
}
