//
//  RealmRepresentable.swift
//  Platform
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

protocol RealmRepresentable {
    associatedtype RealmType: DomainConvertibleType
    
    var uid: String {get}
    
    func asRealm() -> RealmType
}
