//
//  DeckUseCase.swift
//  Platform
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import Realm
import RealmSwift
import RxSwift

final class DecksUseCase<Repository>: Domain.DecksUseCase where Repository: AbstractRepository, Repository.T == Deck {
    
    private let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func decks() -> Observable<[Deck]> {
        return repository.queryAll()
    }
    
    func save(deck: Deck) -> Observable<Void> {
        return repository.save(entity: deck)
    }
    
    func delete(deck: Deck) -> Observable<Void> {
        return repository.delete(entity: deck)
    }
}
