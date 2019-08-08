//
//  Application.swift
//  QCards
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import Platform

final class Application {
    static let shared = Application()
    
    private let realmUseCaseProvider: Domain.UseCaseProvider
    
    private init() {
        self.realmUseCaseProvider = Platform.UseCaseProvider()
    }
    
    func configureMainInterface(in window: UIWindow) {
        let navigationController = NavigationController()
        
        let navigator = DefaultDecksNavigator(services: realmUseCaseProvider,
                                              navigationController: navigationController)
        
        window.rootViewController = navigationController
        
        navigator.toDecks()
    }
}
