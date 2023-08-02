import Foundation
import UIKit

struct Recipe: Identifiable, Decodable, Encodable{
    let id: String
    var name: String
    let imageURL: String
    var ingredients: String
    var steps: String
    

    mutating func updateRecipe(modifiedRecipe: Recipe) {
        ingredients = modifiedRecipe.ingredients
        name = modifiedRecipe.name
        steps = modifiedRecipe.steps
    }
    
    // constructor to create recipe from params and id, used for updating UI after edit/add requests
    init(params: RecipeParameters, id: String) {
        self.name = params.name
        self.imageURL = params.imageURL
        self.steps = params.steps
        self.ingredients = params.ingredients
        self.id = id
    }
    
    init(id: String, name: String, imageURL: String, steps: String, ingredients: String) {
        self.name = name
        self.imageURL = imageURL
        self.steps = steps
        self.ingredients = ingredients
        self.id = id
    }
    
    init(entity: RecipeEntity) {
        self.name = entity.name
        self.id = entity.id 
        self.imageURL = entity.imageURL ?? ""
        self.steps = entity.steps ?? ""
        self.ingredients = entity.ingredients ?? ""
    }
}
