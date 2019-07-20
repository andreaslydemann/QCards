//
//  SettingsViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class SettingsViewModel: ViewModelType {
    
    struct Input {
        let okTrigger: Driver<Void>
    }
    
    struct Output {
        let dismiss: Driver<Void>
    }
    
    private let useCase: CardsUseCase
    private let navigator: SettingsNavigator
    
    init(useCase: CardsUseCase, navigator: SettingsNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let dismiss = input.okTrigger
            .do(onNext: navigator.toCards)
        
        return Output(dismiss: dismiss)
    }
}
