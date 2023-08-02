//
//  RecipeViewControllerGrid.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 14.10.21.
//
import UIKit

struct RecipeViewModel {
    let name: String
    let rating: UIImage
    let imageURL: String
    var image: UIImage?
    init (name: String, rating: UIImage, imageURL: String) {
        self.name = name
        self.rating = rating
        self.imageURL = imageURL
    }
    
    // set image separately in case we don't have one
    mutating func setImage(image: UIImage) {
        self.image = image
    }
}

struct RecipeDetailsViewModel {
    let name: String
    let rating: UIImage
    let ingredients: String
    init (name: String, rating: UIImage, ingredients: String) {
        self.name = name
        self.rating = rating
        self.ingredients = ingredients
    }
}
