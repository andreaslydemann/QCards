//
//  DecksUseCaseMock.swift
//  QCardsTests
//
//  Created by Andreas Lüdemann on 19/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
@testable import QCards
import RxSwift

class DecksUseCaseMock: Domain.DecksUseCase {
    
    var decks_ReturnValue: Observable<[Deck]> = Observable.just([])
    var decks_Called = false
    var saveDeck_ReturnValue: Observable<Void> = Observable.just(())
    var saveDeck_Called = false
    var deleteDeck_ReturnValue: Observable<Void> = Observable.just(())
    var deleteDeck_Called = false
    
    func decks() -> Observable<[Deck]> {
        decks_Called = true
        return decks_ReturnValue
    }
    
    func save(deck: Deck) -> Observable<Void> {
        saveDeck_Called = true
        return saveDeck_ReturnValue
    }
    
    func delete(deck: Deck) -> Observable<Void> {
        deleteDeck_Called = true
        return deleteDeck_ReturnValue
    }
}
