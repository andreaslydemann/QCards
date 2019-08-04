//
//  SwitchTableViewCell.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxSwift
import UIKit

final class SwitchTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = UIColor.UIColorFromHex(hex: "#1DA1F2")
        return switchView
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    private func setupLayout() {
        self.selectionStyle = .none
        self.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, switchView])
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,
                         padding: .init(top: 10, left: 20, bottom: 6, right: 15), size: .init(width: 0, height: 35))
    }
    
    func bind(to viewModel: SwitchCellViewModel) {
        titleLabel.text = viewModel.title
        
        let trigger = switchView.rx.isOn.changed.asDriver()
        
        viewModel
            .transform(input: SwitchCellViewModel.Input(trigger: trigger))
            .isEnabled.drive(switchView.rx.isOn)
            .disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
