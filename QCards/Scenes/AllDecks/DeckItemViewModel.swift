//
//  DeckItemViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/03/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxDataSources

final class DeckItemViewModel: IdentifiableType, Equatable {
    let title: String
    let createdAt: String
    let deck: Domain.Deck
    
    init (with deck: Domain.Deck) {
        self.deck = deck
        self.title = deck.title
        self.createdAt = deck.createdAt
    }
    
    var identity: String {
        return deck.uid
    }
    
    static func == (lhs: DeckItemViewModel, rhs: DeckItemViewModel) -> Bool {
        return lhs.title == rhs.title
    }
}
