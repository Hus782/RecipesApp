//
//  RecipeDetailsViewController.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 6.10.21.
//

import UIKit

protocol RecipeDetailsViewControllerProtocol: AnyObject {
    func showConfirmationAlert()
    func showAlertForDeleteFailure()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func popBackToList()
    func setSegmentControllerText(text: String)
    func setRecipeParams(recipe: RecipeDetailsViewModel)
    func setRecipeImage(image: UIImage)
}

class RecipeDetailsViewController: UIViewController, RecipeDetailsViewControllerProtocol {
    var presenter: DetailsPresenter?
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var directionsLabel: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewIsReady()
    }
    
    private func createConfirmationAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Are you sure?", message: "This is going to permanently delete this recipe", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {[weak self] _ in
            self?.dismiss(animated: false, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:  {[weak self]
            action in
            self?.sendDeleteRequest()
        }))
        
        return alert
    }

    private func createLoadingIndicator() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        return alert
    }

    private func createAlertForDeleteFailure() -> UIAlertController {
        let alert = UIAlertController(title: "Something went wrong", message: "Could not delete  recipe", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {[weak self]
            action in
            self?.dismiss(animated: false, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler:  {[weak self]
            action in
            self?.sendDeleteRequest()
        }))
        return alert
    }
    
    func setRecipeParams(recipe: RecipeDetailsViewModel) {
        titleLabel.text = recipe.name
        ratingImageView.image = recipe.rating
        directionsLabel.text = recipe.ingredients
    }
    
    func setRecipeImage(image: UIImage) {
        imageView.image = image
    }
    
    func showConfirmationAlert() {
        present(createConfirmationAlert(), animated: true)
    }
    
    func showAlertForDeleteFailure() {
        present(createAlertForDeleteFailure(), animated: true)
    }
    
    func popBackToList() {
        if let navController = self.navigationController {
            navController.popToRootViewController(animated: false)
        }
    }
    
    func showLoadingIndicator() {
        present(createLoadingIndicator(), animated: true, completion: nil)
    }
    
    func hideLoadingIndicator() {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func deleteRecipe(_ sender: Any) {
        showConfirmationAlert()
    }
    
    private func sendDeleteRequest() {
        presenter?.deleteRecipe()
    }
    
    @IBAction func switchMode(_ sender: Any) {
        presenter?.switchSegmentControll(index: segmentedControl.selectedSegmentIndex)
    }
    
    func setSegmentControllerText(text: String) {
        directionsLabel.text = text
    }
}

extension RecipeDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEditViewSegue", let destination = segue.destination as? EditRecipeViewController {
            destination.recipe = self.presenter?.recipe
            destination.recipesManager = self.presenter?.recipesManager
        }
    }
}
