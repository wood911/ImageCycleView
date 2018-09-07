//
//  ImageCycleView.swift
//  dotdotbuy
//
//  Created by wtf on 2017/5/31.
//  Copyright © 2017年 Superbuy. All rights reserved.
//

import UIKit
import Kingfisher

/// 实现代理方法，点击图片的下标
protocol ImageCycleViewDelegate: AnyObject {
    func imageCycleView(_ cycleView: ImageCycleView, didSelectAt index: Int)
}

/// 图片轮播
class ImageCycleView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    /// 轮播时间 默认2s
    var interval: TimeInterval = 2
    /// 本地图片
    var localImages: [UIImage] = [] {
        didSet {
            reset(true, count: localImages.count)
        }
    }
    /// 网络图片
    var imageURLs: [String] = [] {
        didSet {
            reset(false, count: imageURLs.count)
        }
    }
    
    private func reset(_ local: Bool, count: Int) {
        isLocal = local
        collectionView.reloadData()
        pageControl.numberOfPages = count
        invalidateTimer()
        setupTimer()
    }
    
    fileprivate var isLocal = false
    
    private var timer: Timer?
    
    private weak var pageControl: UIPageControl!
    private weak var collectionView: UICollectionView!
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(autoScroll(_:)), userInfo: nil, repeats: true)
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func autoScroll(_ timer: Timer) {
        if collectionView.frame == CGRect.zero {
            return
        }
        let width = collectionView.frame.width
        let pages = Int(collectionView.contentSize.width / width)
        let index = Int(collectionView.contentOffset.x / width)
        if pages - index > 1 {
            pageControl.currentPage = index + 1
            collectionView.setContentOffset(CGPoint(x: CGFloat(index + 1) * width, y: collectionView.contentOffset.y), animated: true)
        } else {
            pageControl.currentPage = 0
            collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentOffset.y), animated: true)
        }
    }
    
    /// 图片点击代理
    weak var delegate: ImageCycleViewDelegate?
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        config()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        config()
    }
    
    private func config() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ImageCycleViewCell.self, forCellWithReuseIdentifier: "ImageCycleCell")
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.collectionView = collectionView
        
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.8)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 91.0/255.0, green: 160.0/255.0, blue: 1, alpha: 1)
        self.addSubview(pageControl)
        pageControl.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(15)
        })
        self.pageControl = pageControl
    }
    
    class ImageCycleViewCell: UICollectionViewCell {
        
        lazy var imageView: UIImageView = {
            let imageView = UIImageView(image: placeholderImageRec)
            self.contentView.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            return imageView
        }()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLocal ? localImages.count : imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCycleCell", for: indexPath) as! ImageCycleViewCell
        if isLocal {
            item.imageView.image = localImages[indexPath.item]
        } else {
            if let url = URL(string: imageURLs[indexPath.item]) {
                item.imageView.kf.setImage(with: ImageResource(downloadURL: url), placeholder: placeholderImageRec)
            }
        }
        return item
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.imageCycleView(self, didSelectAt: indexPath.item)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let curIndex = pageControl.currentPage
        let offsetX = scrollView.bounds.width * CGFloat(curIndex), width = scrollView.bounds.width * 0.5
        if scrollView.contentOffset.x - offsetX > width {
            pageControl.currentPage += 1
        } else if scrollView.contentOffset.x - offsetX < -width {
            pageControl.currentPage -= curIndex == 0 ? 0 : 1
        }
    }
    
    // 解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            invalidateTimer()
        }
    }
    
    // 解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
    deinit {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        invalidateTimer()
    }
    
}
