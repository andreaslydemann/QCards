//
//  IdentifiableObject.swift
//  Platform
//
//  Created by Andreas Lüdemann on 28/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RealmSwift

protocol IdentifiableObject: Object {
    var uid: String { get }
}
