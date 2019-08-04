//
//  TimePerCardViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 04/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class TimePerCardViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    
    private let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNavigationItems()
        bindViewModel()
    }
    
    private func setupLayout() {
        tableView.backgroundColor = UIColor.UIColorFromHex(hex: "#10171E")
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = "Settings"
    }
    
    private func bindViewModel() {
        
    }
    
    /*
    func setupLayout() {
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = R.string.localizable.languageNavigationTitle.key.localized()
            self?.saveButtonItem.title = R.string.localizable.commonSave.key.localized()
        }).disposed(by: rx.disposeBag)
        
        navigationItem.rightBarButtonItem = saveButtonItem
        tableView.register(R.nib.languageCell)
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel as? LanguageViewModel else { return }
        
        let refresh = Observable.of(Observable.just(()),
                                    languageChanged.asObservable()).merge()
        let input = LanguageViewModel.Input(trigger: refresh,
                                            saveTrigger: saveButtonItem.rx.tap.asDriver(),
                                            selection: tableView.rx.modelSelected(LanguageCellViewModel.self).asDriver())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: reuseIdentifier, cellType: LanguageCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
            }.disposed(by: rx.disposeBag)
        
        output.saved.drive(onNext: { [weak self] () in
            self?.navigator.dismiss(sender: self)
        }).disposed(by: rx.disposeBag)
    }*/
}
