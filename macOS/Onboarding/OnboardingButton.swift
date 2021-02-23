//
//  OnboardingButton.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/22.
//  
//

import AppKit

class OnboardingButton: NSButton {
    @objc dynamic var backgroundColor = NSColor.systemBlue
    
    override func awakeFromNib() {
        bezelStyle = .texturedSquare
        isBordered = false
        wantsLayer = true
        let attrString = NSAttributedString(
            string: attributedTitle.string,
            attributes: [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 16)
            ])
        attributedTitle = attrString
        layer?.cornerRadius = 4
        layer?.masksToBounds = true
    }

    override func updateLayer() {
        super.updateLayer()
        if isHighlighted {
            layer?.backgroundColor = backgroundColor.withAlphaComponent(0.8).cgColor
        } else {
            layer?.backgroundColor = backgroundColor.cgColor
        }
    }
}
