//
//  EditCardNavigator.swift
//  QCards
//
//  Created by Andreas Lüdemann on 11/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import UIKit

protocol EditCardNavigator {
    func toCards()
}

final class DefaultEditCardNavigator: EditCardNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toCards() {
        navigationController.popViewController(animated: true)
    }
}
