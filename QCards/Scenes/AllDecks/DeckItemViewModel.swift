//
//  DeckItemViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/03/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation

final class DeckItemViewModel {
    let title: String
    let createdAt: String
    let deck: Domain.Deck
    init (with deck: Domain.Deck) {
        self.deck = deck
        self.title = deck.title
        self.createdAt = deck.createdAt
    }
}
