//
//  DeckProvider.swift
//  QCards
//
//  Created by Andreas Lüdemann on 10/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RealmSwift

protocol IDeckProvider {
    func fetch() -> Results<DeckEntity>
    func add(name: String)
    func delete(deck: DeckEntity)
}

class DeckProvider: Database, IDeckProvider {
    static let shared = DeckProvider()
    
    public func fetch() -> Results<DeckEntity> {
        let realm = getRealm()
        printDatabaseLocation()
        
        return realm.objects(DeckEntity.self)
    }
    
    func add(name: String) {
        var id: Int? = 1
        
        let realm = getRealm()
        
        if let lastEntity = realm.objects(DeckEntity.self).last {
            id = lastEntity.id + 1
        }
        
        let deckEntity = DeckEntity()
        deckEntity.id = id!
        deckEntity.name = name
        
        do {
            try realm.write {
                realm.add(deckEntity)
            }
        } catch {
            print("Error adding deck \(error)")
        }
    }
    
    func delete(deck: DeckEntity) {
        let realm = getRealm()
        
        print("realm delete deck with id: ", deck.id)
        
        do {
            try realm.write {
                realm.delete(deck)
            }
        } catch {
            print("Error deleting deck, \(error)")
        }
        
        /*if let deckEntity = realm.object(ofType: DeckEntity.self, forPrimaryKey: primaryKey) {
            
        }*/
    }
}
