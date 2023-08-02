//
//  TryAgainViewController.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 14.10.21.
//

import Foundation
import UIKit

class TryAgainViewController: UIViewController {
    weak var delegate: TryAgainDelegate?
    @IBOutlet weak var messageLabel: UILabel!
    
    var message = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        messageLabel.text = message
    }
    
    @IBAction func tryAgain(_ sender: Any) {
        delegate?.tryAgain()
        _ = navigationController?.popViewController(animated: false)
    }
}

protocol TryAgainDelegate: AnyObject {
    func tryAgain()
}

