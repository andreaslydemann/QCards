//
//  DecksViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/03/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

class DecksViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    private let createDeckButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let store = PublishSubject<(RowAction, Int)>()
    var viewModel: DecksViewModel!
    
    enum RowAction {
        case edit
        case delete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupTableView() {
        tableView.register(DeckTableViewCell.self, forCellReuseIdentifier: DeckTableViewCell.reuseID)
        tableView.rowHeight = 80
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#34495e")
        navigationController?.navigationBar.barStyle = .black
        navigationItem.rightBarButtonItem = createDeckButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.title = "QCards"
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let createDeckTrigger = createDeckButton.rx.tap.flatMap {
            return UIAlertController
                .present(in: self, text: UIAlertController.AlertText(
                    title: "Create deck", message: "Input a title for the deck"),
                         style: .alert, buttons: [.default("Add"), .cancel("Cancel")],
                         textFields: [ {(textfield: UITextField) -> Void in textfield.placeholder = "Presentation"} ])
            }.map { $0.1[0] }
        
        let deleteDeckTrigger = store
            .filter { $0.0 == RowAction.delete }.flatMap { _, row in
                return Observable<Int>.create { observer in
                    let alert = UIAlertController(title: "Delete Deck",
                                                  message: "Do you want to delete this deck?",
                                                  preferredStyle: .alert)
                    
                    let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { _ -> Void in observer.onNext((row)) })
                    let noAction = UIAlertAction(title: "No", style: .cancel, handler: { _ -> Void in observer.onNext((-1)) })
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    return Disposables.create()
                }
        }
        
        let input = DecksViewModel.Input(trigger: viewWillAppear,
                                         createDeckTrigger: createDeckTrigger.asDriverOnErrorJustComplete(),
                                         deleteDeckTrigger: deleteDeckTrigger.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.decks.drive(tableView.rx.items(cellIdentifier: DeckTableViewCell.reuseID, cellType: DeckTableViewCell.self)) { _, viewModel, cell in
            cell.bind(viewModel)
            }.disposed(by: disposeBag)
        
        output.createDeck
            .drive()
            .disposed(by: disposeBag)
        
        output.deleteDeck
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { [unowned self] _, indexPath in
            self.store.onNext((RowAction.edit, indexPath.row))
        })
        
        edit.backgroundColor = .red
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] _, indexPath in
            self.store.onNext((RowAction.delete, indexPath.row))
        })
        
        delete.backgroundColor = .blue
        
        return [delete, edit]
    }
}
