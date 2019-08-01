//
//  SettingsUseCase.swift
//  Domain
//
//  Created by Andreas Lüdemann on 01/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation
import RxSwift

public protocol SettingsUseCase {
    func getSetting(of key: String, defaultValue: Bool) -> Observable<Bool>
    func saveSetting(with value: Bool, key: String) -> Observable<Void>
}
