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
