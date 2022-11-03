//
//  UIColor+Extendsion.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 18/10/22.
//

import Foundation


extension UIColor {
    
    /**
     Initialization `UIColor` with RGB value
     - Parameter red: `Int` value in the range between 0-255
     - Parameter green: `Int` value in the range between 0-255
     - Parameter blue: `Int` value in the range between 0-255
     - Parameter a: `CGFloat` value in the range between 0.0-1.0
     */
    convenience init(red: Int, green: Int, blue: Int,a: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }
    
    /**
     Initialization `UIColor` from hex value
     - Parameter rgba: `HEX` exp: 0xFFFFFFFF
     */
    convenience init(_ rgba: Int) {
        self.init(
            red: (rgba >> 16) & 0xFF,
            green: (rgba >> 8) & 0xFF,
            blue: rgba & 0xFF,
            a: CGFloat((rgba >> 24) & 0xFF)
        )
    }
}
