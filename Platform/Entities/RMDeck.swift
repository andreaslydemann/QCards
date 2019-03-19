//
//  RMDeck.swift
//  Platform
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Realm
import RealmSwift

final class RMDeck: Object {
    @objc dynamic var uid: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var createdAt: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMDeck {
    static var title: Attribute<String> { return Attribute("title")}
    static var uid: Attribute<String> { return Attribute("uid")}
    static var createdAt: Attribute<String> { return Attribute("createdAt")}
}

extension RMDeck: DomainConvertibleType {
    func asDomain() -> Deck {
        return Deck(title: title,
                    uid: uid,
                    createdAt: createdAt)
    }
}

extension Deck: RealmRepresentable {
    func asRealm() -> RMDeck {
        return RMDeck.build { object in
            object.uid = uid
            object.title = title
            object.createdAt = createdAt
        }
    }
}
