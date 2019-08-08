//
//  SettingsViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 17/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class SettingsViewController: UITableViewController {
    
    var viewModel: SettingsViewModel!
    
    private let disposeBag = DisposeBag()
    private let okButton = UIBarButtonItem(title: NSLocalizedString("Common.OK", comment: ""),
                                           style: .plain, target: self, action: nil)
    
    override func loadView() {
        super.loadView()
        
        setupLayout()
        setupNavigationItems()
        bindViewModel()
    }
    
    private func setupLayout() {
        tableView.backgroundColor = UIColor.UIColorFromHex(hex: "#10171E")
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseID)
        tableView.register(TimeTableViewCell.self, forCellReuseIdentifier: TimeTableViewCell.reuseID)
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = okButton
        navigationItem.title = NSLocalizedString("Settings.Navigation.Title", comment: "")
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SettingsViewModel.Input(trigger: viewWillAppear, okTrigger: okButton.rx.tap.asDriver(), selection: tableView.rx.modelSelected(SettingsSectionItem.self).asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.dismiss.drive(),
         output.selectedEvent.drive(),
         output.items
            .drive(tableView.rx.items(dataSource: createDataSource()))]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<SettingsSection> {
        return RxTableViewSectionedReloadDataSource<SettingsSection>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch item {
                case .timePerCardItem(let viewModel):
                    let cell = tableView.dequeueReusableCell(withIdentifier: TimeTableViewCell.reuseID, for: indexPath) as! TimeTableViewCell
                    cell.bind(to: viewModel)
                    return cell
                case .nextCardFlashItem(let viewModel),
                     .nextCardVibrateItem(let viewModel):
                    let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseID, for: indexPath) as! SwitchTableViewCell
                    cell.bind(to: viewModel)
                    return cell
                }
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource[index].title
        })
    }
}
