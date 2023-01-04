//
//  String+Localization.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 15/12/22.
//

import Foundation


extension String {
    func localized() -> String {
        let langCode = UserDefaults.standard.string(forKey: "KEY_LANG_CODE") ??  Locale.current.languageCode
        let plugin_bundle = Bundle.getBundle(for: VideoConferenceViewController.self)
        guard let path = plugin_bundle.path(forResource: langCode, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else { return NSLocalizedString(self, bundle: plugin_bundle, comment: "") }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    func localizedWithFormat(_ arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments)
    }
}
