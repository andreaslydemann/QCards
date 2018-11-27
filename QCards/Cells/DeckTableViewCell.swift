//
//  DeckTableViewCell.swift
//  QCards
//
//  Created by Andreas Lüdemann on 26/11/2018.
//  Copyright © 2018 Andreas Lüdemann. All rights reserved.
//

import SwipeCellKit
import UIKit

class DeckTableViewCell: SwipeTableViewCell {

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    /*let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()*/

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(nameLabel)
        //addSubview(timeLabel)

        nameLabel.centerInSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
