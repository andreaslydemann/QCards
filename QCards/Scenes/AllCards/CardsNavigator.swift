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
    func toEditCard(_ card: Card)
    func toPresentation(_ cards: [Card])
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
    
    func toEditCard(_ card: Card) {
        let navigator = DefaultEditCardNavigator(navigationController: navigationController)
        let vc = EditCardViewController()
        vc.viewModel = EditCardViewModel(card: card, useCase: services.makeCardsUseCase(), navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toPresentation(_ cards: [Card]) {
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        navigationController.view.layer.add(transition, forKey: nil)
        
        let navigator = DefaultPresentationNavigator(navigationController: navigationController)
        let vc = PresentationViewController()
        vc.viewModel = PresentationViewModel(cards: cards, cardsUseCase: services.makeCardsUseCase(), settingsUseCase: services.makeSettingsUseCase(), navigator: navigator)
        
        navigationController.pushViewController(vc, animated: false)
    }
}
