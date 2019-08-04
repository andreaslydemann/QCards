//
//  TimeCellViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 04/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class TimeCellViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    
    struct Output {
        //let timePerCard: Driver<Int>
        let showTimeOptions: Driver<Void>
    }
    
    private let useCase: SettingsUseCase
    private let navigator: SettingsNavigator
    private let userDefaultsKey: String
    public let timePerCard: Int = 0
    
    init(useCase: SettingsUseCase, navigator: SettingsNavigator, userDefaultsKey: String) {
        self.useCase = useCase
        self.navigator = navigator
        self.userDefaultsKey = userDefaultsKey
    }
    
    func transform(input: Input) -> Output {
        let showTimeOptions = input.trigger
            .do(onNext: navigator.toCards)
        
        return Output(showTimeOptions: showTimeOptions)
    }
}
