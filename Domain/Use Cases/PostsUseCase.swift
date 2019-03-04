//
//  DeckUseCases.swift
//  Domain
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation
import RxSwift

public protocol PostsUseCase {
    func posts() -> Observable<[Post]>
    func save(post: Post) -> Observable<Void>
    func delete(post: Post) -> Observable<Void>
}
