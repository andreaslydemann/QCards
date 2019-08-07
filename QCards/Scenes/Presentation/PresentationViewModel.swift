//
//  PresentationViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 14/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class PresentationViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let nextCardTrigger: Observable<Int>
        let dismissTrigger: Driver<Void>
    }
    
    struct Output {
        let cards: Driver<[CardItemViewModel]>
        let nextCard: Driver<Int>
        let dismiss: Driver<Void>
        let countDownTime: Driver<Int>
    }
    
    private let cards: [Card]
    private let cardsUseCase: CardsUseCase
    private let settingsUseCase: SettingsUseCase
    private let navigator: PresentationNavigator
    
    init(cards: [Card], cardsUseCase: CardsUseCase, settingsUseCase: SettingsUseCase, navigator: PresentationNavigator) {
        self.cards = cards
        self.cardsUseCase = cardsUseCase
        self.settingsUseCase = settingsUseCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let timePerCard = settingsUseCase.getTimeSetting(of: "TimePerCardKey", defaultValue: 0)
            .map { $0 }.asDriver(onErrorJustReturn: 0)
        
        let cards = input.trigger.flatMapLatest { _ in
            return Driver.just(self.cards)
                .map { $0.map { CardItemViewModel(with: $0) }}
        }
        
        let nextCard = input.nextCardTrigger.startWith(0)
        
        let countDownTime = nextCard.mapToVoid().flatMap { self.count(from: 5).takeUntil(input.nextCardTrigger) }.asDriverOnErrorJustComplete()
        
        let dismiss = input.dismissTrigger
            .do(onNext: navigator.toCards)
        
        return Output(cards: cards, nextCard: nextCard.asDriverOnErrorJustComplete(), dismiss: dismiss, countDownTime: countDownTime)
    }
    
    func count(from: Int, to: Int = 0, quickStart: Bool = true) -> Observable<Int> {
        return Observable<Int>
            .timer(0, period: 1, scheduler: MainScheduler.instance)
            .take(from - to + 1)
            .map { from - $0 }
    }
}
