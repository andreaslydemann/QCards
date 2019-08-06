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
    func getSwitchSetting(of key: String, defaultValue: Bool) -> Observable<Bool>
    func saveSwitchSetting(with value: Bool, key: String) -> Observable<Void>
    func getTimeSetting(of key: String, defaultValue: Int?) -> Observable<Int>
    func saveTimeSetting(with value: Int, key: String) -> Observable<Void>
}
