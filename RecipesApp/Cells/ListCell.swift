//
//  ListCell.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 7.10.21.
//

import Foundation
import UIKit

class ListCell: UICollectionViewCell {
    @IBOutlet weak var imageViewList: UIImageView!
    @IBOutlet weak var ratingImageList: UIImageView!
    @IBOutlet weak var nameLabelList: UILabel!
    @IBOutlet weak var sourceLabelList: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setImageWithTransition(image: UIImage) {
        UIView.transition(with: imageViewList,
                          duration: 0.6,
                          options: .transitionCrossDissolve,
                          animations: {
            self.imageViewList.image = image
        }, completion: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewList.image = nil
    }
}
