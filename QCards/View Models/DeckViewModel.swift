//
//  DeckViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift

class DeckViewModel {

    public var decks = BehaviorRelay<[Deck]>(value: [])
    private var deckDataAccessProvider: DeckDataAccessProvider?
    private var notificationToken: NotificationToken?
    private let disposeBag = DisposeBag()
    
    init() {
        let deckResults = deckDataAccessProvider?.fetch()
        
        if let deckResults = deckResults {
            observeChanges(to: deckResults)
        }
    }
    
    func observeChanges(to deckResults: Results<DeckEntity>) {
        
        notificationToken = deckResults.observe({ [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                deckResults.forEach({ deckEntity in
                    let deck = Deck(id: "\(deckEntity.id)", name: deckEntity.name)
                    self?.decks.append(deck)
                })
            case .update(_, _, let insertions, _):
                
                insertions.forEach({ index in
                    let deckEntity = deckResults[index]
                    self?.decks.append(Deck(id: "\(deckEntity.id)", name: deckEntity.name))
                })
                
                /*modifications.forEach({ index in
                    let deckEntity = deckResults[index]
                    
                    guard let index = self?.decks.value.index(where: { Int($0.id!) == deckEntity.id }) else {
                        print("Deck for the index does not exist.")
                        return
                    }
                    
                    var deck = self?.decks.value[index]
                    deck?.name = deckEntity.name
                })*/
                
            case .error(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /*func saveDeck(deck: Deck) {
        do {
            try realm.write {
                realm.add(deck)
            }
        } catch {
            print("Error saving deck \(error)")
        }
    }*/
    
    func onAddDeck(name: String) {
        deckDataAccessProvider?.add(name: name)
    }
    
    func onRemoveDeck(id: String) {
        deckDataAccessProvider?.delete(primaryKey: (Int(id))!)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}
