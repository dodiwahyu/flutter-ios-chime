//
//  String+Localization.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 15/12/22.
//

import Foundation


extension String {
    func localized() -> String {
        let bundle = Bundle.getBundle(for: VideoConferenceViewController.self)
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    func localizedWithFormat(_ arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments)
    }
}
