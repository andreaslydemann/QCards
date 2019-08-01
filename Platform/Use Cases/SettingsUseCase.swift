//
//  SettingsUseCase.swift
//  Platform
//
//  Created by Andreas Lüdemann on 01/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import Realm
import RealmSwift
import RxSwift

final class SettingsUseCase {
    
    private let repository: Repository<RMDeck>
    
    init(repository: Repository<RMDeck>) {
        self.repository = repository
    }
    
    func decks() -> Observable<[Deck]> {
        return repository.queryAll().mapToDomain()
    }
    
    func save(deck: Deck) -> Observable<Void> {
        return repository.save(entity: deck.asRealm())
    }
    
    func delete(deck: Deck) -> Observable<Void> {
        return repository.delete(entity: deck.asRealm())
    }
}
