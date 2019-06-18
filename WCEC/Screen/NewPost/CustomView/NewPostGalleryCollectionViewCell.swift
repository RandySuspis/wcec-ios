//
//  NewPostGalleryCollectionViewCell.swift
//  WCEC
//
//  Created by hnc on 6/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol NewPostGalleryCollectionViewCellDelegate: class {
    func didRemoveItem(cell: NewPostGalleryCollectionViewCell, atIndex: IndexPath)
}

extension NewPostGalleryCollectionViewCellDelegate {
    func didRemoveItem(cell: NewPostGalleryCollectionViewCell, atIndex: IndexPath) { }
}

class NewPostGalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var videoIcon: UIImageView!
    
    var index: IndexPath = IndexPath.init(row: -1, section: 0)
    public weak var delegate: NewPostGalleryCollectionViewCellDelegate?
    
    @IBAction func onSelectDeleteButton(_ sender: Any) {
        if index.row > -1 {
            self.delegate?.didRemoveItem(cell: self, atIndex: index)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
