//
//  DeckViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift

class DeckViewModel {
    
    // MARK: inputs
    private let deckProvider: IDeckProvider?
    let selectedDeck = PublishRelay<IndexPath>()
    let deleteCommand = PublishRelay<(Int, [String])>()
    let addCommand = PublishRelay<String>()
    
    // MARK: outputs
    public let decks: BehaviorRelay<[Deck]> = BehaviorRelay(value: [])
    
    private var notificationToken: NotificationToken?
    private let disposeBag = DisposeBag()
    
    init(deckProvider: IDeckProvider) {
        self.deckProvider = deckProvider
        
        setupCommands()

        if let deckResults = self.deckProvider?.fetch() {
            observeChanges(to: deckResults)
        }
    }
    
    private func setupCommands() {
        deleteCommand
            .map { $0.0 }
            .withLatestFrom(selectedDeck) { _, selectedDeck in
                return selectedDeck.row
            }
            .withLatestFrom(decks) { selectedDeck, decks in
                return decks[selectedDeck].id
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] id in
                self?.deckProvider?.delete(primaryKey: Int(id)!)
            })
            .disposed(by: disposeBag)
        
        addCommand
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] name in
                self?.deckProvider?.add(name: name)
            })
            .disposed(by: disposeBag)
    }
    
    func observeChanges(to deckResults: Results<DeckEntity>) {
        
        notificationToken = deckResults.observe({ [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                deckResults.forEach({ deckEntity in
                    let deck = Deck(id: "\(deckEntity.id)", name: deckEntity.name)
                    self?.decks.append(deck)
                })
                
            case .update(_, let deletions, let insertions, _):
                deletions.forEach({ index in
                    self?.decks.remove(at: index)
                })
                
                insertions.forEach({ index in
                    let deckEntity = deckResults[index]
                    self?.decks.append(Deck(id: "\(deckEntity.id)", name: deckEntity.name))
                })
                
                /*modifications.forEach({ index in
                    let deckEntity = deckResults[index]
                    
                    guard let index = self?.decks.value.index(where: { Int($0.id!) == deckEntity.id }) else {
                        print("Deck for the index does not exist.")
                        return
                    }
                    
                    var deck = self?.decks.value[index]
                    deck?.name = deckEntity.name
                })*/
                
            case .error(let error):
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}
