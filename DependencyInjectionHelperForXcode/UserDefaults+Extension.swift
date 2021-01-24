//
//  UserDefaults+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/24.
//  
//

import Foundation

extension UserDefaults {
    static var group = UserDefaults(
        suiteName: "xxxx.kazuhiro.hayashi.DependencyInjectionHelperForXcode"
    )!
}
