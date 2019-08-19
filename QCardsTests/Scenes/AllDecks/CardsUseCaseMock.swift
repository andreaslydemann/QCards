//
//  CardsUseCaseMock.swift
//  QCardsTests
//
//  Created by Andreas Lüdemann on 19/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
@testable import QCards
import RxSwift

class CardsUseCaseMock: Domain.CardsUseCase {
    
    var cards_ReturnValue: Observable<[Card]> = Observable.just([])
    var cards_Called = false
    var saveCard_ReturnValue: Observable<Void> = Observable.just(())
    var saveCard_Called = false
    var saveCards_ReturnValue: Observable<Void> = Observable.just(())
    var saveCards_Called = false
    var deleteCard_ReturnValue: Observable<Void> = Observable.just(())
    var deleteCard_Called = false
    var deleteCards_ReturnValue: Observable<Void> = Observable.just(())
    var deleteCards_Called = false
    
    func cards(of deck: Deck) -> Observable<[Card]> {
        cards_Called = true
        return cards_ReturnValue
    }
    
    func save(card: Card) -> Observable<Void> {
        saveCard_Called = true
        return saveCard_ReturnValue
    }
    
    func save(cards: [Card]) -> Observable<Void> {
        saveCards_Called = true
        return saveCards_ReturnValue
    }
    
    func delete(card: Card) -> Observable<Void> {
        deleteCard_Called = true
        return deleteCard_ReturnValue
    }
    
    func deleteCards(of deck: Deck) -> Observable<Void> {
        deleteCards_Called = true
        return deleteCards_ReturnValue
    }
}
