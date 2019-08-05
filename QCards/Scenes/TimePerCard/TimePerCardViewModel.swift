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
    }
    
    //private var currentSelection: BehaviorRelay<Int>
    private let useCase: SettingsUseCase
    private let navigator: TimePerCardNavigator
    
    init(useCase: SettingsUseCase, navigator: TimePerCardNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
    
    func transform(input: Input) -> Output {
        
        let items = input.trigger.map({ () -> [TimePerCardCellViewModel] in
            return self.iterateEnum(TimePerCard.self).map({ timeOption -> TimePerCardCellViewModel in
                return TimePerCardCellViewModel(with: timeOption.rawValue)
            })
        })
        
        let initialValue = useCase.getTimeSetting(of: "TimePerCardKey")
            .map { $0 }.asDriver(onErrorJustReturn: 0)
        
        let selection = input.selection.map { cellViewModel in
            // self.currentSelection.accept(cellViewModel.timeOption)
            return cellViewModel.timeOption
        }.asDriver()
        
        let selectedOption = Driver.merge(initialValue, selection)
            .asDriver(onErrorJustReturn: 0)
        
        let save = input.saveTrigger.withLatestFrom(selectedOption).map { option in
                return self.useCase.saveTimeSetting(with: option, key: "TimePerCardKey")
            }.mapToVoid().do(onNext: navigator.toSettings)
        
        return Output(items: items.asDriver(), save: save)
    }
}
