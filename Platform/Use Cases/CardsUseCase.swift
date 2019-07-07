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

final class CardsUseCase<Repository>: Domain.CardsUseCase where Repository: AbstractRepository, Repository.T == Card {
    
    private let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func cards() -> Observable<[Card]> {
        return repository.queryAll()
    }
    
    func save(card: Card) -> Observable<Void> {
        return repository.save(entity: card)
    }
    
    func delete(card: Card) -> Observable<Void> {
        return repository.delete(entity: card)
    }
}
