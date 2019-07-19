//
//  SettingsNavigator.swift
//  QCards
//
//  Created by Andreas Lüdemann on 17/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import UIKit

protocol SettingsNavigator {
    func toCards()
}

final class DefaultSettingsNavigator: SettingsNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toCards() {
        navigationController.popViewController(animated: false)
    }
}
