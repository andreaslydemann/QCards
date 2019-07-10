//
//  CardsUseCase.swift
//  Domain
//
//  Created by Andreas Lüdemann on 08/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation
import RxSwift

public protocol CardsUseCase {
    func cards(of deck: Deck) -> Observable<[Card]>
    func save(card: Card) -> Observable<Void>
    func delete(card: Card) -> Observable<Void>
}
