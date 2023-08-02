//
//  RecipeEntity+CoreDataProperties.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 23.10.21.
//
//

import Foundation
import CoreData


extension RecipeEntity {
    
    static func fetchByID(id: String, context: NSManagedObjectContext) -> RecipeEntity? {
        let request: NSFetchRequest<RecipeEntity> = Self.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let recipe = try context.fetch(request)
            return recipe.first
        } catch {
            return nil
        }
    }
    
    func updateRecipe(newRecipe: Recipe, context: NSManagedObjectContext) {
        self.name = newRecipe.name
        self.imageURL = newRecipe.imageURL
        self.steps = newRecipe.steps
        self.ingredients = newRecipe.ingredients
        
        do {
            try context.save()
        } catch {
            NotificationCenter.default
                .post(name: NSNotification.Name("save.error"),
                      object: nil)
        }
    }
    
    static func deleteByID(id: String, context: NSManagedObjectContext) {
        if let entity = self.fetchByID(id: id, context: context) {
            context.delete(entity)
        }
    }
    
    
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String
    @NSManaged public var id: String
    @NSManaged public var ingredients: String?
    @NSManaged public var steps: String?
    @NSManaged public var user: AppUser?
    
    static func create(id: String, name: String, imageURL: String, steps: String, ingredients: String, owner: AppUser, in context: NSManagedObjectContext) -> RecipeEntity {
        let recipe = RecipeEntity(context: context)
        recipe.id = id
        recipe.name = name
        recipe.imageURL = imageURL
        recipe.steps = steps
        recipe.ingredients = ingredients
        recipe.user = owner
        return recipe
    }
}

extension RecipeEntity : Identifiable {
    
}
