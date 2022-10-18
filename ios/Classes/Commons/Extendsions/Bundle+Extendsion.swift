//
//  Bundle+Extendsion.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import UIKit

extension Bundle {
    static func getBundle(for target: AnyClass) -> Bundle {
        let podBundle = Bundle(for: target)
        if let bundleUrl = podBundle.url(forResource: "ios_chime", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleUrl) {
                return bundle
            } else {
                fatalError("Could not load the bundle")
            }
        } else {
            fatalError("Could not load the bundle")
        }
    }
    
    static func getNib(for target: AnyClass, withName name: String) -> UINib {
        let bundle = Bundle.getBundle(for: target)
        return UINib(nibName: name, bundle: bundle)
    }
    
    static func image(classType: AnyClass, name: String) -> UIImage? {
        let bundle = Bundle.getBundle(for: classType)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
