//
//  TimeTableViewCell.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxSwift
import UIKit

final class TimeTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        themeService.rx.bind({ $0.activeTint }, to: label.rx.textColor).disposed(by: rx.disposeBag)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        themeService.rx.bind({ $0.inactiveTint }, to: label.rx.textColor).disposed(by: rx.disposeBag)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    private func setupLayout() {
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
        themeService.rx.bind({ $0.primary }, to: self.rx.backgroundColor).disposed(by: rx.disposeBag)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, timeLabel])
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,
                         padding: .init(top: 8, left: 20, bottom: 8, right: 40), size: .init(width: 0, height: 35))
    }
    
    func bind(to viewModel: TimeCellViewModel) {
        titleLabel.text = viewModel.title
        
        viewModel
            .transform(input: TimeCellViewModel.Input()).timePerCard
            .map { TimePerCard.displayName(option: $0) }
            .drive(timeLabel.rx.text).disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
