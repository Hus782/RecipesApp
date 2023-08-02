//
//  CoreDataManagerTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 25.10.21.
//

import XCTest
@testable import RecipesApp

class CoreDataManagerTests: XCTestCase {
    var userDefaults: UserDefaults!
    
    var coreDataStore: CoreDataStore!
    var coreDataManager: CoreDataManager!
    let testEmail = "test@gmail.com"
    let testRecipe = Recipe(id: "1234", name: "TestRecipe", imageURL: "None", steps: "Boil the eggs", ingredients: "Boil the egg")
    let testRecipe2 = Recipe(id: "12345", name: "TestRecipe", imageURL: "None", steps: "Boil the eggs", ingredients: "Boil the egg")
    let editedRecipe = Recipe(id: "1234", name: "TestRecipeEdited", imageURL: "NoneEdited", steps: "Boil the eggs", ingredients: "Boil the egg")
    
    override func setUp() {
        coreDataStore = CoreDataStore(.inMemory)
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults.set("token", forKey: Constants.authToken)
        userDefaults.set(testEmail, forKey: Constants.userEmail)
        AppUser.create(email: testEmail, in: coreDataStore.persistentContainer.viewContext)
    }

    override func tearDownWithError() throws {
        coreDataStore = nil
        coreDataManager = nil
    }

    func testSetUser() {
        coreDataManager = CoreDataManager(coreDataStore: coreDataStore, userDefaults: userDefaults)
        coreDataManager.setCurrentUser()
        let user = AppUser.fetchUserByEmail(email: testEmail, context: coreDataStore.persistentContainer.viewContext)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.email, testEmail)
    }

    func testSaveRecipes() {
        coreDataManager = CoreDataManager(coreDataStore: coreDataStore, userDefaults: userDefaults)
        coreDataManager.setCurrentUser()
        
        coreDataManager.saveAllRecipesInDB(recipes: [testRecipe])
        
        // probably bad practice
        sleep(5)
        let recipe = RecipeEntity.fetchByID(id: "1234", context: coreDataStore.persistentContainer.viewContext)
        XCTAssertNotNil(recipe)
        XCTAssertEqual(recipe?.name, testRecipe.name)
        XCTAssertEqual(recipe?.imageURL, testRecipe.imageURL)

    }

    func testLoadRecipes() {
        let user = AppUser.fetchUserByEmail(email: testEmail, context: coreDataStore.persistentContainer.viewContext)
        // add recipe to test coreDataStore
        let _ = RecipeEntity.create(id: testRecipe.id,
                                    name: testRecipe.name,
                                    imageURL: testRecipe.imageURL,
                                    steps: testRecipe.steps,
                                    ingredients: testRecipe.ingredients,
                                    owner: user!,
                                    in: coreDataStore.persistentContainer.viewContext)
        do {
            try coreDataStore.persistentContainer.viewContext.save()
        } catch {
          
        }
        
        coreDataManager = CoreDataManager(coreDataStore: coreDataStore, userDefaults: userDefaults)
    
        let recipes = coreDataManager.loadRecipesFromDB()
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes[0].name, testRecipe.name)
        XCTAssertEqual(recipes[0].id, testRecipe.id)
        XCTAssertEqual(recipes[0].steps, testRecipe.steps)
        XCTAssertEqual(recipes[0].ingredients, testRecipe.ingredients)
    }
    
    func testUpdateRecipe() {
        let user = AppUser.fetchUserByEmail(email: testEmail, context: coreDataStore.persistentContainer.viewContext)
        // add recipe to test coreDataStore
        let _ = RecipeEntity.create(id: testRecipe.id,
                                    name: testRecipe.name,
                                    imageURL: testRecipe.imageURL,
                                    steps: testRecipe.steps,
                                    ingredients: testRecipe.ingredients,
                                    owner: user!,
                                    in: coreDataStore.persistentContainer.viewContext)
        do {
            try coreDataStore.persistentContainer.viewContext.save()
        } catch {
          
        }
        
        coreDataManager = CoreDataManager(coreDataStore: coreDataStore, userDefaults: userDefaults)

        coreDataManager.updateRecipe(modifiedRecipe: editedRecipe)
        
        let recipe =  RecipeEntity.fetchByID(id: testRecipe.id, context: coreDataStore.persistentContainer.viewContext)
        XCTAssertNotNil(recipe)
        XCTAssertEqual(recipe?.name, editedRecipe.name)
        XCTAssertEqual(recipe?.imageURL, editedRecipe.imageURL)
    }
//    
    func testDeleteRecipe() {
        let user = AppUser.fetchUserByEmail(email: testEmail, context: coreDataStore.persistentContainer.viewContext)
        // add recipe to test coreDataStore
        let _ = RecipeEntity.create(id: testRecipe.id,
                                    name: testRecipe.name,
                                    imageURL: testRecipe.imageURL,
                                    steps: testRecipe.steps,
                                    ingredients: testRecipe.ingredients,
                                    owner: user!,
                                    in: coreDataStore.persistentContainer.viewContext)
        do {
            try coreDataStore.persistentContainer.viewContext.save()
        } catch {
          
        }
        
        coreDataManager = CoreDataManager(coreDataStore: coreDataStore, userDefaults: userDefaults)
        coreDataManager.deleteRecipe(id: testRecipe.id)
        
        let recipe =  RecipeEntity.fetchByID(id: testRecipe.id, context: coreDataStore.persistentContainer.viewContext)
        XCTAssertNil(recipe)
    }
}
