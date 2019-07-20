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
    
    private let disposeBag = DisposeBag()
    
    private let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil)
    private let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: nil)
    
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
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = true
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
        deleteButton.tintColor = UIColor.UIColorFromHex(hex: "#DF245E")
    }
    
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#15202B")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.view.tintColor = .white
        navigationItem.rightBarButtonItems = [saveButton, deleteButton]
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    private func bindViewModel() {
        let deleteCardTrigger = deleteButton.rx.tap.flatMap { row in
                return UIAlertController
                    .present(in: self, text: UIAlertController.AlertText(
                        title: "Do you want to delete this card?",
                        message: "You can't undo this action"),
                             style: .alert,
                             buttons: [.default("Yes"), .cancel("No")],
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
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    var cardBinding: Binder<Card> {
        return Binder(self, binding: { (vc, card) in
            vc.titleTextField.text = card.title
            vc.contentTextView.text = card.content
            vc.title = card.title
        })
    }
    
}
