//
//  CardsUseCase.swift
//  Platform
//
//  Created by Andreas Lüdemann on 08/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import Realm
import RealmSwift
import RxSwift

final class CardsUseCase: Domain.CardsUseCase {
    
    private let repository: Repository<Card.RealmType>
    
    init(repository: Repository<Card.RealmType>) {
        self.repository = repository
    }
    
    func cards(of deck: Deck) -> Observable<[Card]> {
        return repository.query(with: NSPredicate(format: "deckId == %@", deck.uid), sortDescriptors: []).mapToDomain()
    }
    
    func save(card: Card) -> Observable<Void> {
        return repository.save(entity: card.asRealm())
    }
    
    func save(cards: [Card]) -> Observable<Void> {
        return repository
            .save(entities: cards.map { $0.asRealm() })
    }
    
    func delete(card: Card) -> Observable<Void> {
        return repository.delete(entity: card.asRealm())
    }
    
    func deleteCards(of deck: Deck) -> Observable<Void> {
        return cards(of: deck).flatMapLatest { cards in
            return self.repository.delete(entities: cards.map { $0.asRealm() })
        }
    }
}
