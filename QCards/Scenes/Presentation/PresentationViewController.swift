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
    private let store = PublishSubject<Int>()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(PresentationCollectionViewCell.self, forCellWithReuseIdentifier: PresentationCollectionViewCell.cellId)
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.isPagingEnabled = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        
        return collectionView
    }()
    
    let footerView: UIView = {
        let footerView = UIView()
        return footerView
    }()
    
    let cardNumber: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let countdownTime: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private var stopButton: UIButton = {
        let stopButton = UIButton(type: .system)
        stopButton.setImage(UIImage(named: "stop"), for: .normal)
        stopButton.tintColor = UIColor.UIColorFromHex(hex: "#1DA1F2")
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        
        footerView.addSubview(countdownTime)
        footerView.addSubview(stopButton)
        footerView.addSubview(cardNumber)
        
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: divider.topAnchor, trailing: view.trailingAnchor)
        divider.anchor(top: collectionView.bottomAnchor, leading: view.leadingAnchor, bottom: footerView.topAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 1))
        footerView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 50))
        countdownTime.anchor(top: footerView.topAnchor, leading: footerView.leadingAnchor, bottom: footerView.bottomAnchor, trailing: nil)
        stopButton.anchor(top: footerView.topAnchor, leading: footerView.leadingAnchor, bottom: footerView.bottomAnchor, trailing: footerView.trailingAnchor)
        cardNumber.anchor(top: footerView.topAnchor, leading: nil, bottom: footerView.bottomAnchor, trailing: footerView.trailingAnchor)

        view.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let nextCardTrigger = store.startWith(0).distinctUntilChanged().share()

        let input = PresentationViewModel.Input(trigger: viewWillAppear,
                                                nextCardTrigger: nextCardTrigger,
                                                dismissTrigger: stopButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.cards
            .map { [CardSection(items: $0)] }
            .drive(collectionView.rx.items(dataSource: createDataSource())),
         output.cardNumber.drive(cardNumber.rx.text),
         output.dismiss.drive(),
         output.hideCountdown.drive(countdownTime.rx.isHidden),
         output.activeNextCardFlash.do(onNext: { [weak self] (activeNextCardFlash) in
            activeNextCardFlash ? self?.startAnimation() : self?.stopAnimation()
         }).drive(),
         output.countdownTime.drive(countdownTime.rx.text)]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    func startAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
        collectionView.layer.add(pulseAnimation, forKey: nil)
    }
    
    func stopAnimation() {
        collectionView.layer.removeAllAnimations()
    }
    
    private func createDataSource() -> RxCollectionViewSectionedAnimatedDataSource<CardSection> {
        return RxCollectionViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(reloadAnimation: .fade),
            configureCell: { _, collectionView, indexPath, card -> PresentationCollectionViewCell in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresentationCollectionViewCell.cellId, for: indexPath) as! PresentationCollectionViewCell
                cell.bind(card)
                return cell
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x / w))
        self.store.onNext(currentPage)
    }
}

extension PresentationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
