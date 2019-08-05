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
    private let services: UseCaseProvider
    
    init(services: UseCaseProvider, navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }
    
    func toDecks() {
        navigationController.dismiss(animated: true)
    }
    
    func toTimePerCard() {
        let vc = TimePerCardViewController()
        let navigator = DefaultTimePerCardNavigator(navigationController: navigationController)
        vc.viewModel = TimePerCardViewModel(useCase: services.makeSettingsUseCase(), navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
