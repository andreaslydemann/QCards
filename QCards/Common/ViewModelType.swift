//
//  ViewModelType.swift
//  QCards
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
