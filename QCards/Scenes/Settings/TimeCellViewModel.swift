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
    
    struct Input { }
    
    struct Output {
        let timePerCard: Driver<Int>
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
        let timePerCard = useCase.getTimeSetting(of: K.UserDefaultsKeys.TimePerCardKey, defaultValue: 0)
            .map { $0 }.asDriver(onErrorJustReturn: 0)

        return Output(timePerCard: timePerCard)
    }
}
