//
//  AppUser+CoreDataProperties.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 23.10.21.
//
//

import Foundation
import CoreData


extension AppUser {
    
    @NSManaged public var email: String
    @NSManaged public var recipes: Array<RecipeEntity>
    
    static func create(email: String, in context: NSManagedObjectContext) {
        let newUser = AppUser(context: context)
        newUser.email = email
        do {
            try context.save()
        } catch {
            NotificationCenter.default
                .post(name: NSNotification.Name("save.error"),
                      object: nil)
        }
    }
    
    static func fetchUserByEmail(email: String, context: NSManagedObjectContext) -> AppUser? {
        let request: NSFetchRequest<AppUser> = Self.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        do {
            let user = try context.fetch(request)
            return user.first
        } catch {
            return nil
        }
    }
    
    
}

// MARK: Generated accessors for recipes
extension AppUser {
    
    @objc(insertObject:inRecipesAtIndex:)
    @NSManaged public func insertIntoRecipes(_ value: RecipeEntity, at idx: Int)
    
    @objc(removeObjectFromRecipesAtIndex:)
    @NSManaged public func removeFromRecipes(at idx: Int)
    
    @objc(insertRecipes:atIndexes:)
    @NSManaged public func insertIntoRecipes(_ values: [RecipeEntity], at indexes: NSIndexSet)
    
    @objc(removeRecipesAtIndexes:)
    @NSManaged public func removeFromRecipes(at indexes: NSIndexSet)
    
    @objc(replaceObjectInRecipesAtIndex:withObject:)
    @NSManaged public func replaceRecipes(at idx: Int, with value: RecipeEntity)
    
    @objc(replaceRecipesAtIndexes:withRecipes:)
    @NSManaged public func replaceRecipes(at indexes: NSIndexSet, with values: [RecipeEntity])
    
    @objc(addRecipesObject:)
    @NSManaged public func addToRecipes(_ value: RecipeEntity)
    
    @objc(removeRecipesObject:)
    @NSManaged public func removeFromRecipes(_ value: RecipeEntity)
    
    @objc(addRecipes:)
    @NSManaged public func addToRecipes(_ values: NSOrderedSet)
    
    @objc(removeRecipes:)
    @NSManaged public func removeFromRecipes(_ values: NSOrderedSet)
    
}

extension AppUser : Identifiable {
    
}
