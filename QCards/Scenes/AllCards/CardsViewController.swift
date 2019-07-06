//
//  CardsViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

final class CardsViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil)
    private lazy var tableView: UITableView = {
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        let tv = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tv.register(DeckTableViewCell.self, forCellReuseIdentifier: DeckTableViewCell.reuseID)
        tv.rowHeight = 65
        return tv
    }()
    var viewModel: CardsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#0E3D5B")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.view.tintColor = .white
        navigationItem.rightBarButtonItem = editButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.title = "Decks"
    }
    
    private func bindViewModel() {
        let input = CardsViewModel.Input(editTrigger: editButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.editing.do(onNext: { _ in print("hello") }).drive()]
            .forEach({$0.disposed(by: disposeBag)})
    }
}

extension Reactive where Base: UITextView {
    var isEditable: Binder<Bool> {
        return Binder(self.base, binding: { (textView, isEditable) in
            textView.isEditable = isEditable
        })
    }
}
