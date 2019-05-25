//
//  ViewController.swift
//  PinterestTest
//
//  Created by Digital Dividend on 19/05/2019.
//  Copyright © 2019 Saad. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: AppBaseVC {
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    var homeModel = [BaseClass]()
    var pinterestModel = [BaseClass]()
    
    var refreshControl : UIRefreshControl!
    var previousPage = 0
    var nextPage = 1
    
    var listCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        
        //Calling API
        homeAPICall()
        
    }
    
    func configureCollectionView(){
        if let layout = homeCollectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
            homeCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            
            homeCollectionView.delegate = self
            homeCollectionView.dataSource = self
            
            // Add Refresh Control
            homeCollectionView.alwaysBounceVertical = true
            homeCollectionView.bounces  = true
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
            homeCollectionView.addSubview(refreshControl)
        }
    }
    
    // Pull To Refresh
    @objc func didPullToRefresh() {
        print("Refersh")
        self.previousPage = 0
        self.nextPage = 1
        self.homeModel = []
        self.pinterestModel = []
        self.listCount = 0
        refreshControl?.endRefreshing()
        
        // Refresh The Home Api Call
        homeAPICall()
    }
    
    func homeAPICall(){
        
        DispatchQueue.main.async {
            self.showLoader()
        }
        
        PinterestModel.getPinterestList { [weak self](status, model, message) in
            if status{
                DispatchQueue.main.async {
                    self!.hideLoader()
                }
                
                // Setting Data to Local Variable
                if let pinModel = model{
                    self?.homeModel = pinModel
                    self?.pinterestModel = pinModel
                    if pinModel.count >= 10{
                        self?.listCount = 10
                    }
                    DispatchQueue.main.async {
                        self!.homeCollectionView.reloadData()
                    }
                }
            }else{
                self?.showAlert(message: message)
            }
        }
    }
    
    
}


extension ViewController: UICollectionViewDelegate , UICollectionViewDataSource, PinterestLayoutDelegate{
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let height = CGFloat(homeModel[indexPath.item].height!) * CGFloat(0.2)
        
        if pinterestModel[indexPath.item].height! > 3000{
            return CGFloat(pinterestModel[indexPath.item].height!) * CGFloat(0.1)
        }
        return CGFloat(height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionCell
        
        if pinterestModel.count > 0{
            
            cell.homeImage.image = UIImage(named: "no-image") // Default Image
            if let url = pinterestModel[indexPath.item].urls?.regular{
                let encodedUrl = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
                ImageHelper.getCacheImage(url: encodedUrl!) { (postImage) in
                    if postImage != nil{
                        cell.homeImage.image = postImage!
                    }
                }
                // Previously I was using this Library
                //cell.homeImage.sd_setImage(with: encodedUrl, placeholderImage: UIImage(named: "no-image"), options: .highPriority, completed: nil)
                
            }else{
                cell.homeImage.image = UIImage(named: "no-image")
            }
        }
        
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if homeCollectionView.contentOffset.y >= (homeCollectionView.contentSize.height - homeCollectionView.frame.size.height) {
            // print("you reached end of the table")
            if Constants.isLoadMore{
                Constants.isLoadMore = false
                
                previousPage = nextPage
                nextPage += 1
                
                if listCount > homeModel.count{
                    listCount = homeModel.count
                }else{
                    
                    pinterestModel = []
                    listCount += 10
                    if homeModel.count > 0{
                        for i in 0...self.homeModel.count-1{
                            if i < listCount{
                                let item = homeModel[i]
                                pinterestModel.append(item)
                            }
                        }
                    }
                    
                }
                self.homeCollectionView.reloadData()
                Constants.isLoadMore = true
                
            }
        }
    }
    
}
