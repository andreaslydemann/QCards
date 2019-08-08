//
//  NavigationController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 09/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return globalStatusBarStyle.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        
        themeService.rx
            .bind({ $0.action }, to: navigationBar.rx.tintColor)
            .bind({ $0.primary }, to: navigationBar.rx.barTintColor)
            .bind({ $0.statusBarStyle }, to: UIApplication.shared.rx.statusBarStyle)
            .bind({ [NSAttributedString.Key.foregroundColor: $0.activeTint] }, to: navigationBar.rx.titleTextAttributes)
            .bind({ [NSAttributedString.Key.foregroundColor: $0.activeTint] }, to: navigationBar.rx.largeTitleTextAttributes)
            .disposed(by: rx.disposeBag)
    }
}
