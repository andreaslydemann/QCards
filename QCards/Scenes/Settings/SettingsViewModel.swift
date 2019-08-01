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
        let enableTimerTrigger: Driver<Bool>
    }
    
    struct Output {
        let dismiss: Driver<Void>
        let timerEnabled: Driver<Bool>
    }
    
    private let useCase: SettingsUseCase
    private let navigator: SettingsNavigator
    
    init(useCase: SettingsUseCase, navigator: SettingsNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let dismiss = input.okTrigger
            .do(onNext: navigator.toCards)
        
        
        let initialValue = useCase.getSetting(of: "EnableTimerKey", defaultValue: false)
            .map { value in
                print("read value: ", value)
                return value }.asDriver(onErrorJustReturn: false)
        
        let valueAfterSaving = input.enableTimerTrigger.flatMap { value -> Driver<Bool> in
            print("value to save: ", value)
            return self.useCase
                .saveSetting(with: value, key: "EnableTimerKey")
                .map { value }
                .asDriver(onErrorJustReturn: !value)
        }.asDriver()
        
        let timerEnabled = Driver.merge(initialValue, valueAfterSaving)
            .asDriver(onErrorJustReturn: false)
        
        return Output(dismiss: dismiss, timerEnabled: timerEnabled)
    }
}
