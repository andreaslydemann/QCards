//
//  PresentationViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 13/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class PresentationViewController: UIViewController, UICollectionViewDelegate {
    
    var viewModel: PresentationViewModel!
    
    private let disposeBag = DisposeBag()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.delegate = self
        collectionView.register(PresentationCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.isPagingEnabled = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        
        return collectionView
    }()
    
    private lazy var footerView: UIStackView = {
        let footerView = UIStackView(arrangedSubviews: [stopButton])
        footerView.distribution = .equalCentering
        return footerView
    }()
    
    private var stopButton: UIButton = {
        let stopButton = UIButton(type: .system)
        stopButton.setImage(UIImage(named: "stop"), for: .normal)
        stopButton.tintColor = .white
        return stopButton
    }()
    
    private var divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        return divider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupCollectionView() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        view.addSubview(collectionView)
        view.addSubview(divider)
        view.addSubview(footerView)
        
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: divider.topAnchor, trailing: view.trailingAnchor)
        divider.anchor(top: collectionView.bottomAnchor, leading: view.leadingAnchor, bottom: footerView.topAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 1))
        footerView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 50))
        
        view.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = PresentationViewModel.Input(trigger: viewWillAppear,
        dismissTrigger: stopButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.cards
            .map { [CardSection(items: $0)] }
            .drive(collectionView.rx.items(dataSource: createDataSource())),
            output.dismiss.drive()]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    private func createDataSource() -> RxCollectionViewSectionedAnimatedDataSource<CardSection> {
        return RxCollectionViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(reloadAnimation: .fade),
            configureCell: { _, collectionView, indexPath, card -> PresentationCollectionViewCell in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PresentationCollectionViewCell
                cell.bind(card)
                return cell
        })
    }
}

extension PresentationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
