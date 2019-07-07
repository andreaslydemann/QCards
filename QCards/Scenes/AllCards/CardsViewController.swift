//
//  CardsViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class CardsViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let store = PublishSubject<(RowAction, Int)>()
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
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
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
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = CardsViewModel.Input(trigger: viewWillAppear, editTrigger: editButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.cards
            .map { [DeckSection(items: $0)] }
            .drive(tableView.rx.items(dataSource: createDataSource())),
         output.editing.do(onNext: { editing in
            self.tableView.isEditing = editing
         }).drive()]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    private func createDataSource() -> RxTableViewSectionedAnimatedDataSource<DeckSection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, deck -> DeckTableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: DeckTableViewCell.reuseID, for: indexPath) as! DeckTableViewCell
                cell.shouldIndentWhileEditing = true
                cell.accessoryType = .disclosureIndicator
                cell.bind(deck)
                return cell
            },
            canEditRowAtIndexPath: { _, _ in true },
            canMoveRowAtIndexPath: { _, _ in true }
        )
    }
}

extension CardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { _, indexPath in
            self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
            return
        }
        
        return [deleteButton]
    }
}
