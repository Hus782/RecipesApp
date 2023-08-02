//
//  RecipeTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 14.10.21.
//

import XCTest
@testable import RecipesApp
class RecipeTests: XCTestCase {
    var recipe: Recipe!
    override func setUpWithError() throws {
        recipe = Recipe(id: "1234", name: "Boiled Eggs", imageURL: "None", steps: "Boil the eggs", ingredients: "Boil the egg")
    }

    override func tearDownWithError() throws {
        recipe = nil
    }

    func updateRecipeTest() {
        let updatedRecipe = Recipe(id: "1234", name: "Boiled Eggs", imageURL: "None", steps: "Boil the eggs", ingredients: "Boil the egg")
        recipe.updateRecipe(modifiedRecipe: updatedRecipe)
        XCTAssertEqual(recipe.name, updatedRecipe.name)
        XCTAssertEqual(recipe.steps, updatedRecipe.steps)
    }
}
