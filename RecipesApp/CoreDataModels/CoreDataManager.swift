//
//  CoreDataManager.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 23.10.21.
//

import UIKit
import CoreData

protocol CoreDataManagerProtocol {
    func loadRecipesFromDB()-> [Recipe]
    func saveAllRecipesInDB(recipes: [Recipe])
    func updateRecipe(modifiedRecipe: Recipe)
    func deleteRecipe(id: String)
    func addNewRecipe(newRecipe: Recipe)
    func getCoreDataStore() -> CoreDataStoreProtocol
}

class CoreDataManager: CoreDataManagerProtocol {
    private var user: AppUser?
    private let userDefaults: UserDefaults
    let coreDataStore: CoreDataStoreProtocol

    init(coreDataStore: CoreDataStoreProtocol = CoreDataStore(), userDefaults: UserDefaults = UserDefaults.standard) {
        self.coreDataStore = coreDataStore
        self.userDefaults = userDefaults
    }
    
    private func addNewUser() {
        guard let email = userDefaults.string(forKey: Constants.userEmail) else { return }
        AppUser.create(email: email, in: coreDataStore.persistentContainer.viewContext)
    }
    
    private func fetchUser()-> AppUser? {
        guard let email = userDefaults.string(forKey: Constants.userEmail) else { return nil}
        return AppUser.fetchUserByEmail(email: email, context: coreDataStore.persistentContainer.viewContext)
    }
    
    func getCoreDataStore() -> CoreDataStoreProtocol {
        return coreDataStore
    }
    
    func setCurrentUser() {
        if let user = fetchUser() {
            self.user = user
        }
        else {
            addNewUser()
            self.user = fetchUser()
        }
    }
    func loadRecipesFromDB()-> [Recipe] {
        setCurrentUser()
        guard let user = self.user else { return [] }
        return user.recipes.map{ Recipe(entity: $0) }
    }
    
    func saveAllRecipesInDB(recipes: [Recipe]) {
        let backgroundContext = coreDataStore.newDerivedContext()
        setCurrentUser()
        guard let user = user else { return }
        
        guard let appUser = AppUser.fetchUserByEmail(email: user.email, context: backgroundContext) else {
            return
        }
        let recipesInData = user.recipes.map{ $0.id }

        backgroundContext.perform {
            for recipe in recipes {
         

                let _ = RecipeEntity.create(id: recipe.id,
                                            name: recipe.name,
                                            imageURL: recipe.imageURL,
                                            steps: recipe.steps,
                                            ingredients: recipe.ingredients,
                                            owner: appUser,
                                            in: backgroundContext)
               
            }
            for id in recipesInData {
                if recipes.first(where: { $0.id == id}) == nil  {
                    RecipeEntity.deleteByID(id: id, context: backgroundContext)
                }
            }

            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                } catch {
                    DispatchQueue.main.async {
                        NotificationCenter.default
                            .post(name: NSNotification.Name("save.error"),
                                  object: nil)
                    }
                }
                backgroundContext.reset()
            }
        }
    }
    
    // method used when adding a new recipe through add button
    func addNewRecipe(newRecipe: Recipe) {
        guard let user = user else { return }
        
        let _ = RecipeEntity.create(id: newRecipe.id,
                                    name: newRecipe.name,
                                    imageURL: newRecipe.imageURL,
                                    steps: newRecipe.steps,
                                    ingredients: newRecipe.ingredients,
                                    owner: user,
                                    in: coreDataStore.persistentContainer.viewContext)
        do {
            try coreDataStore.persistentContainer.viewContext.save()
        } catch {
            NotificationCenter.default
                .post(name: NSNotification.Name("save.error"),
                      object: nil)
        }
    }
    
    func updateRecipe(modifiedRecipe: Recipe) {
        if let recipeEntity = RecipeEntity.fetchByID(id: modifiedRecipe.id, context: coreDataStore.persistentContainer.viewContext) {
            recipeEntity.updateRecipe(newRecipe: modifiedRecipe, context: coreDataStore.persistentContainer.viewContext)
        }
    }
    
    func deleteRecipe(id: String) {
        
        RecipeEntity.deleteByID(id: id, context: coreDataStore.persistentContainer.viewContext)
        do {
            try coreDataStore.persistentContainer.viewContext.save()
        } catch {
            NotificationCenter.default
                .post(name: NSNotification.Name("save.error"),
                      object: nil)
        }
        
    }}
