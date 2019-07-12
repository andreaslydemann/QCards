//
//  EditCardViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 11/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class EditCardViewModel: ViewModelType {
    
    struct Input {
        let saveTrigger: Driver<Void>
        let deleteTrigger: Driver<Void>
        let title: Driver<String>
        let content: Driver<String>
    }
    
    struct Output {
        let save: Driver<Void>
        let delete: Driver<Void>
        let saveEnabled: Driver<Bool>
        let card: Driver<Card>
    }
    
    private let card: Card
    private let useCase: CardsUseCase
    private let navigator: EditCardNavigator
    
    init(card: Card, useCase: CardsUseCase, navigator: EditCardNavigator) {
        self.card = card
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let canSave = Driver.combineLatest(input.title, input.content) { title, content in
            return !title.isEmpty && !content.isEmpty
        }
        
        let titleAndContent = Driver.combineLatest(input.title, input.content)
        let card = Driver.combineLatest(Driver.just(self.card), titleAndContent) { (card, titleAndContent) -> Card in
            return Card(uid: card.uid, title: titleAndContent.0, content: titleAndContent.1, deckId: card.deckId)
            }.startWith(self.card)

        let saveCard = input.saveTrigger.withLatestFrom(card)
            .flatMapLatest { card in
                return self.useCase.save(card: card)
                    .asDriverOnErrorJustComplete()
        }.do(onNext: navigator.toCards)
        
        let deleteCard = input.deleteTrigger.withLatestFrom(card)
            .flatMapLatest { card in
                return self.useCase.delete(card: card)
                    .asDriverOnErrorJustComplete()
            }.do(onNext: navigator.toCards)
        
        return Output(save: saveCard,
                      delete: deleteCard,
                      saveEnabled: canSave,
                      card: card)
    }
}
