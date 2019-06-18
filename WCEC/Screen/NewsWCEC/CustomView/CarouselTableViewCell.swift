//
//  CarouselTableViewCell.swift
//  WCEC
//
//  Created by GEM on 8/3/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class CarouselTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentIndex: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: CarouselCollectionViewCell.classString(), bundle: nil),
                                forCellWithReuseIdentifier: CarouselCollectionViewCell.classString())
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { collectionView.contentOffset.x = newValue }
        get { return collectionView.contentOffset.x }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        //        visibleRect.origin = collectionView.contentOffset
        //        visibleRect.size = collectionView.bounds.size
        //        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        //        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        //        currentIndex = indexPath.row + 1
        //        pageControl.currentPage = indexPath.row
    }
}
