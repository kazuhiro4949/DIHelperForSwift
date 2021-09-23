//
//  NSAttributedString+SyntaxSugar.swift
//  DIHelperforSwift
//
//  Created by kazuhiro2 on 2021/09/12.
//

import Cocoa

extension NSAttributedString {
    static func makeLink(_ url: URL) -> NSAttributedString {
        NSAttributedString(
            string: url.absoluteString,
            attributes: [
                .link: url,
                .font: NSFont.systemFont(ofSize: 12)
               
       ])
    }
}
