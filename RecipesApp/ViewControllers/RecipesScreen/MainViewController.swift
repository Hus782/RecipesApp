//
//  ViewController.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 6.10.21.
//

import UIKit

protocol MainViewControllerProtocol: AnyObject {
    func startRefreshing()
    func stopRefreshing()
    func switchToLogin()
    func showTryAgainViewController()
    func setDataError()
    func switchToListView()
    func switchToGridView()
    func reloadData()
    func applyPendingChanges(pendingChanges: [Change])
    func dismissLogin()
}

class MainViewController: UIViewController, MainViewControllerProtocol {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var switchLayoutButton: UIBarButtonItem!
    private var isListView = false {
        didSet {
            presenter?.layoutSwitched(isListView: isListView)
        }
    }
    private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    private var isGetDataError = false
    var presenter: RecipesPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default
            .addObserver(self,
                         selector:#selector(showSomethingWentWrongDialog),
                         name: NSNotification.Name ("save.error"),                                           object: nil)
        
        NotificationCenter.default
            .addObserver(self,
                         selector:#selector(sessionExpired),
                         name: NSNotification.Name ("session.expired"),                                           object: nil)
        
        setUpCollectionView()
        presenter?.viewIsReady()
    }
    
    @objc func sessionExpired(_ notification: Notification) {
        switchToLogin()
    }
    
    @objc func showSomethingWentWrongDialog(_ notification: Notification) {
        let alert = UIAlertController(title: "Something went wrong", message: "This is not your fault (probably). Try restarting the app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok :(", style: .default, handler: {[weak self] _ in
            if let navController = self?.navigationController {
                navController.popToRootViewController(animated: false)
            }
        }))
        present(alert, animated: true)
    }
    
    func startRefreshing() {
        collectionView.refreshControl?.beginRefreshing()
    }
    
    func stopRefreshing() {
        collectionView.refreshControl?.endRefreshing()
    }
    
    func setDataError() {
        isGetDataError = true
    }
    
    func getRecipesDataFromApi() {
        presenter?.getRecipesFromAPI()
    }
    
    func dismissLogin() {
        dismiss(animated: true, completion: nil)
    }
    
    func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "GridCell", bundle: .main), forCellWithReuseIdentifier: Constants.gridCellIndentifier)
        collectionView.register(UINib(nibName: "ListCell", bundle: .main), forCellWithReuseIdentifier: Constants.listCellIndentifier)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        collectionView.refreshControl = refreshControl
    }
    
    func applyPendingChanges(pendingChanges: [Change]) {
        collectionView.performBatchUpdates({
            for change in pendingChanges {
                switch change {
                case .insert(let indexPath):
                    collectionView.insertItems(at: [indexPath])
                case .update(let indexPath):
                    collectionView.reloadItems(at: [indexPath])
                case .delete(let indexPath):
                    collectionView.deleteItems(at: [indexPath])
                    
                case .move(let fromIndexPath, let toIndexPath):
                    collectionView.deleteItems(at: [fromIndexPath])
                    collectionView.insertItems(at: [toIndexPath])
//                    collectionView.moveItem(at: fromIndexPath, to: toIndexPath)

                }
            }
        }, completion: { [weak self] _ in
            self?.presenter?.clearPendingChanges()
        })
    }
    
    @objc private func refresh(refreshControl: UIRefreshControl) {
        getRecipesDataFromApi()
    }
    
    func showTryAgainViewController() {
        performSegue(withIdentifier: "ShowTryAgainSegue", sender: self)
    }
    
    func switchToLogin() {
        let loginController = LoginViewController()
        let loginInteractor = LoginPresenter()
        loginController.presenter = loginInteractor
        loginInteractor.view = loginController
        loginInteractor.delegate = presenter
        
        loginController.modalPresentationStyle = .fullScreen
        self.present(loginController, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        presenter?.logout()
    }
    
    func switchToListView() {
        switchLayoutButton.image = Constants.listModeImage
    }
    
    func switchToGridView() {
        switchLayoutButton.image = Constants.gridModeImage
    }
    
    @IBAction func switchLayout(_ sender: Any) {
        isListView.toggle()
    }

    func reloadData() {
        // update data with some animation
        collectionView.performBatchUpdates( {
            let indexSet = IndexSet(integersIn: 0...0)
            self.collectionView.reloadSections(indexSet)
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRecipeDetailsSegue", let destination = segue.destination as? RecipeDetailsViewController {
            if let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
                let fetched = presenter?.getRecipeByIndexPath(indexPath: indexPath)
                guard let fetched = fetched else {
                    return
                }
                let manager = presenter?.getRecipesManager() as! RecipeManager
                let presenter = DetailsPresenter(recipe: fetched, recipesManager: manager)
                presenter.view = destination
                destination.presenter = presenter
            }
        }
        else if segue.identifier == "AddRecipeSegue", let destination = segue.destination as? AddRecipeViewController {
            let manager = presenter?.getRecipesManager() as! RecipeManager
            destination.recipesManager = manager
        }
        else if segue.identifier == "ShowTryAgainSegue" {
            let destination = segue.destination as! TryAgainViewController
            destination.delegate = self
            if !isGetDataError {
                destination.message = "Authentication Error"
            }
            else {
                destination.message = "Could not load recipes"
            }
            
        }
    }
}

