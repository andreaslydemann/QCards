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
    
    var viewModel: DecksViewModel!
    
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
        
        let input = DecksViewModel.Input(trigger: viewWillAppear,
                                         createDeckTrigger: createDeckTrigger.asDriverOnErrorJustComplete(),
                                         selection: tableView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)
        
        output.decks.drive(tableView.rx.items(cellIdentifier: DeckTableViewCell.reuseID, cellType: DeckTableViewCell.self)) { tv, viewModel, cell in
            cell.bind(viewModel)
            }.disposed(by: disposeBag)
        
        output.createDeck
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: { _, _, completion in
            //self.displayAlertToAddDeck(indexPath.row)
            completion(true)
        })
        
        //editAction.image = #imageLiteral(resourceName: "edit")
        editAction.backgroundColor = .purple
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: { _, _, completion in
            //self.displayAlertToDeleteDeck(withIndex: indexPath.row)
            
            //self.viewModel.selectedDeck.onNext(indexPath)
            
            //self.categoryListViewModel.removeCategory(withIndex: indexPath.row)
            completion(true)
        })
        
        //deleteAction.image = #imageLiteral(resourceName: "trash")
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}
