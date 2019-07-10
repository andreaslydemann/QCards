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
    func toCreateCard(_ deck: Deck)
}

class DefaultCardsNavigator: CardsNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider
    
    init(services: UseCaseProvider, navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }
    
    func toDecks() {
        navigationController.dismiss(animated: true)
    }
    
    func toCreateCard(_ deck: Deck) {
        let navigator = DefaultCreateCardNavigator(navigationController: navigationController)
        let vc = CreateCardViewController()
        vc.viewModel = CreateCardViewModel(deck: deck, useCase: services.makeCardsUseCase(), navigator: navigator)
        let nc = UINavigationController(rootViewController: vc)
        navigationController.present(nc, animated: true, completion: nil)
    }
}
