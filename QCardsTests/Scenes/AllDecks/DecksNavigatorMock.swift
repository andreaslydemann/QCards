//
//  DecksNavigatorMock.swift
//  QCardsTests
//
//  Created by Andreas Lüdemann on 19/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
@testable import QCards
import RxSwift

class DecksNavigatorMock: DecksNavigator {

    var toDecks_Called = false
    var toDeck_deck_Called = false
    var toDeck_deck_ReceivedArguments: Deck?
    var toSettings_Called = false
    
    func toDecks() {
        toDecks_Called = true
    }
    
    func toSettings() {
        toSettings_Called = true
    }
    
    func toCreateDeck() {
        toSettings_Called = true
    }
    
    func toDeck(_ deck: Deck) {
        toDeck_deck_Called = true
        toDeck_deck_ReceivedArguments = deck
    }
}
