//
//  DecksViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/03/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class DecksViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let selection: Driver<IndexPath>
        let createDeckTrigger: Driver<String>
        let editDeckTrigger: Driver<(title: String, row: Int)>
        let deleteDeckTrigger: Driver<Int>
        let settingsTrigger: Driver<Void>
    }
    
    struct Output {
        let decks: Driver<[DeckItemViewModel]>
        let selectedDeck: Driver<Deck>
        let createDeck: Driver<Void>
        let editDeck: Driver<Void>
        let deleteDeck: Driver<Void>
        let deleteCards: Driver<Void>
        let settings: Driver<Void>
        let decksAvailable: Driver<Bool>
    }
    
    private let decksUseCase: DecksUseCase
    private let cardsUseCase: CardsUseCase
    private let navigator: DecksNavigator
    
    init(decksUseCase: DecksUseCase, cardsUseCase: CardsUseCase, navigator: DecksNavigator) {
        self.decksUseCase = decksUseCase
        self.cardsUseCase = cardsUseCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let decks = input.trigger.flatMapLatest { _ in
            return self.decksUseCase.decks()
                .asDriverOnErrorJustComplete()
                .map { $0.map { DeckItemViewModel(with: $0) }.sorted(by: {$0.createdAt > $1.createdAt}) }
        }
        
        let decksAvailable = decks.map({ $0.count > 0 }).asDriver(onErrorJustReturn: false)
        
        let selectedDeck = input.selection
            .withLatestFrom(decks) { (indexPath, decks) -> Deck in
                return decks[indexPath.row].deck
            }
            .do(onNext: navigator.toDeck)
        
        let createDeck = input.createDeckTrigger
            .map { (title) in
                return Domain.Deck(title: title)
            }
            .flatMapLatest { [unowned self] in
                return self.decksUseCase.save(deck: $0)
                    .asDriverOnErrorJustComplete()
        }
        
        let editDeck = input.editDeckTrigger
            .withLatestFrom(decks) { arg, decks -> (Domain.Deck, String) in
                let (title, row) = arg
                return (decks[row].deck, title)
            }
            .map { arg -> Domain.Deck in
                let (deck, title) = arg
                return Domain.Deck(title: title, uid: deck.uid, createdAt: deck.createdAt)
            }.flatMapLatest { [unowned self] in
                return self.decksUseCase.save(deck: $0)
                    .asDriverOnErrorJustComplete()
        }
        
        let deckToDelete = input.deleteDeckTrigger
            .withLatestFrom(decks) { row, decks in
                return decks[row].deck
        }
        
        let deleteDeck = deckToDelete.flatMapLatest { deck in
            return self.decksUseCase.delete(deck: deck)
                .asDriverOnErrorJustComplete()
        }
        
        let deleteCards = deckToDelete.flatMapLatest({
            return self.cardsUseCase.deleteCards(of: $0).asDriverOnErrorJustComplete()
        })
        
        let settings = input.settingsTrigger
            .do(onNext: navigator.toSettings)
        
        return Output(decks: decks,
                      selectedDeck: selectedDeck,
                      createDeck: createDeck,
                      editDeck: editDeck,
                      deleteDeck: deleteDeck,
                      deleteCards: deleteCards,
                      settings: settings,
                      decksAvailable: decksAvailable)
    }
}
