//
//  ProductListViewController.swift
//  JLDishwashers
//
//  Created by Dario Banno on 14/02/2017.
//  Copyright © 2017 AppTown. All rights reserved.
//

import UIKit

class ProductListViewController: UICollectionViewController {

    var productCategory = "dishwasher"
    var productPageSize = 20

    let dataSource = ProductListCollectionViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Dishwashers"
        
        let collectionViewFlowLayout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 300)

        collectionView!.dataSource = dataSource
        collectionView!.registerNib(forClass: ProductListCollectionViewCell.self)
        
        loadProductList()
    }

    func loadProductList() {
        NetworkManager.shared.productListService.search(query: productCategory, pageSize: productPageSize) { [weak self] (products, error) in
            guard let products = products, error == nil else {
                return
            }
            self?.dataSource.products = products
            self?.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productPageViewController = ProductPageViewController()
        productPageViewController.product = dataSource.products[indexPath.row]
        show(productPageViewController, sender: self)
    }
}
