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
        let trigger: Driver<Void>
        let okTrigger: Driver<Void>
        let selection: Driver<SettingsSectionItem>
    }
    
    struct Output {
        let dismiss: Driver<Void>
        let items: Driver<[SettingsSection]>
        let selectedEvent: Driver<SettingsSectionItem>
    }
    
    private let useCase: SettingsUseCase
    private let navigator: SettingsNavigator
    
    init(useCase: SettingsUseCase, navigator: SettingsNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let dismiss = input.okTrigger
            .do(onNext: navigator.toDecks)
        
        let timePerCardViewModel = TimeCellViewModel(useCase: useCase, title: "Time per card", userDefaultsKey: "TimePerCardKey")
        let nextCardFlashViewModel = SwitchCellViewModel(useCase: useCase, title: "Enable next card flashing", userDefaultsKey: "NextCardFlashKey")
        let nextCardVibrateViewModel = SwitchCellViewModel(useCase: useCase, title: "Enable next card vibration", userDefaultsKey: "NextCardVibrateKey")
        
        let items = input.trigger.map {
            [SettingsSection.setting(title: "Timer", items: [
                .timePerCardItem(viewModel: timePerCardViewModel),
                .nextCardFlashItem(viewModel: nextCardFlashViewModel),
                .nextCardVibrateItem(viewModel: nextCardVibrateViewModel)
                ])]
        }
        
        let selectedEvent = input.selection.do(onNext: { [weak self] (item) in
            switch item {
            case .timePerCardItem: self?.navigator.toTimePerCard()
            default: break
            }
        })
        
        return Output(dismiss: dismiss, items: items, selectedEvent: selectedEvent)
    }
}
