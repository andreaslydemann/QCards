//
//  DecksNavigator.swift
//  QCards
//
//  Created by Andreas Lüdemann on 19/03/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import UIKit

protocol DecksNavigator {
    func toDecks()
}

class DefaultDecksNavigator: DecksNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider
    
    init(services: UseCaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }
    
    func toDecks() {
        let vc = DecksViewController()
        vc.viewModel = DecksViewModel(useCase: services.makeDecksUseCase(),
                                      navigator: self)
        navigationController.pushViewController(vc, animated: true)
    }
}
