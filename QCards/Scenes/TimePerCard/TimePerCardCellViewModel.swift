//
//  TimePerCardCellViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 05/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

enum TimePerCard: Int {
    case infinite
    case thirtysec
    case onemin
    case twomin
}

extension TimePerCard: CaseIterable {}

class TimePerCardCellViewModel {
    
    let timeOption: Int
    
    init(with timeOption: Int) {
        self.timeOption = timeOption
        //super.init()
    }
}

func displayName(forTime time: Int) -> Int {
    return time
    
}
