//
//  CardsNavigator.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import UIKit

protocol CardsNavigator {
    func toDecks()
}

class DefaultCardsNavigator: CardsNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toDecks() {
        navigationController.dismiss(animated: true)
    }
}
