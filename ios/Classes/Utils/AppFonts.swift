//
//  AppFonts.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 23/11/22.
//

import UIKit

struct AppFonts {
    static func font(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        var strWeight = "Regular"
        switch (weight) {
        case .medium:
            strWeight = "Medium"
        case .bold:
            strWeight = "Bold"
        case .semibold:
            strWeight = "SemiBold"
        default:
            break
        }
        
        return UIFont(name: "Poppins-\(strWeight)", size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
