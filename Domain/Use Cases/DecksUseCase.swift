//
//  DeckUseCases.swift
//  Domain
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation
import RxSwift

public protocol DecksUseCase {
    func decks() -> Observable<[Deck]>
    func save(deck: Deck) -> Observable<Void>
    func delete(deck: Deck) -> Observable<Void>
}
