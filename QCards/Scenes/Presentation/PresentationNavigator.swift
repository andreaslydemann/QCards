//
//  PresentationNavigator.swift
//  QCards
//
//  Created by Andreas Lüdemann on 13/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import UIKit

protocol PresentationNavigator {
    func toCards()
}

final class DefaultPresentationNavigator: PresentationNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toCards() {
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        
        navigationController.view.layer.add(transition, forKey: nil)
        navigationController.popViewController(animated: false)
    }
}
