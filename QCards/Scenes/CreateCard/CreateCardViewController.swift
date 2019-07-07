//
//  CreateCardViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 08/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

final class CreateCardViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    var viewModel: CreateCardViewModel!
    
    private let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: nil)
    private let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil)
    
    private var titleTextField: UITextField = {
        let titleTextField = UITextField()
        return titleTextField
    }()
    
    private var contentTextView: UITextView = {
        let contentTextField = UITextView()
        return contentTextField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let input = CreateCardViewModel.Input(cancelTrigger: cancelButton.rx.tap.asDriver(),
                                              saveTrigger: saveButton.rx.tap.asDriver(),
                                              title: titleTextField.rx.text.orEmpty.asDriver(),
                                              content: contentTextView.rx.text.orEmpty.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.dismiss.drive(),
         output.saveEnabled.drive(saveButton.rx.isEnabled)]
        .forEach({$0.disposed(by: disposeBag)})
    }
}
