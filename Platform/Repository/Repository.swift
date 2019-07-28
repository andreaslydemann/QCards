//
//  Repository.swift
//  Platform
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Realm
import RealmSwift
import RxRealm
import RxSwift

protocol AbstractRepository {
    associatedtype T
    func queryAll() -> Observable<[T]>
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor]) -> Observable<[T]>
    func save(entity: T) -> Observable<Void>
    func save(entity: [T]) -> Observable<Void>
    func delete(entity: T, id: Any) -> Observable<Void>
    func deleteAll() -> Observable<Void>
}

final class Repository<T: IdentifiableObject>: AbstractRepository {
    private let configuration: Realm.Configuration
    private let scheduler: RunLoopThreadScheduler
    
    private var realm: Realm {
        do {
            return try Realm(configuration: self.configuration)
        } catch {
            fatalError("Could not create instance of realm")
        }
    }
    
    init(configuration: Realm.Configuration) {
        self.configuration = configuration
        let name = "com.andreaslydemann.Platform.Repository"
        self.scheduler = RunLoopThreadScheduler(threadName: name)
        print("File 📁 url: \(RLMRealmPathForFile("default.realm"))")
    }
    
    func queryAll() -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.self)
            
            return Observable.array(from: objects)
            }
            .subscribeOn(scheduler)
    }
    
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor] = []) -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.self)
                .filter(predicate)
                .sorted(by: sortDescriptors.map(SortDescriptor.init))
            return Observable.array(from: objects)
            }
            .subscribeOn(scheduler)
    }
    
    func save(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(entity: entity)
            }.subscribeOn(scheduler)
    }
    
    func save(entity: [T]) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(entity: entity)
            }.subscribeOn(scheduler)
    }
    
    func delete(entity: T, id: Any) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.delete(entity: entity, id: id)
            }.subscribeOn(scheduler)
    }
    
    func delete(entity: [T]) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.delete(entity: entity)
            }.subscribeOn(scheduler)
    }
    
    func deleteAll() -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.deleteAll()
            }.subscribeOn(scheduler)
    }
}
