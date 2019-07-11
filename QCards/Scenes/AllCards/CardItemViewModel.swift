//
//  CardItemViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 10/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxDataSources

final class CardItemViewModel: IdentifiableType, Equatable {
    let title: String
    let content: String
    let card: Domain.Card
    
    init (with card: Domain.Card) {
        self.card = card
        self.title = card.title
        self.content = card.content
    }
    
    var identity: String {
        return card.uid
    }
    
    static func == (lhs: CardItemViewModel, rhs: CardItemViewModel) -> Bool {
        return lhs.title == rhs.title && lhs.content == rhs.content
    }
}
