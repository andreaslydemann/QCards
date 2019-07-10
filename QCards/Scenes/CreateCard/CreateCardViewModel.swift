//
//  CreateCardViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 08/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class CreateCardViewModel: ViewModelType {
    
    struct Input {
        let cancelTrigger: Driver<Void>
        let saveTrigger: Driver<Void>
        let title: Driver<String>
        let content: Driver<String>
    }
    
    struct Output {
        let dismiss: Driver<Void>
        let saveEnabled: Driver<Bool>
    }
    
    private let deck: Deck
    private let useCase: CardsUseCase
    private let navigator: CreateCardNavigator
    
    init(deck: Deck, useCase: CardsUseCase, navigator: CreateCardNavigator) {
        self.deck = deck
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let canSave = Driver.combineLatest(input.title, input.content) { title, content in
            return !title.isEmpty && !content.isEmpty
        }
        
        let save = input.saveTrigger.withLatestFrom(Driver.combineLatest(input.title, input.content, Driver.just(deck)))
            .map { Domain.Card(title: $0.0, content: $0.1, deckId: $0.2.uid) }
            .flatMapLatest { [unowned self] in
                return self.useCase.save(card: $0)
                    .asDriverOnErrorJustComplete()
        }
        
        let dismiss = Driver.of(save, input.cancelTrigger)
            .merge()
            .do(onNext: navigator.toCards)
        
        return Output(dismiss: dismiss, saveEnabled: canSave)
    }
}
