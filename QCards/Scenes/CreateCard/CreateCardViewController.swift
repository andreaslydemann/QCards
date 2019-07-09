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
        let titleTextField = UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        titleTextField.placeholder = "Enter title here"
        titleTextField.borderStyle = .roundedRect
        return titleTextField
    }()
    
    private var contentTextView: UITextView = {
        let contentTextField = UITextView(frame: CGRect(x: 20.0, y: 30.0, width: 300.0, height: 40))
        return contentTextField
    }()
    
    private lazy var fieldsView: UIStackView = {
        let fieldsView = UIStackView(arrangedSubviews: [titleTextField, contentTextView])
        fieldsView.axis = .vertical
        fieldsView.distribution = .equalCentering
        return fieldsView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupLayout() {
        view.backgroundColor = .blue
        view.addSubview(fieldsView)
 
        fieldsView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#0E3D5B")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.view.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.title = "Create Card"
    }
    
    private func bindViewModel() {
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
