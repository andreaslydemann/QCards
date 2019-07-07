//
//  CardsViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class CardsViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let createCardTrigger: Driver<Void>
        let editTrigger: Driver<Void>
    }
    
    struct Output {
        let cards: Driver<[DeckItemViewModel]>
        let editing: Driver<Bool>
        let createCard: Driver<Void>
    }
    
    private let deck: Deck
    private let useCase: DecksUseCase
    private let navigator: CardsNavigator
    
    init(deck: Deck, useCase: DecksUseCase, navigator: CardsNavigator) {
        self.deck = deck
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let cards = input.trigger.flatMapLatest { _ in
            return self.useCase.decks()
                .asDriverOnErrorJustComplete()
                .map { $0.map { deck in DeckItemViewModel(with: deck) }.sorted(by: {$0.createdAt > $1.createdAt}) }
        }
        
        let editing = input.editTrigger.scan(false) { editing, _ in
            return !editing
            }.startWith(false)
        
        let createCard = input.createCardTrigger
            .do(onNext: navigator.toCreateCard)
        
        return Output(cards: cards, editing: editing, createCard: createCard)
    }
}
