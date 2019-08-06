//
//  TimePerCardCellViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 05/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

enum TimePerCard: Int {
    case infinite, thirtysec, onemin, twomin
    static let allValues = [infinite, thirtysec, onemin, twomin]
}

class TimePerCardCellViewModel {
    
    let timeOption: Int
    let isSelected: Bool
    var displayName: String {
        switch TimePerCard(rawValue: timeOption)! {
        case .infinite: return "Infinite"
        case .thirtysec: return "30 seconds"
        case .onemin: return "One minute"
        case .twomin: return "Two minutes"
        }
    }
    
    init(with timeOption: Int, isSelected: Bool) {
        self.timeOption = timeOption
        self.isSelected = isSelected
    }
}
