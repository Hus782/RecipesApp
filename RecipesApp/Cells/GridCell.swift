//
//  RecipeCell.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 12.10.21.
//

import UIKit

class GridCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ratingImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setImageWithTransition(image: UIImage) {
        UIView.transition(with: imageView,
                          duration: 0.6,
                          options: .transitionCrossDissolve,
                          animations: {
            self.imageView.image = image
        }, completion: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
