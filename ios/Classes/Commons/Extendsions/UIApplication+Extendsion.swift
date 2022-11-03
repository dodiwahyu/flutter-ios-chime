//
//  UIApplication+Extendsion.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import UIKit
extension UIApplication {
    
    /**
     Get the most top of view controller from controlles stack
     */
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
