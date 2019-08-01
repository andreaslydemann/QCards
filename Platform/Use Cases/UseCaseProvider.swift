//
//  UseCaseProvider.swift
//  Platform
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import Realm
import RealmSwift

public final class UseCaseProvider: Domain.UseCaseProvider {
    private let configuration: Realm.Configuration
    
    public init(configuration: Realm.Configuration = Realm.Configuration()) {
        self.configuration = configuration
    }
    
    public func makeDecksUseCase() -> Domain.DecksUseCase {
        let repository = RealmRepository<Deck.RealmType>(configuration: configuration)
        return DecksUseCase(repository: repository)
    }
    
    public func makeCardsUseCase() -> Domain.CardsUseCase {
        let repository = RealmRepository<Card.RealmType>(configuration: configuration)
        return CardsUseCase(repository: repository)
    }
    
    public func makeSettingsUseCase() -> Domain.SettingsUseCase {
        let repository = UserDefaultsRepository(userDefaults: UserDefaults())
        return SettingsUseCase(repository: repository)
    }
}
