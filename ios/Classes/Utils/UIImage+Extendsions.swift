//
//  UIImae+Extendsions..swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 15/12/22.
//

import UIKit


extension UIImage {
    static func fromCurrentBundle(with named: String) -> UIImage? {
        let bundle = Bundle.getBundle(for: VideoConferenceViewController.self)
        if #available(iOS 13.0, *) {
            return UIImage(named: named, in: bundle, with: nil)
        } else {
            return UIImage(named: named, in: bundle, compatibleWith: nil)
        }
    }
}
