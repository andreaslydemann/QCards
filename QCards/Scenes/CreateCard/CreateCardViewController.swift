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

class CreateCardViewController: UIViewController, UITextViewDelegate {
    
    var viewModel: CreateCardViewModel!
        
    private let disposeBag = DisposeBag()
    private let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: nil)
    private let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil)
    
    private var titleTextField: UITextField = {
        let titleTextField = UITextField()
        titleTextField.textColor = .white
        titleTextField.attributedPlaceholder =
            NSAttributedString(string: "Enter title",
                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        titleTextField.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        titleTextField.font = UIFont.systemFont(ofSize: 14)
        titleTextField.becomeFirstResponder()
        return titleTextField
    }()
    
    private var contentTextView: UITextView = {
        let contentTextView = UITextView()
        contentTextView.textColor = .white
        contentTextView.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
        contentTextView.layer.cornerRadius = 10
        contentTextView.font = UIFont.systemFont(ofSize: 14)
        return contentTextView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some text..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (contentTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (contentTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = .lightGray
        return placeholderLabel
    }()
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupLayout() {
        hideKeyboardWhenTappedAround()
        
        contentTextView.delegate = self
        contentTextView.addSubview(placeholderLabel)

        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        
        titleTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.leadingAnchor,
                          bottom: nil,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 20, left: 20, bottom: 20, right: 20), size: .init(width: 0, height: 30))
        
        contentTextView.anchor(top: titleTextField.bottomAnchor,
                              leading: view.leadingAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              trailing: view.trailingAnchor,
                              padding: .init(top: 20, left: 20, bottom: 20, right: 20))
        
        view.backgroundColor = UIColor.UIColorFromHex(hex: "#10171E")
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#15202B")
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
