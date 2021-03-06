//
//  ProductListCollectionViewCell.swift
//  JLDishwashers
//
//  Created by Dario Banno on 14/02/2017.
//  Copyright © 2017 AppTown. All rights reserved.
//

import UIKit

class ProductListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: URLImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.contentMode = .scaleAspectFit
        imageView.errorPlaceholder = #imageLiteral(resourceName: "jlewis-placeholder")

        priceLabel.font = Resource.Font.contentTextBold
        priceLabel.textColor = Resource.Color.darkText

        titleLabel.font = Resource.Font.contentText
        titleLabel.textColor = Resource.Color.darkText
    }
    
    func configure(from product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "£" + (product.price?.now ?? "")
        if let productImage = product.image, let url = URL(httpsString: productImage) {
            imageView.load(from: url)
        }
    }
    
}
