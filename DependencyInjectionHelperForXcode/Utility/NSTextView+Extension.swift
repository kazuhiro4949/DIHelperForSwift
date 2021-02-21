//
//  NSTextView+Extension.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/21.
//  
//

import AppKit

extension NSTextView {
    func makePlaceText() {
        font = NSFont.userFixedPitchFont(ofSize: 16)
        isRulerVisible = false
        isFieldEditor = false
        isRichText = false
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticLinkDetectionEnabled = false
        isContinuousSpellCheckingEnabled = false
        isGrammarCheckingEnabled = false
        isAutomaticDashSubstitutionEnabled = false
        isAutomaticDataDetectionEnabled = false
        isAutomaticSpellingCorrectionEnabled = false
        isAutomaticTextReplacementEnabled = false
        isIncrementalSearchingEnabled = false
        isAutomaticTextCompletionEnabled = false
    }
}
