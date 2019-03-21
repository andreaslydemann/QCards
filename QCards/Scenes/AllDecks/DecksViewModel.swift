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
        let createDeckTrigger: Driver<String>
        let deleteDeckTrigger: Driver<Void>
        let selection: Driver<IndexPath>
    }
    
    struct Output {
        let decks: Driver<[DeckItemViewModel]>
        let createDeck: Driver<Void>
        let deleteDeck: Driver<Void>
    }
    
    //private let deck: Deck
    private let useCase: DecksUseCase
    private let navigator: DecksNavigator
    
    init(useCase: DecksUseCase, navigator: DecksNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let decks = input.trigger.flatMapLatest {
            return self.useCase.decks()
                .asDriverOnErrorJustComplete()
                .map { $0.map { DeckItemViewModel(with: $0) } }
        }
        
        let createDeck = input.createDeckTrigger
            .map { (title) in
                return Domain.Deck(title: title)
            }
            .flatMapLatest { [unowned self] in
                return self.useCase.save(deck: $0)
                    .asDriverOnErrorJustComplete()
        }
        
        /*let deleteDeck = input.deleteTrigger.withLatestFrom(deck)
            .flatMapLatest { deck in
                return self.useCase.delete(deck: deck)
                    .asDriverOnErrorJustComplete()
            }*/
        
        return Output(decks: decks,
                      createDeck: createDeck,
                      deleteDeck: input.deleteDeckTrigger)
        // deleteDeck: deleteDeck
    }
}
