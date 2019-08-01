//
//  UserDefaultsRepository.swift
//  Platform
//
//  Created by Andreas Lüdemann on 01/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxCocoa
import RxSwift

protocol AbstractUserDefaultsRepository {
    func remove(key: String) -> Observable<Void>
    func save<T: RxSettingCompatible>(value: T, key: String) -> Observable<Void>
    func get<T: RxSettingCompatible>(key: String, defaultValue: T) -> Observable<T>
}

final class UserDefaultsRepository: AbstractUserDefaultsRepository {
    
    let userDefaults: UserDefaults
    private let scheduler: RunLoopThreadScheduler
    
    public init(userDefaults: UserDefaults) {
        let name = "com.andreaslydemann.Platform.UserDefaultsRepository"
        self.scheduler = RunLoopThreadScheduler(threadName: name)
        self.userDefaults = userDefaults
    }
    
    public func remove(key: String) -> Observable<Void> {

        return Observable.deferred {
            return Observable.create { observer in
                self.userDefaults.removeObject(forKey: key)
                
                observer.onNext(())
                observer.onCompleted()
                
                return Disposables.create()
            }
            }
            .subscribeOn(scheduler)
    }
    
    public func save<T: RxSettingCompatible>(value: T, key: String) -> Observable<Void> {

        return Observable.deferred {
            return Observable.create { observer in
                let persValue = value.toPersistedValue()
                
                self.userDefaults.set(persValue, forKey: key)
                
                observer.onNext(())
                observer.onCompleted()
                
                return Disposables.create()
            }
            }
            .subscribeOn(scheduler)
    }
    
    public func get<T: RxSettingCompatible>(key: String, defaultValue: T) -> Observable<T> {
        return Observable.deferred {
            return Observable.create { observer in
                var value: T = defaultValue
                
                if self.isSet(key: key) {
                    value = T.fromPersistedValue(value: self.userDefaults.value(forKey: key) as Any)
                }
                
                observer.onNext(value)
                observer.onCompleted()
                
                return Disposables.create()
            }
            }
            .subscribeOn(scheduler)
    }
    
    private func isSet(key: String) -> Bool {
        return userDefaults.dictionaryRepresentation().keys.contains(key)
    }
}

public protocol RxSettingCompatible {
    func toPersistedValue() -> Any
    static func fromPersistedValue(value: Any) -> Self
}

public protocol RxSettingEnum: RxSettingCompatible { }
