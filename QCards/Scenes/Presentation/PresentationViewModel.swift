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
        let cardCount: Driver<String>
        let activeNextCardFlash: Driver<Bool>
        let activeNextCardVibrate: Driver<Bool>
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
            .getTimeSetting(of: K.UserDefaultsKeys.TimePerCardKey, defaultValue: 0)
            .asDriverOnErrorJustComplete()
        
        let nextCardFlash = settingsUseCase
            .getSwitchSetting(of: K.UserDefaultsKeys.NextCardFlashKey, defaultValue: false)
            .asDriverOnErrorJustComplete()
        
        let nextCardVibrate = settingsUseCase
            .getSwitchSetting(of: K.UserDefaultsKeys.NextCardVibrateKey, defaultValue: false)
            .asDriverOnErrorJustComplete()
        
        let hideCountdown = timePerCard.map { $0 == 0 }
        
        let cards = input.trigger.flatMapLatest {
            Driver.just(self.cards)
                .map { $0.map { CardItemViewModel(with: $0) }}
        }
        
        let nextCard = input.nextCardTrigger
            .startWith(0)
            .asDriverOnErrorJustComplete()
        
        let cardCount = Driver.combineLatest(nextCard, cards)
            .map { String(format: NSLocalizedString("Presentation.CardCount.Title", comment: ""),
                          String($0 + 1 > $1.count ? $0 : $0 + 1), String($1.count))
        }
        
        let countdownTime = Driver.combineLatest(nextCard, timePerCard) { $1 }
            .flatMap {
                self.count(from: $0)
                    .takeUntil(input.nextCardTrigger)
                    .asDriverOnErrorJustComplete()
        }
        
        let timeOut = Driver.combineLatest(countdownTime, timePerCard) { $0 == 0 && $1 != 0 }.distinctUntilChanged()
        let activeNextCardFlash = Driver.combineLatest(timeOut, nextCardFlash) { $0 && $1 }
        let activeNextCardVibrate = Driver.combineLatest(timeOut, nextCardVibrate) { $0 && $1 }
        let countdownText = countdownTime.map {
            String(format: NSLocalizedString("Presentation.Countdown.Title", comment: ""), String($0))
        }
        
        let dismiss = input.dismissTrigger
            .do(onNext: navigator.toCards)
        
        return Output(cards: cards,
                      hideCountdown: hideCountdown,
                      cardCount: cardCount,
                      activeNextCardFlash: activeNextCardFlash,
                      activeNextCardVibrate: activeNextCardVibrate,
                      dismiss: dismiss,
                      countdownTime: countdownText)
    }
    
    func count(from: Int, to: Int = 0, quickStart: Bool = true) -> Observable<Int> {
        return Observable<Int>
            .timer(0, period: 1, scheduler: MainScheduler.instance)
            .take(from - to + 1)
            .map { from - $0 }
    }
}
