//
//  AddRecipeViewController.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 15.10.21.
//

import Foundation
import UIKit

class AddRecipeViewController: UIViewController {
    @IBOutlet weak var stepsTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var urlErrorLabel: UILabel!
    var recipesManager: RecipeManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextViewDelegates()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }


    private func setTextViewDelegates() {
        nameTextView.textStorage.delegate = self
        urlTextView.textStorage.delegate = self
        stepsTextView.textStorage.delegate = self
        ingredientsTextView.textStorage.delegate = self
    }
    
    @IBAction func showImagePreview(_ sender: Any) {
        self.urlErrorLabel.isHidden = true
        let urlString = urlTextView.text ?? ""
        guard let url = URL(string: urlString) else {
            return
        }
        ImageCache.publicCache.load(url: url as NSURL) { image in
            if let recipeImage = image {
                DispatchQueue.main.async {
                    self.imageView.isHidden.toggle()
                    self.imageView.image = recipeImage
                }
            }
            else {
                DispatchQueue.main.async {
                    self.urlErrorLabel.isHidden = false
                }
            }
        }
    }
    
    private func checkImage(params: RecipeParameters) {
        // suspicious syntax below
        let urlString = urlTextView.text ?? ""
        guard let url = URL(string: urlString) else {
            self.urlErrorLabel.isHidden = false
            self.setSaveButton()
            return
        }
        ImageCache.publicCache.load(url: url as NSURL) { image in
            if let _ = image {
                DispatchQueue.main.async {
                    self.sendAddRequest(params: params)
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
    
    @objc func saveRecipe(_ sender: Any) {
        setLoadingButton()
        if let params = getNewRecipeParams() {
            checkImage(params: params)
        }
    }
    
    private func sendAddRequest(params: RecipeParameters) {
        guard let recipeService = recipesManager else {
            return
        }
        recipeService.addRecipe(params: params, completion: { [weak self] result in
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
                        self?.showAlertForAddFailure(params: params)
                    }
                }
            }
        })
    }
    
    private func showAlertForAddFailure(params: RecipeParameters) {
        let alert = UIAlertController(title: "Something went wrong", message: "Could not add  recipe", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self]
            action in
            self?.setSaveButton()
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler:  { [weak self]
            action in
            self?.sendAddRequest(params: params)
        }))
        self.present(alert, animated: true)
    }
    
    private func getNewRecipeParams() -> RecipeParameters? {
        guard let newName = nameTextView.text, let newSteps = stepsTextView.text,
              let newIngredients = ingredientsTextView.text, let newURL = urlTextView.text else {
                  return nil
              }
        
        let recipeParams = RecipeParameters(name: newName, imageURL: newURL, ingredients: newIngredients, steps: newSteps)
        
        return recipeParams
    }
    
    private func setSaveButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveRecipe))
        //self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setLoadingButton() {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.color = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
    }
}

extension AddRecipeViewController: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        self.navigationItem.rightBarButtonItem?.isEnabled = !(nameTextView.text.isEmpty || urlTextView.text.isEmpty || stepsTextView.text.isEmpty || ingredientsTextView.text.isEmpty)
    }
}
