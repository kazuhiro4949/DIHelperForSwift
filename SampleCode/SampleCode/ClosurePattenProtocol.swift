//
//  ClosurePattenProtocol.swift
//  SampleCode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Foundation

protocol ClosurePattenProtocol {
    var arg1: (() -> Void)? { get }
    func func1(complesion: @escaping () -> Void)
    func func1(complesion: (() -> Void)?)
    func func1() -> (() -> Void)?
}

