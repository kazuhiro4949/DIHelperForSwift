//
//  UIStoryboard+SyntaxSugar.swift
//  DIHelperforSwift
//
//  Created by kazuhiro2 on 2021/09/12.
//

import Cocoa

extension NSStoryboard {
    func instantiate<T: NSViewController>(_ type: T.Type) -> T? {
        if let name = NSStringFromClass(type).components(separatedBy: ".").last {
            return instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier(name)
            ) as? T
        }
        return nil
    }

}
