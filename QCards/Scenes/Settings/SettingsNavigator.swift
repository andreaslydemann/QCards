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
    func toDecks()
    func toTimePerCard()
}

final class DefaultSettingsNavigator: SettingsNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toDecks() {
        navigationController.dismiss(animated: true)
    }
    
    func toTimePerCard() {
        //let navigator = DefaultEditCardNavigator(navigationController: navigationController)
        let vc = TimePerCardViewController()
        
        //vc.viewModel = EditCardViewModel(card: card, useCase: services.makeCardsUseCase(), navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
