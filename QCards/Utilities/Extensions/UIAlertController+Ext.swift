//
//  UIAlertController+Ext.swift
//  QCards
//
//  Created by Andreas Lüdemann on 14/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxSwift
import UIKit

extension UIAlertController {
    
    public typealias TextFieldConfiguration = ((UITextField) -> Void)
    
    public enum AlertButton {
        case `default`(String, String)
        case disabled(String, String)
        case cancel(String, String)
        case destructive(String, String)
    }
    
    struct AlertText {
        let title: String?
        let message: String?
    }
    
    static func present(
        in viewController: UIViewController,
        text: AlertText?,
        style: Style,
        buttons: [AlertButton],
        textFields: [TextFieldConfiguration?])
        -> Observable<(buttonIndex: Int, texts: [String])> {
        return Observable.create { observer in
            let alertController = UIAlertController(title: text?.title, message: text?.message, preferredStyle: style)
            
            buttons.enumerated().forEach { buttonIndex, action in
                let handler = { [unowned alertController] (action: UIAlertAction) -> Void in
                    let texts: [String] = alertController.textFields?.map { $0.text ?? "" } ?? []
                    
                    observer.onNext((buttonIndex, texts))
                    observer.onCompleted()
                }
                
                let action: UIAlertAction
                switch buttons[buttonIndex] {
                case .default(let title, let accessibilityLabel):
                    action = UIAlertAction(title: title, style: .default, handler: handler)
                    action.accessibilityLabel = accessibilityLabel
                case .cancel(let title, let accessibilityLabel):
                    action = UIAlertAction(title: title, style: .cancel, handler: handler)
                    action.accessibilityLabel = accessibilityLabel
                case .destructive(let title, let accessibilityLabel):
                    action = UIAlertAction(title: title, style: .destructive, handler: handler)
                    action.accessibilityLabel = accessibilityLabel
                case .disabled(let title, let accessibilityLabel):
                    action = UIAlertAction(title: title, style: .default, handler: handler)
                    action.accessibilityLabel = accessibilityLabel
                    action.isEnabled = false
                }
                
                alertController.addAction(action)
            }
            
            for textField in textFields {
                alertController.addTextField(configurationHandler: textField)
            }
            
            viewController.present(alertController, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: alertController, action: #selector(self.dismissAlertController))
                alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
            
            return Disposables.create { alertController.dismiss(animated: true, completion: nil) }
        }
    }
    
    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
}
