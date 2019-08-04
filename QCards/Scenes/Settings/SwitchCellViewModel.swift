//
//  SwitchCellViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 04/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class SwitchCellViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Bool>
    }
    
    struct Output {
        let isEnabled: Driver<Bool>
    }
    
    private let useCase: SettingsUseCase
    private let userDefaultsKey: String
    public let title: String
    
    init(useCase: SettingsUseCase, title: String, userDefaultsKey: String) {
        self.useCase = useCase
        self.title = title
        self.userDefaultsKey = userDefaultsKey
    }
    
    func transform(input: Input) -> Output {
        let initialValue = useCase.getSwitchSetting(of: userDefaultsKey, defaultValue: false)
            .map { $0 }.asDriver(onErrorJustReturn: false)
        
        let valueAfterSaving = input.trigger.flatMap { value -> Driver<Bool> in
            return self.useCase
                .saveSwitchSetting(with: value, key: self.userDefaultsKey)
                .map { value }
                .asDriver(onErrorJustReturn: !value)
            }.asDriver()
        
        let isEnabled = Driver.merge(initialValue, valueAfterSaving)
            .asDriver(onErrorJustReturn: false)
        
        return Output(isEnabled: isEnabled)
    }
}
