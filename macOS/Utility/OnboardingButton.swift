//
//  OnboardingButton.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/22.
//  
//

import AppKit

class OnboardingButton: NSButton {
    var titleColor = NSColor.white
    var normalBackgroundColor = NSColor.systemBlue
    var highlightBackgroundColor = NSColor.highlightColor
    
    override func awakeFromNib() {
        bezelStyle = .texturedSquare
        isBordered = false
        wantsLayer = true
        let attrString = NSAttributedString(
            string: attributedTitle.string,
            attributes: [
                .foregroundColor: titleColor,
                .font: NSFont.systemFont(ofSize: 16)
            ])
        attributedTitle = attrString
        layer?.backgroundColor = NSColor.systemBlue.cgColor
        layer?.cornerRadius = 4
        layer?.masksToBounds = true
    }

    override func updateLayer() {
        super.updateLayer()
        if isHighlighted {
            layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.8).cgColor
        } else {
            layer?.backgroundColor = NSColor.systemBlue.cgColor
        }
    }
}
