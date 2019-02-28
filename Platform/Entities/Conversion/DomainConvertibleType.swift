//
//  DomainConvertibleType.swift
//  Platform
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

protocol DomainConvertibleType {
    associatedtype DomainType
    
    func asDomain() -> DomainType
}
