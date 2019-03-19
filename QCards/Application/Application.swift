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
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //let navigationController = UINavigationController()
        
        //let navigator = DefaultPostsNavigator(services: realmUseCaseProvider,
        //                                      navigationController: navigationController,
        //                                      storyBoard: storyboard)
        
        //window.rootViewController = navigationController
        
        //navigator.toPosts()
    }
}
