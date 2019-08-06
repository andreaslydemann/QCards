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

    }
    
    struct Output {
        let timePerCard: Driver<Int>
    }
    
    private let useCase: SettingsUseCase
    private let navigator: SettingsNavigator
    private let userDefaultsKey: String
    
    init(useCase: SettingsUseCase, navigator: SettingsNavigator, userDefaultsKey: String) {
        self.useCase = useCase
        self.navigator = navigator
        self.userDefaultsKey = userDefaultsKey
    }
    
    func transform(input: Input) -> Output {
        let timePerCard = useCase.getTimeSetting(of: "TimePerCardKey", defaultValue: 0)
            .map { $0 }.asDriver(onErrorJustReturn: 0)

        return Output(timePerCard: timePerCard)
    }
}
