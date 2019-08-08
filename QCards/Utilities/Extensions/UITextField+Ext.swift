//
//  UITextField+Ext.swift
//  QCards
//
//  Created by Andreas Lüdemann on 09/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import UIKit

extension UITextField {
    func setPlaceHolderTextColor(_ color: UIColor) {
        guard let holder = placeholder, !holder.isEmpty else { return }
        attributedPlaceholder = NSAttributedString(string: holder, attributes: [.foregroundColor: color])
    }
}
