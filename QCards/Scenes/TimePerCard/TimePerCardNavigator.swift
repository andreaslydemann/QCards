//
//  TimePerCardNavigator.swift
//  QCards
//
//  Created by Andreas Lüdemann on 05/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import UIKit

protocol TimePerCardNavigator {
    func toSettings()
}

final class DefaultTimePerCardNavigator: TimePerCardNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toSettings() {
        navigationController.popViewController(animated: true)
    }
}
