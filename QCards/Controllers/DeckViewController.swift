//
//  ViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/11/2018.
//  Copyright © 2018 Andreas Lüdemann. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import RxSwift

class DeckController: UITableViewController, SwipeTableViewCellDelegate {
    
    let realm = try! Realm()
    
    var decks: Results<Deck>?
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDecks()
        // print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        tableView.rowHeight = 80
        view.backgroundColor = .white
        
        tableView.register(DeckTableViewCell.self, forCellReuseIdentifier: cellId)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#34495e")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.title = "QCards"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DeckTableViewCell
        cell.delegate = self
        
        if let deck = decks?[indexPath.row] {
            cell.textLabel?.text = deck.name
            //cell.labTime.text = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .short, timeStyle: .short)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            self.updateModel(at: indexPath)
            action.fulfill(with: .delete)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .border
        options.expansionStyle = .none
        return options
        
    }
    
    func save(deck: Deck) {
        do {
            try realm.write {
                realm.add(deck)
            }
        } catch {
            print("Error saving deck \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadDecks() {
        decks = realm.objects(Deck.self)
        
        tableView.reloadData()
    }
    
    func updateModel(at indexPath: IndexPath) {
        if let deckForDeletion = self.decks?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(deckForDeletion)
                }
            } catch {
                print("Error deleting deck, \(error)")
            }
        }
    }
    
    @IBAction func addButtonPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Deck", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newDeck = Deck()
            newDeck.name = textField.text!
            
            self.save(deck: newDeck)
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Presentation"
        }
        
        present(alert, animated: true, completion: nil)
    }
}
