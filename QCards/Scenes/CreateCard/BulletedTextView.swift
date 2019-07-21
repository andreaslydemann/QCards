//
//  BulletedTextView.swift
//  QCards
//
//  Created by Andreas Lüdemann on 21/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import UIKit

class BulletedTextView: UITextView {
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        frame = newSuperview?.frame.insetBy(dx: 26, dy: 355) ?? frame
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange),
                                               name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func textViewDidChange(notification: Notification) {
        var lines: [String] = []
        let bullet = "\u{2022}"
        let textComponents = text.components(separatedBy: .newlines).enumerated()
        
        for (_, line) in textComponents {
            if line.contains("*") {
                let noAsterisk = line.replacingOccurrences(of: "*", with: "")
                let noMultibleBullets = noAsterisk.replacingOccurrences(of: bullet, with: "")
                lines.append(noMultibleBullets + "\(bullet)  ")
            } else {
                lines.append(line)
            }
        }
        
        text = lines.joined(separator: "\n")
    }
}
