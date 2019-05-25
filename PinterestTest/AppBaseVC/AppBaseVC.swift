//
//  AppBaseVC.swift
//  PinterestTest
//
//  Created by Digital Dividend on 19/05/2019.
//  Copyright © 2019 Saad. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class AppBaseVC: UIViewController , NVActivityIndicatorViewable{

    //NVActivityIndicator
    var actInd : NVActivityIndicatorView!
    public let presentingIndicatorTypes = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "Opps", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    public func hideLoader() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.stopAnimating(nil)
        }
    }
    
    public func showLoader(message: String? = "Loading...") {
        
        let size = CGSize(width: 40, height: 40)
        let indicatorType = presentingIndicatorTypes[24]
        
        startAnimating(size, message: "", type: indicatorType, fadeInAnimation: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            NVActivityIndicatorPresenter.sharedInstance.setMessage("")
        }
        
    }

}
