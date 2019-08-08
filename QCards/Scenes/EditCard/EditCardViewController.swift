//
//  EditCardViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 11/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

class EditCardViewController: UIViewController, UITextViewDelegate {
    
    var viewModel: EditCardViewModel!
    
    private let saveButton = UIBarButtonItem(title: NSLocalizedString("Common.Save", comment: ""), style: .plain, target: self, action: nil)
    private let deleteButton = UIBarButtonItem(title: NSLocalizedString("Common.Delete", comment: ""), style: .plain, target: self, action: nil)
    
    private lazy var titleTextField: UITextField = {
        let titleTextField = UITextField()
        
        themeService.rx
            .bind({ $0.primary }, to: titleTextField.rx.backgroundColor)
            .bind({ $0.inactiveTint }, to: titleTextField.rx.placeholderColor)
            .bind({ $0.activeTint }, to: titleTextField.rx.textColor)
            .disposed(by: rx.disposeBag)
        
        titleTextField.placeholder = NSLocalizedString("EditCard.TitleField.Placeholder", comment: "")
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        titleTextField.font = UIFont.systemFont(ofSize: 14)
        titleTextField.becomeFirstResponder()
        return titleTextField
    }()
    
    private lazy var contentTextView: BulletedTextView = {
        let contentTextView = BulletedTextView()
        
        themeService.rx
            .bind({ $0.activeTint }, to: contentTextView.rx.textColor)
            .bind({ $0.primary }, to: contentTextView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        contentTextView.layer.cornerRadius = 10
        contentTextView.font = UIFont.systemFont(ofSize: 14)
        return contentTextView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("EditCard.ContentField.Placeholder", comment: "")
        placeholderLabel.font = UIFont.systemFont(ofSize: (contentTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (contentTextView.font?.pointSize)! / 2)
        themeService.rx.bind({ $0.inactiveTint}, to: placeholderLabel.rx.textColor).disposed(by: rx.disposeBag)
        placeholderLabel.isHidden = true
        return placeholderLabel
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
        
        themeService.rx
            .bind({ $0.secondary}, to: view.rx.backgroundColor)
            .bind({ $0.danger}, to: deleteButton.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItems = [saveButton, deleteButton]
    }
    
    private func bindViewModel() {
        let deleteCardTrigger = deleteButton.rx.tap.flatMap { row in
            return UIAlertController
                .present(in: self, text: UIAlertController.AlertText(
                    title: NSLocalizedString("EditCard.DeleteCard.Title", comment: ""),
                    message: NSLocalizedString("EditCard.DeleteCard.Subtitle", comment: "")),
                         style: .alert,
                         buttons: [.default(NSLocalizedString("Common.Yes", comment: "")), .cancel(NSLocalizedString("Common.No", comment: ""))],
                         textFields: [])
                .withLatestFrom(Observable.just(row)) { alertData, row in
                    return (alertData.0, row)
                }
            }
            .filter { $0.0 == 0 }
            .map { $0.1 }
        
        let input = EditCardViewModel.Input(
            saveTrigger: saveButton.rx.tap.asDriver(),
            deleteTrigger: deleteCardTrigger.asDriverOnErrorJustComplete(),
            title: titleTextField.rx.text.orEmpty.asDriver(),
            content: contentTextView.rx.text.orEmpty.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.card.drive(cardBinding),
         output.save.drive(),
         output.saveEnabled.drive(saveButton.rx.isEnabled),
         output.delete.drive()]
            .forEach({$0.disposed(by: rx.disposeBag)})
    }
    
    var cardBinding: Binder<Card> {
        return Binder(self, binding: { (vc, card) in
            vc.titleTextField.text = card.title
            vc.contentTextView.text = card.content
            vc.title = card.title
        })
    }
}
