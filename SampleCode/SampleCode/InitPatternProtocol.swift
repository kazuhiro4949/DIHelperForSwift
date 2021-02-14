//
//  InitPatternProtocol.swift
//  SampleCode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Foundation

protocol InitPatternProtocol {
    init()
    init(arg1: (() -> Void)?)
    init(arg1: @escaping () -> Void)
    init?(arg2: String)
    init?(arg2: (() -> Void, String))
    init?(arg3: String) throws
}
