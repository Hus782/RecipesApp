//
//  RecipesPresenter.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 28.10.21.
//

import Foundation
import CoreData

protocol RecipesPresenterProtocol: AnyObject {
    func viewIsReady()
    func getRecipesManager() -> RecipesManagerProtocol
    func logout()
    func layoutSwitched(isListView: Bool)
    func clearPendingChanges()
    func getRecipeByIndexPath(indexPath: IndexPath) -> Recipe
    func getRecipeViewModelByIndexPath(indexPath: IndexPath) -> RecipeViewModel
    func getSectionsNum() -> Int
    func getNumberOfItemsInSection(section: Int) -> Int
}

class RecipesPresenter: NSObject, RecipesPresenterProtocol {
    var recipesManager: RecipesManagerProtocol
    weak var view: MainViewControllerProtocol?
    
    lazy var fetchedResultsController: NSFetchedResultsController<RecipeEntity> = createResultsController()
    
    private var pendingChanges: [Change]?
    
    init(recipesManager: RecipesManagerProtocol) {
        self.recipesManager = recipesManager
    }
    
    func getRecipeByIndexPath(indexPath: IndexPath) -> Recipe {
        let recipe = Recipe(entity: fetchedResultsController.object(at: indexPath))
        return recipe
    }
    
    func getRecipeViewModelByIndexPath(indexPath: IndexPath) -> RecipeViewModel {
        let entity = fetchedResultsController.object(at: indexPath)
        let recipe = RecipeViewModel(name: entity.name, rating: Constants.noRatingImage, imageURL: entity.imageURL ?? "")
        return recipe
    }
    
    func clearPendingChanges() {
        pendingChanges = nil
    }
    
    func getSectionsNum() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func getNumberOfItemsInSection(section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    private func createResultsController() -> NSFetchedResultsController<RecipeEntity> {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.sortDescriptors = [.init(key: "name", ascending: true)]
        let email = UserDefaults.standard.string(forKey: Constants.userEmail) ?? ""
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(RecipeEntity.user.email), email)
        let context = recipesManager.getCoreDataStore().persistentContainer.viewContext
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }
    
    func layoutSwitched(isListView: Bool) {
        if isListView {
            view?.switchToListView()
        }
        else {
            view?.switchToGridView()
        }
        view?.reloadData()
    }
    
    func logout() {
        UserDefaults.standard.set(nil, forKey: Constants.authToken)
        UserDefaults.standard.set(nil, forKey: Constants.userEmail)
        view?.switchToLogin()
    }
    
    func getRecipesManager() -> RecipesManagerProtocol {
        return recipesManager
    }
    
    func viewIsReady() {
        //recipesManager.loadRecipesFromDB()
        getRecipesFromAPI()
    }

    func getRecipesFromAPI() {
        view?.startRefreshing()
        recipesManager.loadRecipes(completion: { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.recipesManager.saveRecipesInDB()
                    self?.view?.stopRefreshing()
                }
            case .failure(let error):
                if error == .authenticationError {
                    DispatchQueue.main.async {
                        self?.view?.stopRefreshing()
                        self?.view?.switchToLogin()
                    }
                }
                // get here if authentication is ok but response is still not fine
                else {
                    DispatchQueue.main.async {
                        self?.view?.stopRefreshing()
                        self?.view?.setDataError()
                        self?.view?.showTryAgainViewController()
                    }
                }
            }
        })
        
    }
}

extension RecipesPresenter: RecipeManagerDelegate {
    func updatedRecipes(index: Int) {
        //
    }
    
    func addedRecipe() {
        //
    }
}

extension RecipesPresenter: LoginDelegate {
    func logginSuccess() {
        view?.dismissLogin()
        // recreate fetch request since user has changed and we need new predicate
        fetchedResultsController = createResultsController()
        view?.reloadData()

        getRecipesFromAPI()
    }
}

enum Change {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
    case move(IndexPath, IndexPath)
}

extension RecipesPresenter: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pendingChanges = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let pendingChanges = pendingChanges, !pendingChanges.isEmpty else {
            return
        }
        view?.applyPendingChanges(pendingChanges: pendingChanges)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            pendingChanges?.append(Change.insert(newIndexPath))
        case .update:
            guard let indexPath = indexPath else { return }
            pendingChanges?.append(Change.update(indexPath))
        case .delete:
            guard let indexPath = indexPath else { return }
            pendingChanges?.append(Change.delete(indexPath))
        case .move:
            guard let newIndexPath = newIndexPath,
                  let indexPath = indexPath else {
                      return
                  }
                pendingChanges?.append(Change.move(indexPath, newIndexPath))
            
        @unknown default:
            assert(false, "Unknown change type \(type)")
        }
    }
}



