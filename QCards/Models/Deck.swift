//
//  Deck.swift
//  QCards
//
//  Created by Andreas Lüdemann on 10/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxDataSources

class Deck: IdentifiableType, Equatable {
    var id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    var identity: String {
        return id
    }
    
    static func == (lhs: Deck, rhs: Deck) -> Bool {
        return lhs.id == rhs.id
    }
}
