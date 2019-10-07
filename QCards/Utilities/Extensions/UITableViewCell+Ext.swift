//
//  UITableViewCell+Ext.swift
//  QCards
//
//  Created by Andreas Lüdemann on 07/10/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func createCustomCellDisclosureIndicator(chevronColor: UIColor = .lightGray) {
        if #available(iOS 13.0, *) {
            let chevronConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            guard let chevronImg = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)?.withTintColor(chevronColor, renderingMode: .alwaysTemplate) else { return }
            let chevron = UIImageView(image: chevronImg)
            chevron.tintColor = chevronColor

            //chevron view
            let accessoryViewHeight = self.frame.height
            let customDisclosureIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: accessoryViewHeight))
            customDisclosureIndicator.addSubview(chevron)

            //chevron constraints
            chevron.translatesAutoresizingMaskIntoConstraints = false
            chevron.trailingAnchor.constraint(equalTo: customDisclosureIndicator.trailingAnchor, constant: 0).isActive = true
            chevron.centerYAnchor.constraint(equalTo: customDisclosureIndicator.centerYAnchor).isActive = true

            //Assign the custom accessory view to the cell
            customDisclosureIndicator.backgroundColor = .clear
            self.accessoryView = customDisclosureIndicator
        } else {
            self.accessoryType = .disclosureIndicator
            self.accessoryView?.tintColor = chevronColor
        }
    }
}
