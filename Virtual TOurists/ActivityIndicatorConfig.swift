//
//  ActivityIndicatorConfig.swift
//  Virtual TOurists
//
//  Created by Amarnath Manipatra on 14/05/17.
//  Copyright © 2017 otd. All rights reserved.
//

import Foundation

import UIKit
import Foundation

private var activityIndicator: ActivityIndicator?

protocol ActivityIndicatorDelegate {
    func showActivityIndicator()
    func hideActivityIndicator()
}

extension UIViewController: ActivityIndicatorDelegate {
    internal func showActivityIndicator() {
        if activityIndicator?.superview != nil {
            activityIndicator?.removeFromSuperview()
        }
        activityIndicator = ActivityIndicator(frame: UIScreen.screenBounds())
        activityIndicator?.activityIndicator.startAnimating()
        activityIndicator?.alpha = 1
        view.addSubview(activityIndicator!)
    }
    
    internal func showActivityIndicator(topField: CGFloat) {
        if activityIndicator?.superview != nil {
            activityIndicator?.removeFromSuperview()
        }
        activityIndicator = ActivityIndicator(frame: CGRect(x: 0,
                                                            y: 0 + topField,
                                                            width: UIScreen.screenWidth(),
                                                            height: UIScreen.screenHeight() - (0 + topField)))
        activityIndicator?.activityIndicator.startAnimating()
        activityIndicator?.alpha = 1
        view.addSubview(activityIndicator!)
    }
    
    internal func hideActivityIndicator() {
        activityIndicator?.activityIndicator.stopAnimating()
        Animations.hide(view: activityIndicator!, alpha: 0)
    }
}

extension UIScreen {
    static func screenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
    
    static func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
}

