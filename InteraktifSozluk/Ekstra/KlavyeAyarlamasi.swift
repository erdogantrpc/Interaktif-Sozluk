//
//  KlavyeAyarlamasi.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 13.03.2021.
//

import Foundation
import UIKit

extension UIView {
    
    func klavyeAyarla() {
        NotificationCenter.default.addObserver(self, selector: #selector(klavyeKonumAyarla(_ :)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
    @objc func klavyeKonumAyarla(_ notification : NSNotification) {
        let sure = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let baslangicFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let bitisFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let farkY = bitisFrame.origin.y - baslangicFrame.origin.y
        UIView.animateKeyframes(withDuration: sure, delay: 0.0, options: UIView.KeyframeAnimationOptions.init(rawValue: curve), animations: {
            self.frame.origin.y += farkY
        }, completion: nil)
    }
    
}
