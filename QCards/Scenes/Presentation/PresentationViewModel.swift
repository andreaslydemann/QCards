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
        let hideCountdown: Driver<Bool>
        let cardNumber: Driver<String>
        let dismiss: Driver<Void>
        let countdownTime: Driver<String>
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
        let timePerCard = settingsUseCase
            .getTimeSetting(of: "TimePerCardKey", defaultValue: 0)
            .map { $0 }
        
        let hideCountdown = timePerCard.map { $0 == 0 }.asDriverOnErrorJustComplete()
        
        let cards = input.trigger.flatMapLatest {
            Driver.just(self.cards)
                .map { $0.map { CardItemViewModel(with: $0) }}
        }
        
        let nextCard = input.nextCardTrigger.startWith(0)
        
        let cardNumber = Observable.combineLatest(nextCard, cards.asObservable())
            .map { "Card \($0 + 1 > $1.count ? $0 : $0 + 1) of \($1.count)" }
            .asDriverOnErrorJustComplete()
        
        let countdownTime = Observable.combineLatest(nextCard, timePerCard) { $1 }
            .flatMap {
                self.count(from: $0)
                    .takeUntil(input.nextCardTrigger)
            }.map { "\($0) seconds left" }
            .asDriverOnErrorJustComplete()
        
        let dismiss = input.dismissTrigger
            .do(onNext: navigator.toCards)
        
        return Output(cards: cards,
                      hideCountdown: hideCountdown,
                      cardNumber: cardNumber,
                      dismiss: dismiss,
                      countdownTime: countdownTime)
    }
    
    func count(from: Int, to: Int = 0, quickStart: Bool = true) -> Observable<Int> {
        return Observable<Int>
            .timer(0, period: 1, scheduler: MainScheduler.instance)
            .take(from - to + 1)
            .map { from - $0 }
    }
}
