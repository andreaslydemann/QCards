//
//  SettingsSection.swift
//  QCards
//
//  Created by Andreas Lüdemann on 04/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation
import RxDataSources

enum SettingsSection {
    case setting(title: String, items: [SettingsSectionItem])
}

enum SettingsSectionItem {
    case enableTimerItem(viewModel: SwitchCellViewModel)
    case timePerCardItem(viewModel: TimeCellViewModel)
}

extension SettingsSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case .enableTimerItem(let viewModel): return viewModel.title
        case .timePerCardItem(let viewModel): return String(viewModel.timePerCard)
        }
    }
}

extension SettingsSectionItem: Equatable {
    static func == (lhs: SettingsSectionItem, rhs: SettingsSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension SettingsSection: AnimatableSectionModelType, IdentifiableType {
    typealias Item = SettingsSectionItem
    
    typealias Identity = String
    var identity: Identity { return title }
    
    var title: String {
        switch self {
        case .setting(let title, _): return title
        }
    }
    
    var items: [SettingsSectionItem] {
        switch  self {
        case .setting(_, let items): return items.map {$0}
        }
    }
    
    init(original: SettingsSection, items: [Item]) {
        switch original {
        case .setting(let title, let items): self = .setting(title: title, items: items)
        }
    }
}
