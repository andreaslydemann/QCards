//
//  SettingsViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 17/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

class SettingsViewController: UITableViewController {
    
    var viewModel: SettingsViewModel!
    
    private let disposeBag = DisposeBag()
    private let okButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: nil)
    
    var firstNameCell: UITableViewCell = UITableViewCell()
    var lastNameCell: UITableViewCell = UITableViewCell()
    var shareCell: UITableViewCell = UITableViewCell()
    
    var firstNameText: UITextField = UITextField()
    var lastNameText: UITextField = UITextField()
    
    override func loadView() {
        super.loadView()
        
        setupTableView()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupTableView() {
        self.firstNameCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.firstNameText = UITextField(frame: self.firstNameCell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.firstNameText.placeholder = "First Name"
        self.firstNameCell.addSubview(self.firstNameText)
        
        self.lastNameCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.lastNameText = UITextField(frame: self.lastNameCell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.lastNameText.placeholder = "Last Name"
        self.lastNameCell.addSubview(self.lastNameText)
        
        self.shareCell.textLabel?.text = "Share with Friends"
        self.shareCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.shareCell.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#0E3D5B")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.view.tintColor = .white
        navigationItem.rightBarButtonItem = okButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.title = "Settings"
    }
    
    private func bindViewModel() {
        let input = SettingsViewModel.Input(okTrigger: okButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.dismiss.drive()]
            .forEach({$0.disposed(by: disposeBag)})
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        default: fatalError("Unknown number of sections")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return self.firstNameCell
            case 1: return self.lastNameCell
            default: fatalError("Unknown row in section 0")
            }
        case 1:
            switch indexPath.row {
            case 0: return self.shareCell
            default: fatalError("Unknown row in section 1")
            }
        default: fatalError("Unknown section")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Profile"
        case 1: return "Social"
        default: fatalError("Unknown section")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)

            if self.shareCell.accessoryType == UITableViewCell.AccessoryType.none {
                self.shareCell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                self.shareCell.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
    }
}
