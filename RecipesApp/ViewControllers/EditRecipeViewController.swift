//
//  EditRecipeViewController.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 11.10.21.
//

import UIKit
class EditRecipeViewController: UIViewController {
    var recipe: Recipe?
    var recipesManager: RecipesManagerProtocol?
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var nameLabelEdit: UITextView!
    @IBOutlet weak var ingredientsLabelEdit: UITextView!
    @IBOutlet weak var stepsLabelEdit: UITextView!
    @IBOutlet weak var urlImageView: UIImageView!
    
    @IBOutlet weak var urlErrorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabelEdit.textStorage.delegate = self
        urlTextView.textStorage.delegate = self
        stepsLabelEdit.textStorage.delegate = self
        ingredientsLabelEdit.textStorage.delegate = self
        setSaveButton()
        if let recipe = recipe {
            nameLabelEdit.text = recipe.name
            ingredientsLabelEdit.text = recipe.ingredients
            stepsLabelEdit.text = recipe.steps
            urlTextView.text = recipe.imageURL
        }
    }
    
    @IBAction func previewImage(_ sender: Any) {
        self.urlErrorLabel.isHidden = true
        let urlString = urlTextView.text ?? ""
        let url = URL(string: urlString)!
        ImageCache.publicCache.load(url: url as NSURL) { image in
            if let recipeImage = image {
                DispatchQueue.main.async {
                    self.urlImageView.isHidden.toggle()
                    self.urlImageView.image = recipeImage
                }
            }
            else {
                DispatchQueue.main.async {
                    self.urlErrorLabel.isHidden = false
                }
            }
        }
    }
    
    func checkImage(params: RecipeParameters, id: String) {
        let urlString = urlTextView.text ?? ""
        guard let url = URL(string: urlString) else {
            self.urlErrorLabel.isHidden = false
            self.setSaveButton()
            return
        }
        ImageCache.publicCache.load(url: url as NSURL) { image in
            if let _ = image {
                DispatchQueue.main.async {
                    self.sendEditRequest(params: params, id: id)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.urlErrorLabel.isHidden = false
                    self.setSaveButton()
                }
            }
        }
    }
    
    func setSaveButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveRecipe))
    }
    
    func setLoadingButton() {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.color = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
    }
    
    @objc func saveRecipe(_ sender: Any) {
        if let recipe = recipe {
            let params = getEditedRecipeParams()
            let id = recipe.id
            setLoadingButton()
            checkImage(params: params, id: id)
        }
    }
    
    private func getEditedRecipeParams() -> RecipeParameters{
        let newName = nameLabelEdit.text ?? ""
        let newSteps = stepsLabelEdit.text ?? ""
        let newIngredients = ingredientsLabelEdit.text ?? ""
        let imageURL = urlTextView.text ?? ""
        let recipeParams = RecipeParameters(name: newName, imageURL: imageURL, ingredients: newIngredients, steps: newSteps)
    
        return recipeParams
    }
    
    private func sendEditRequest(params: RecipeParameters, id: String) {
        guard let recipesManager = recipesManager else {
            return
        }
        recipesManager.editRecipe(params: params, id: id, completion: { [weak self]
            result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let navController = self?.navigationController {
                        navController.popToRootViewController(animated: true)
                    }
                }
            case .failure(let error):
                if error == .authenticationError {
                    DispatchQueue.main.async {
                        NotificationCenter.default
                            .post(name: NSNotification.Name("session.expired"),
                                  object: nil)
                        if let navController = self?.navigationController {
                            navController.popToRootViewController(animated: false)
                        }
                    }
                }
                // get here if authentication is ok but response is still not fine
                else {
                    DispatchQueue.main.async {
                        self?.showAlertForEditFailure(params: params, id: id)
                    }
                }
            }
        })
    }
    
    private func showAlertForEditFailure(params: RecipeParameters, id: String) {
        let alert = UIAlertController(title: "Something went wrong", message: "Could not update the recipe", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self]
            action in
            self?.setSaveButton()
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler:  { [weak self]
            action in
            self?.sendEditRequest(params: params, id: id)
        }))
        self.present(alert, animated: true)
    }
}

extension EditRecipeViewController: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        self.navigationItem.rightBarButtonItem?.isEnabled = !(nameLabelEdit.text.isEmpty || urlTextView.text.isEmpty || stepsLabelEdit.text.isEmpty || ingredientsLabelEdit.text.isEmpty)
    }
}

extension EditRecipeViewController: LoginDelegate {
    func logginSuccess() {
        if let navController = self.navigationController {
            navController.popToRootViewController(animated: true)
        }
    }
}
