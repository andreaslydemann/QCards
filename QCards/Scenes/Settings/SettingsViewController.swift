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
    
    private let store = PublishSubject<Void>()
    private let okButton = UIBarButtonItem(title: NSLocalizedString("Common.OK", comment: ""),
                                           style: .plain, target: self, action: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        self.store.onNext(())
    }
    
    override func viewDidLoad() {
        super.loadView()
        
        setupLayout()
        setupNavigationItems()
        bindViewModel()
    }
    
    private func setupLayout() {
        themeService.rx.bind({ $0.secondary }, to: tableView.rx.backgroundColor)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseID)
        tableView.register(TimeTableViewCell.self, forCellReuseIdentifier: TimeTableViewCell.reuseID)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = okButton
        navigationItem.title = NSLocalizedString("Settings.Navigation.Title", comment: "")
        okButton.accessibilityLabel = "okButton"
    }
    
    private func bindViewModel() {
        let viewWillAppear = store.asDriverOnErrorJustComplete()
        
        let input = SettingsViewModel.Input(trigger: viewWillAppear, okTrigger: okButton.rx.tap.asDriver(), selection: tableView.rx.modelSelected(SettingsSectionItem.self).asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.dismiss.drive(),
         output.selectedEvent.drive(),
         output.items
            .drive(tableView.rx.items(dataSource: createDataSource()))]
            .forEach({$0.disposed(by: rx.disposeBag)})
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
                case .darkModeItem(let viewModel):
                    let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseID, for: indexPath) as! SwitchTableViewCell
                    cell.bind(to: viewModel)
                    return cell
                }
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource[index].title
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            themeService.rx
                .bind({ $0.activeTint }, to: view.textLabel!.rx.textColor)
                .bind({ $0.secondary }, to: view.contentView.rx.backgroundColor)
                .disposed(by: rx.disposeBag)
        }
    }
}
