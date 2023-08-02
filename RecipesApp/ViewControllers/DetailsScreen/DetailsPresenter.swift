//
//  DetailsViewModel.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 27.10.21.
//

import Foundation

protocol DetailsPresenterProtocol: AnyObject {
    func viewIsReady()
    func switchSegmentControll(index: Int)
    func deleteRecipe()
}

class DetailsPresenter: DetailsPresenterProtocol {
    var recipe: Recipe
    var recipesManager: RecipesManagerProtocol
    weak var view: RecipeDetailsViewControllerProtocol?
    
    init(recipe: Recipe, recipesManager: RecipesManagerProtocol) {
        self.recipe = recipe
        self.recipesManager = recipesManager
    }
    
    func viewIsReady() {
        setRecipeData()
        setImage()
    }
    
    private func setRecipeData() {
        let recipeData = RecipeDetailsViewModel(name: recipe.name, rating: Constants.noRatingImage, ingredients: recipe.ingredients)
        view?.setRecipeParams(recipe: recipeData)
    }
    
    private func setImage() {
        // here we ignore failure scenario because image is placeholder by default
        if let url = URL(string: recipe.imageURL) {
            ImageCache.publicCache.load(url: url as NSURL) { [weak self] image in
                if let recipeImage = image {
                    DispatchQueue.main.async {
                        self?.view?.setRecipeImage(image: recipeImage)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self?.view?.setRecipeImage(image: Constants.placeHolderImage)
                    }
                }
            }
        }
    }
    
    func switchSegmentControll(index: Int) {
        switch index
        {
        case 0:
            view?.setSegmentControllerText(text: recipe.ingredients)
        case 1:
            view?.setSegmentControllerText(text: recipe.steps)
        default:
            break
        }
    }
    
    func deleteRecipe() {
        view?.showLoadingIndicator()
        recipesManager.deleteRecipe(id: recipe.id, completion: { [weak self]
            result in
            self?.view?.hideLoadingIndicator()
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.view?.popBackToList()
                }
            case .failure(let error):
                if error == .authenticationError {
                    DispatchQueue.main.async {
                        NotificationCenter.default
                            .post(name: NSNotification.Name("session.expired"),
                                  object: nil)
                        self?.view?.popBackToList()
                    }
                }
                // get here if authentication is ok but response is still not fine
                else {
                    DispatchQueue.main.async {
                        self?.view?.hideLoadingIndicator()
                        self?.view?.showAlertForDeleteFailure()
                    }
                }
            }
        })
    }
}
