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
    
    private let cancelButton = UIBarButtonItem(title: NSLocalizedString("Common.Cancel", comment: ""), style: .plain, target: self, action: nil)
    private let saveButton = UIBarButtonItem(title: NSLocalizedString("Common.Save", comment: ""), style: .plain, target: self, action: nil)
    
    private lazy var titleTextField: UITextField = {
        let titleTextField = UITextField()
        titleTextField.placeholder = NSLocalizedString("CreateCard.TitleField.Placeholder", comment: "")
        titleTextField.accessibilityLabel = "cardTitleTextField"
        
        themeService.rx
            .bind({ $0.primary }, to: titleTextField.rx.backgroundColor)
            .bind({ $0.inactiveTint }, to: titleTextField.rx.placeholderColor)
            .bind({ $0.activeTint }, to: titleTextField.rx.textColor)
            .disposed(by: rx.disposeBag)
        
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        titleTextField.font = UIFont.systemFont(ofSize: 14)
        titleTextField.becomeFirstResponder()
        return titleTextField
    }()
    
    private lazy var contentTextView: BulletedTextView = {
        let contentTextView = BulletedTextView()
        contentTextView.accessibilityLabel = "cardContentTextView"
        
        themeService.rx
            .bind({ $0.activeTint }, to: contentTextView.rx.textColor)
            .bind({ $0.primary }, to: contentTextView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        contentTextView.layer.cornerRadius = 10
        contentTextView.font = UIFont.systemFont(ofSize: 14)
        return contentTextView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("CreateCard.ContentField.Placeholder", comment: "")
        label.font = UIFont.systemFont(ofSize: (contentTextView.font?.pointSize)!)
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 5, y: (contentTextView.font?.pointSize)! / 2)
        themeService.rx.bind({ $0.inactiveTint }, to: label.rx.textColor).disposed(by: rx.disposeBag)
        return label
    }()
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNavigationItems()
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
                              padding: .init(top: 20, left: 15, bottom: 20, right: 15), size: .init(width: 0, height: 30))
        
        contentTextView.anchor(top: titleTextField.bottomAnchor,
                               leading: view.leadingAnchor,
                               bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               trailing: view.trailingAnchor,
                               padding: .init(top: 20, left: 15, bottom: 0, right: 15))
        
        themeService.rx.bind({ $0.secondary }, to: view.rx.backgroundColor).disposed(by: rx.disposeBag)
    }
    
    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = NSLocalizedString("CreateCard.Navigation.Title", comment: "")
        navigationItem.accessibilityLabel = "createCardNavigationTitle"
        cancelButton.accessibilityLabel = "cancelButton"
        saveButton.accessibilityLabel = "saveButton"
    }
    
    private func bindViewModel() {
        let input = CreateCardViewModel.Input(cancelTrigger: cancelButton.rx.tap.asDriver(),
                                              saveTrigger: saveButton.rx.tap.asDriver(),
                                              title: titleTextField.rx.text.orEmpty.asDriver(),
                                              content: contentTextView.rx.text.orEmpty.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.dismiss.drive(),
         output.saveEnabled.drive(saveButton.rx.isEnabled)]
            .forEach({$0.disposed(by: rx.disposeBag)})
    }
}
