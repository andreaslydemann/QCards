//
//  DeckEntity.swift
//  QCards
//
//  Created by Andreas Lüdemann on 26/11/2018.
//  Copyright © 2018 Andreas Lüdemann. All rights reserved.
//

import Foundation
import RealmSwift

class DeckEntity: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
}
