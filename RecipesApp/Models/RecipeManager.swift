//
//  RecipesManager.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 7.10.21.
//

import CoreData

protocol RecipesManagerProtocol {
    func loadRecipesFromDB()
    func saveRecipesInDB()
    func loadRecipes(completion: @escaping ((Result<[Recipe], NetworkError>) -> Void ))
    func editRecipe(params: RecipeParameters, id: String, completion: @escaping ((Result<Any?, NetworkError>) -> Void ))
    func addRecipe(params: RecipeParameters, completion: @escaping ((Result<Any?, NetworkError>) -> Void ))
    func deleteRecipe(id: String, completion: @escaping ((Result<Any?, NetworkError>) -> Void ))
    func getCoreDataStore() -> CoreDataStoreProtocol
}

class RecipeManager: RecipesManagerProtocol {
    private (set) var recipes: [Recipe]
    private let client: HTTPClientProtocol
    private let coreDataManager: CoreDataManagerProtocol
    weak var delegate: RecipeManagerDelegate?

    init (client: HTTPClientProtocol = HTTPClient(), preloadedRecipes: [Recipe] = [], coreDataManager: CoreDataManagerProtocol = CoreDataManager()) {
        self.client = client
        self.recipes = preloadedRecipes
        self.coreDataManager = coreDataManager
    }
    
    func getCoreDataStore() -> CoreDataStoreProtocol {
        return coreDataManager.getCoreDataStore()
    }
    
    func loadRecipesFromDB() {
        recipes = coreDataManager.loadRecipesFromDB()
    }
    
    func saveRecipesInDB() {
        coreDataManager.saveAllRecipesInDB(recipes: recipes)
    }
    
    func loadRecipes(completion: @escaping ((Result<[Recipe], NetworkError>) -> Void )) {
        client.getAllRecipes(completion: { result in
            switch result {
            case .success (let newRecipes):
                DispatchQueue.main.async {
                    self.recipes = newRecipes
                    completion(.success(newRecipes))
                }
            case .failure (let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        })
    }
    
    func editRecipe(params: RecipeParameters, id: String, completion: @escaping ((Result<Any?, NetworkError>) -> Void )) {
        client.editRecipe(parameters: params, recipeID: id, completion: { result in
            switch result {
            case .success (let id):
                DispatchQueue.main.async {
                    let modifiedRecipe = Recipe(params: params, id: id)
                    self.updateRecipe(modifiedRecipe: modifiedRecipe)
                    completion(.success(nil))
                }
            case .failure (let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        })
    }
    
    func addRecipe(params: RecipeParameters, completion: @escaping ((Result<Any?, NetworkError>) -> Void )) {
        client.addRecipe(parameters: params, completion: { result in
            switch result {
            case .success (let id):
                DispatchQueue.main.async {
                    self.addNewRecipe(id: id, params: params)
                    completion(.success(nil))
                }
            case .failure (let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        })
    }
    
    func deleteRecipe(id: String, completion: @escaping ((Result<Any?, NetworkError>) -> Void )) {
        client.deleteRecipe(recipeID: id, completion: { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.removeRecipe(id: id)
                    completion(.success(nil))
                }
            case .failure (let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        })
    }
    
    private func addNewRecipe(id: String, params: RecipeParameters) {
        let newRecipe = Recipe(params: params, id: id)
        recipes.append(newRecipe)
        coreDataManager.addNewRecipe(newRecipe: newRecipe)
        delegate?.addedRecipe()
    }
    
    private func updateRecipe(modifiedRecipe: Recipe) {
        if let row = recipes.firstIndex(where: {$0.id == modifiedRecipe.id}) {
            recipes[row] = modifiedRecipe
            coreDataManager.updateRecipe(modifiedRecipe: modifiedRecipe)
            delegate?.updatedRecipes(index: row)
        }
    }
    
    private func removeRecipe(id: String) {
        if let row = recipes.firstIndex(where: {$0.id == id}) {
            recipes.remove(at: row)
            coreDataManager.deleteRecipe(id: id)
            delegate?.updatedRecipes(index: row)
        }
    }
}

protocol RecipeManagerDelegate : AnyObject{
    func updatedRecipes(index: Int)
    func addedRecipe()
}
