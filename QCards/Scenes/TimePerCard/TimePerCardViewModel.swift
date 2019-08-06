//
//  TimePerCardViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 05/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class TimePerCardViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let saveTrigger: Driver<Void>
        let selection: Driver<TimePerCardCellViewModel>
    }
    
    struct Output {
        let items: Driver<[TimePerCardCellViewModel]>
        let save: Driver<Void>
        let selectedOption: Driver<Int>
    }
    
    private let useCase: SettingsUseCase
    private let navigator: TimePerCardNavigator
    
    init(useCase: SettingsUseCase, navigator: TimePerCardNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
        let initialValue = useCase.getTimeSetting(of: "TimePerCardKey", defaultValue: 0)
            .map { $0 }.asDriver(onErrorJustReturn: 0)
        
        let selection = input.selection.map { $0.timeOption }.asDriver()
        
        let selectedOption = Driver.merge(initialValue, selection)
            .asDriver(onErrorJustReturn: 0)
        
        let save = input.saveTrigger.withLatestFrom(selectedOption)
            .flatMapLatest { option in
                return self.useCase.saveTimeSetting(with: option, key: "TimePerCardKey")
                    .asDriverOnErrorJustComplete()
            }.do(onNext: navigator.toSettings)
        
        let items = selectedOption.map { selectedOption -> [TimePerCardCellViewModel] in
            return TimePerCard.allValues.map({ timeOption -> TimePerCardCellViewModel in
                return TimePerCardCellViewModel(with: timeOption.rawValue,
                                                isSelected: timeOption.rawValue == selectedOption)
            })
        }
        
        return Output(items: items.asDriver(), save: save, selectedOption: selectedOption)
    }
}
