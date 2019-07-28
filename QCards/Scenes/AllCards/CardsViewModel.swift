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
        let selectionTrigger: Driver<IndexPath>
        let moveCardTrigger: Driver<(ItemMovedEvent, [CardItemViewModel])>
        let presentationTrigger: Driver<Void>
        let settingsTrigger: Driver<Void>
        let createCardTrigger: Driver<Void>
        let deleteCardTrigger: Driver<Int>
        let editOrderTrigger: Driver<Void>
    }
    
    struct Output {
        let cards: Driver<[CardItemViewModel]>
        let editing: Driver<Bool>
        let presentation: Driver<[Card]>
        let settings: Driver<Void>
        let createCard: Driver<Void>
        let deleteCard: Driver<Void>
        let selectedCard: Driver<Card>
        let moveCard: Driver<[CardItemViewModel]>
        let enablePresentation: Driver<Bool>
    }
    
    private let deck: Deck
    private let useCase: CardsUseCase
    private let navigator: CardsNavigator
    
    init(deck: Deck, useCase: CardsUseCase, navigator: CardsNavigator) {
        self.deck = deck
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let initialCards = input.trigger.flatMapLatest { _ in
            return self.useCase.cards(of: self.deck)
                .asDriverOnErrorJustComplete()
                .map { $0.map { CardItemViewModel(with: $0) }}
        }
        
        let moveCard = input.moveCardTrigger.map { element -> [CardItemViewModel] in
            let moveEvent = element.0
            var newCards = element.1
            
            newCards.insert(newCards.remove(at: moveEvent.sourceIndex.row), at: moveEvent.destinationIndex.row)
            
            for (index, card) in newCards.enumerated() {
                var newCard = card.card
                newCard.orderPosition = index
                _ = self.useCase.save(card: newCard)
            }
            
            return newCards
        }
        
        let cards = Driver.merge(initialCards, moveCard)
        
        let selectedCard = input.selectionTrigger
            .withLatestFrom(cards) { (indexPath, cards) -> Card in
                return cards[indexPath.row].card
            }
            .do(onNext: navigator.toEditCard)
        
        let editing = input.editOrderTrigger.scan(false) { editing, _ in
            return !editing
            }.startWith(false)
        
        let presentation = input.presentationTrigger
            .withLatestFrom(cards) { _, cards -> [CardItemViewModel] in
                return cards
            }
            .map { $0.map { $0.card } }
            .do(onNext: navigator.toPresentation)
        
        let settings = input.settingsTrigger.withLatestFrom(cards)
            .map { $0.map { $0.card } }
        .flatMapLatest { [unowned self] in
            return self.useCase.save(cards: $0)
                .asDriverOnErrorJustComplete()
        }
        
        let createCard = input.createCardTrigger
            .do(onNext: { self.navigator.toCreateCard(self.deck) })
        
        let deleteCard = input.deleteCardTrigger
            .withLatestFrom(cards) { row, cards in
                return cards[row].card
            }
            .flatMapLatest { card in
                return self.useCase.delete(card: card)
                    .asDriverOnErrorJustComplete()
        }
        
        let enablePresentation = cards.scan(false) { _, cards in
            return !cards.isEmpty
        }.startWith(false)
        
        return Output(cards: cards,
                      editing: editing,
                      presentation: presentation,
                      settings: settings,
                      createCard: createCard,
                      deleteCard: deleteCard,
                      selectedCard: selectedCard,
                      moveCard: moveCard,
                      enablePresentation: enablePresentation)
    }
}
