//
//  ViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/11/2018.
//  Copyright © 2018 Andreas Lüdemann. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class DeckViewController: UITableViewController {
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let deckCellId = "deckCellId"
    private var viewModel: DeckViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = DeckViewModel(deckProvider: DeckProvider.shared)
        
        populateTableView()
        setupBindings()
        setupTableView()
        setupNavigationBar()
    }
    
    private func populateTableView() {
        let dataSource = RxTableViewRealmDataSource<DeckEntity>(cellIdentifier: deckCellId, cellType: DeckTableViewCell.self) { cell, _, deck in
            cell.configure(withItem: deck)
        }
        
        Observable
            .changeset(from: viewModel.decks)
            .bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        tableView.register(DeckTableViewCell.self, forCellReuseIdentifier: deckCellId)
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
        navigationItem.rightBarButtonItem = addButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.title = "QCards"
    }
    
    private func displayAlertToAddDeck(_ index: Int?) {
        var title = "New Deck"
        var message = "Input a name for the deck"
        var actionTitle = "Create"
        
        if index != nil {
            title = "Update Deck"
            message = "Update the name of the deck"
            actionTitle = "Update"
        }
        
        /*if let index = index {
            addCategoryAlert.textFields?[0].text = self.categoryListViewModel.getCategories()[index].name
        }*/
        
        UIAlertController
            .present(in: self, text: UIAlertController.AlertText(
                title: title, message: message),
                     style: .alert, buttons: [.default(actionTitle), .cancel("Cancel")],
                     textFields: [ {(textfield: UITextField) -> Void in textfield.placeholder = "Presentation"} ])
            .filter { $0.0 == 0 && $0.1[0] != "" }
            .map { $0.1[0] }
            .bind(to: self.viewModel.addCommand)
            .disposed(by: self.disposeBag)
    }
    
    private func displayAlertToDeleteDeck(withIndex index: Int) {
        UIAlertController
            .present(in: self, text: UIAlertController.AlertText(
                title: "Do you want to delete this deck?",
                message: "You can't undo this action"),
                     style: .alert,
                     buttons: [.default("Yes"), .cancel("No")],
                     textFields: [])
            .filter { $0.0 == 0 }
            .map { _ in index }
            .bind(to: viewModel.deleteCommand)
            .disposed(by: self.disposeBag)
    }
    
    private func setupBindings() {
        self.tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
                //self.performSegue(withIdentifier: "goToTaskList", sender: self.categoryListViewModel.getCategories()[indexPath.row])
            })
            .disposed(by: disposeBag)
        
        addButton.rx.tap.subscribe(onNext: {
            self.displayAlertToAddDeck(nil)
        }).disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    private func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit", handler: { _, _, completion in
            self.displayAlertToAddDeck(indexPath.row)
            completion(true)
        })
        action.image = #imageLiteral(resourceName: "edit")
        action.backgroundColor = .purple
        
        return action
    }
    
    private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete", handler: { _, _, completion in
            self.displayAlertToDeleteDeck(withIndex: indexPath.row)
            
            //self.viewModel.selectedDeck.onNext(indexPath)
            
            //self.categoryListViewModel.removeCategory(withIndex: indexPath.row)
            completion(true)
        })
        action.image = #imageLiteral(resourceName: "trash")
        action.backgroundColor = .red
        
        return action
    }
}