extension MainViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter?.getSectionsNum() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.performSegue(withIdentifier: "ShowRecipeDetailsSegue", sender: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.getNumberOfItemsInSection(section: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let width = collectionView.frame.width
        if isListView {
            return CGSize(width: width - 20, height: width/3)
        }
        else {
            return CGSize(width: (width - 30) / 3, height: (width + 150) / 3)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isListView {
            let cell = setUpListCell(indexPath: indexPath)
            return cell
        }
        else {
            let cell = setUpGridCell(indexPath: indexPath)
            return cell
        }
    }
    
    func setUpGridCell(indexPath: IndexPath) -> GridCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.gridCellIndentifier, for: indexPath) as? GridCell
        else {
            fatalError("Unable to dequeue cell!")
        }
        let recipeViewModel = presenter?.getRecipeViewModelByIndexPath(indexPath: indexPath)
        if let recipeViewModel = recipeViewModel {
            cell.nameLabel.text = recipeViewModel.name
            cell.ratingImage.image = recipeViewModel.rating
            loadImageInCell(recipeViewModel: recipeViewModel, completion: { image, oldURL in
                if recipeViewModel.imageURL == oldURL {
                    cell.imageView.image = image
                }
                else {
                    cell.imageView.image = Constants.placeHolderImage
                }
            })
        }
        return cell
    }
    
    func setUpListCell(indexPath: IndexPath) -> ListCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.listCellIndentifier, for: indexPath) as? ListCell
        else {
            fatalError("Unable to dequeue cell!")
        }
        let recipeViewModel = presenter?.getRecipeViewModelByIndexPath(indexPath: indexPath)
        if let recipeViewModel = recipeViewModel {
            cell.nameLabelList.text = recipeViewModel.name
            cell.ratingImageList.image = recipeViewModel.rating
            loadImageInCell(recipeViewModel: recipeViewModel, completion: { image, oldURL in
                if recipeViewModel.imageURL == oldURL {
                    cell.imageViewList.image = image
                }
                else {
                    cell.imageViewList.image = Constants.placeHolderImage
                }
            })
        }
        return cell
    }
    
    private func loadImageInCell(recipeViewModel: RecipeViewModel, completion: @escaping (UIImage, String?) -> Void) {
        if let url = URL(string: recipeViewModel.imageURL) {
            ImageCache.publicCache.load(url: url as NSURL) { image in
                if let recipeImage = image {
                    DispatchQueue.main.async {
                        completion(recipeImage, recipeViewModel.imageURL)
                    }
                }
            }
        } else {
            completion(Constants.placeHolderImage, recipeViewModel.imageURL)
        }
    }
    
}

// The delegate from TryAgainViewController to start
extension MainViewController: TryAgainDelegate{
    func tryAgain(){
        getRecipesDataFromApi()
    }
}

