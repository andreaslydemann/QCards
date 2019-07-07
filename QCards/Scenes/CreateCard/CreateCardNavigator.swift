//
//  CreateCardNavigator.swift
//  QCards
//
//  Created by Andreas Lüdemann on 08/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import UIKit

protocol CreateCardNavigator {
    func toCards()
}

final class DefaultCreateCardNavigator: CreateCardNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toCards() {
        navigationController.dismiss(animated: true)
    }
}
