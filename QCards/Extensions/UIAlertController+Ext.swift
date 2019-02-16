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
    
    struct AlertText {
        let title: String?
        let message: String?
    }
    
    struct AlertAction {
        var title: String?
        var style: UIAlertAction.Style
        
        static func action(title: String?, style: UIAlertAction.Style = .default) -> AlertAction {
            return AlertAction(title: title, style: style)
        }
    }
    
    static func present(
        in viewController: UIViewController,
        text: AlertText?,
        style: UIAlertController.Style,
        actions: [AlertAction],
        textFields: [UITextField])
        -> Observable<(Int, [String])> {
        return Observable.create { observer in
            let alertController = UIAlertController(title: text?.title, message: text?.message, preferredStyle: style)
            
            textFields.enumerated().forEach { args in
                var (_, textField) = args
                alertController.addTextField { field in
                    field.placeholder = textField.placeholder
                    textField = field
                }
            }
            
            actions.enumerated().forEach { index, action in
                let action = UIAlertAction(title: action.title, style: action.style) { _ in
                    let inputText = alertController.textFields?.map({ textField in
                        return textField.text ?? ""
                    })
                    
                    observer.onNext((index, inputText ?? []))
                    observer.onCompleted()
                }
                
                alertController.addAction(action)
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
