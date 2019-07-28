//
//  Realm+Ext.swift
//  Platform
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Realm
import RealmSwift
import RxSwift

extension Object {
    static func build<O: Object>(_ builder: (O) -> Void ) -> O {
        let object = O()
        builder(object)
        return object
    }
}

extension SortDescriptor {
    init(sortDescriptor: NSSortDescriptor) {
        self.init(keyPath: sortDescriptor.key ?? "", ascending: sortDescriptor.ascending)
    }
}

extension Reactive where Base: Realm {
    func save<R: Object>(entity: R, update: Bool = true) -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.add(entity, update: update ? .all : .error)
                }
                
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func save<R: Object>(entity: [R], update: Bool = true) -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.add(entity, update: update ? .all : .error)
                }
                
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func delete<R: Object>(entity: R, id: Any) -> Observable<Void> {
        return Observable.create { observer in
            guard let object = self.base.object(ofType: R.self, forPrimaryKey: id) else { fatalError() }
            
            do {
                try self.base.write {
                    self.base.delete(object)
                }
                
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func delete<R: IdentifiableObject>(entity: [R]) -> Observable<Void> {
        return Observable.create { observer in
            let objects = entity.map { singleEntity -> Object in
                guard let object = self.base.object(ofType: R.self, forPrimaryKey: singleEntity.uid) else { fatalError() }
                return object
            }
            
            do {
                try self.base.write {
                    self.base.delete(objects)
                }
                
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func deleteAll() -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.deleteAll()
                }
                
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
}
