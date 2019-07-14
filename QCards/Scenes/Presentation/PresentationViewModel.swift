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
        let dismissTrigger: Driver<Void>
    }
    
    struct Output {
        let cards: Driver<[CardItemViewModel]>
        let dismiss: Driver<Void>
    }
    
    private let cards: [Card]
    private let useCase: CardsUseCase
    private let navigator: PresentationNavigator
    
    init(cards: [Card], useCase: CardsUseCase, navigator: PresentationNavigator) {
        self.cards = cards
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let cards = input.trigger.flatMapLatest { _ in
            return Driver.just(self.cards)
                .map { $0.map { CardItemViewModel(with: $0) }}
        }
        
        let dismiss = input.dismissTrigger
            .do(onNext: navigator.toCards)
        
        return Output(cards: cards, dismiss: dismiss)
    }
}
