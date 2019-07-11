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
        let editCardTrigger: Driver<Void>
        let deleteCardTrigger: Driver<Void>
        let title: Driver<String>
        let content: Driver<String>
    }
    
    struct Output {
        let editButtonTitle: Driver<String>
        let save: Driver<Void>
        let delete: Driver<Void>
        let editing: Driver<Bool>
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
        let editing = input.editCardTrigger.scan(false) { editing, _ in
            return !editing
            }.startWith(false)
        
        let editButtonTitle = editing.map { editing -> String in
            return editing == true ? "Save" : "Edit"
        }
        
        let saveTrigger = editing.skip(1)
            .filter { $0 == false }
            .mapToVoid()
        
        let titleAndContent = Driver.combineLatest(input.title, input.content)
        let card = Driver.combineLatest(Driver.just(self.card), titleAndContent) { (card, titleAndContent) -> Card in
            return Card(uid: card.uid, title: titleAndContent.0, content: titleAndContent.1, deckId: card.deckId)
            }.startWith(self.card)
        
        let saveCard = saveTrigger.withLatestFrom(card)
            .flatMapLatest { card in
                return self.useCase.save(card: card)
                    .asDriverOnErrorJustComplete()
        }
        
        let deleteCard = input.deleteCardTrigger.withLatestFrom(card)
            .flatMapLatest { card in
                return self.useCase.delete(card: card)
                    .asDriverOnErrorJustComplete()
            }.do(onNext: {
                self.navigator.toCards()
            })
        
        return Output(editButtonTitle: editButtonTitle,
                      save: saveCard,
                      delete: deleteCard,
                      editing: editing,
                      card: card)
    }
}
