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

final class EditCardViewController: UIViewController, UITextViewDelegate {
    
    var viewModel: EditCardViewModel!
    
    private let disposeBag = DisposeBag()
    private let store = PublishSubject<(RowAction, Int)>()
    
    private let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil)
    private let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: nil)
    
    private var titleTextField: UITextField = {
        let titleTextField = UITextField()
        titleTextField.placeholder = "Enter title here"
        titleTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        titleTextField.layer.cornerRadius = 10
        titleTextField.font = UIFont.systemFont(ofSize: 14)
        return titleTextField
    }()
    
    private var contentTextView: UITextView = {
        let contentTextView = UITextView()
        contentTextView.backgroundColor = UIColor(white: 0, alpha: 0.03)
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
        return placeholderLabel
    }()
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    private lazy var fieldsView: UIStackView = {
        let fieldsView = UIStackView(arrangedSubviews: [titleTextField, contentTextView])
        
        fieldsView.axis = .vertical
        fieldsView.spacing = 10
        return fieldsView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        contentTextView.delegate = self
        contentTextView.addSubview(placeholderLabel)
        
        view.addSubview(fieldsView)
        
        fieldsView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#0E3D5B")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.view.tintColor = .white
        navigationItem.rightBarButtonItems = [editButton, deleteButton]
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.title = "Edit Card"
    }
    
    private func bindViewModel() {
        let deleteCardTrigger = store
            .filter { $0.0 == RowAction.delete }.flatMap { _, row in
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
            editCardTrigger: editButton.rx.tap.asDriver(),
            deleteCardTrigger: deleteCardTrigger.asDriverOnErrorJustComplete(),
            title: titleTextField.rx.text.orEmpty.asDriver(),
            content: contentTextView.rx.text.orEmpty.asDriver())
    
        let output = viewModel.transform(input: input)
        
        [output.editButtonTitle.drive(editButton.rx.title),
         output.editing.drive(titleTextField.rx.isEnabled),
         output.editing.drive(contentTextView.rx.isEditable),
         output.card.drive(cardBinding),
         output.save.drive(),
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

extension Reactive where Base: UITextView {
    var isEditable: Binder<Bool> {
        return Binder(self.base, binding: { (textView, isEditable) in
            textView.isEditable = isEditable
        })
    }
}
