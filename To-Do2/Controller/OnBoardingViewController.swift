//
//  OnBoardingViewController.swift
//  To-Do2
//
//  Created by User on 2024/05/12.
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    private enum LocalConstants {
        static let cornerRadius: CGFloat = 10
    }
        
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func alreadyShown() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.Key.onboarding)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        markAsSeen()
        dismiss(animated: true)
    }
    
    private func markAsSeen() {
        UserDefaults.standard.set(true, forKey: Constants.Key.onboarding)
    }

    fileprivate func setupViews() {
        nextButton.layer.cornerRadius = LocalConstants.cornerRadius
        nextButton.clipsToBounds = true
    }
}
