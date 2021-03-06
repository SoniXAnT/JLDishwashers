//
//  ProductPageViewController.swift
//  JLDishwashers
//
//  Created by Dario Banno on 15/02/2017.
//  Copyright © 2017 AppTown. All rights reserved.
//

import UIKit

class ProductPageViewController: UIViewController {
    
    // Left column
    @IBOutlet weak var imageSliderContainer: UIView!
    var imageSliderViewController: ImageSliderViewController!

    @IBOutlet weak var leftPriceDetailsContainer: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var specialOfferLabel: UILabel!
    @IBOutlet weak var additionalServicesLabel: UILabel!
    
    @IBOutlet weak var productInformationTitleLabel: UILabel!
    @IBOutlet weak var productInformationLabel: UILabel!
    
    @IBOutlet weak var productCodeLabel: UILabel!
    
    @IBOutlet weak var productSpecificationTitleLabel: UILabel!
    @IBOutlet weak var productSpecificationStackView: UIStackView!

    // Right column
    @IBOutlet weak var rightScrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightPriceDetailsContainer: UIView!
    weak var rightPriceDetailsView: PriceDetailsView!
    let defaultRightScrollViewWidth: CGFloat = 200
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layout
        edgesForExtendedLayout = []
        
        // Layout left column
        imageSliderViewController = ImageSliderViewController()
        imageSliderViewController.view.embed(in: imageSliderContainer)
        addChildViewController(imageSliderViewController)
        
        priceLabel.text = ""
        priceLabel.font = Resource.Font.heading1
        priceLabel.textColor = Resource.Color.darkText

        specialOfferLabel.text = ""
        specialOfferLabel.font = Resource.Font.contentText
        specialOfferLabel.textColor = Resource.Color.specialOffer

        additionalServicesLabel.text = ""
        additionalServicesLabel.font = Resource.Font.contentText
        additionalServicesLabel.textColor = Resource.Color.warrantyInfo

        productInformationTitleLabel.text = "Product information"
        productInformationTitleLabel.font = Resource.Font.heading2
        productInformationTitleLabel.textColor = Resource.Color.contentText
        
        productInformationLabel.text = ""
        productInformationLabel.lineBreakMode = .byWordWrapping
        productInformationLabel.textColor = Resource.Color.contentText
        
        productCodeLabel.text = ""
        productCodeLabel.font = Resource.Font.contentTextLight
        productCodeLabel.textColor = Resource.Color.contentText
        
        productSpecificationTitleLabel.text = "Product specification"
        productSpecificationTitleLabel.font = Resource.Font.heading2
        productSpecificationTitleLabel.textColor = Resource.Color.contentText
        
        productSpecificationStackView.spacing = 17
        
        // Layout right column
        let rightPriceDetailsView = PriceDetailsView.loadFromNib() as! PriceDetailsView
        rightPriceDetailsView.embed(in: rightPriceDetailsContainer)
        self.rightPriceDetailsView = rightPriceDetailsView
        
        // Apply layout for columns depending on orientation
        layoutColumns()

        // Configure with initial data from product
        configure(with: product)
        
        // Load more details for product
        loadProductDetails()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        layoutColumns()
    }
    
    func layoutColumns() {
        if UIDevice.current.orientation.isLandscape {
            rightScrollViewWidthConstraint.constant = defaultRightScrollViewWidth
            leftPriceDetailsContainer.isHidden = true
        } else {
            rightScrollViewWidthConstraint.constant = 0
            leftPriceDetailsContainer.isHidden = false
        }
    }
    
    func loadProductDetails() {
        NetworkManager.shared.productListService.fetch(byId: product.productId!) { [weak self] (product: Product?, error: HTTPClientError?) in
            guard let product = product, error == nil else {
                // TODO: error case
                return
            }
            self?.configure(with: product)
        }
    }
    
    func configure(with product: Product) {
        self.product = product

        title = product.title

        // Populate image slider
        if let urlStrings = product.media?.images?.urls {
            imageSliderViewController.configure(with: urlStrings.flatMap({ URL(httpsString: $0) }))
        }
        
        // Populate price details
        priceLabel.text = "£\(product.price?.now ?? "--")"
        specialOfferLabel.text = product.displaySpecialOffer
        rightPriceDetailsView.configure(with: product)
        
        // Add additional services separated by newline
        additionalServicesLabel.text = ""
        if let includedServices = product.additionalServices?.includedServices {
            var servicesString = ""
            for service in includedServices {
                servicesString += service + "\n"
            }
            additionalServicesLabel.text = servicesString
        }
        
        // Product information
        if let productInformation = product.details?.productInformation,
            let htmlAttributedString = NSAttributedString(html: productInformation, usingFont: Resource.Font.contentText) {
            productInformationLabel.attributedText = htmlAttributedString
        }
        
        // Product code
        if let productCode = product.code {
            productCodeLabel.text = "Product code: \(productCode)"
        }
        
        // Product specification
        if let features = product.details?.features,
            features.count > 0,
            let attributes = features[0].attributes {
            for attribute in attributes {
                // add separator and keyValueView to stackView for each attribute
                productSpecificationStackView.addArrangedSubview(separatorView())
                productSpecificationStackView.addArrangedSubview(keyValueView(name: attribute.name ?? "-", value: attribute.value ?? "-"))
            }
        }
    }
    
    
    // MARK: - Convenience methods
    
    private func separatorView() -> UIView {
        let separatorView = UIView()
        separatorView.backgroundColor = Resource.Color.divider
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return separatorView
    }
    
    private func keyValueView(name: String, value: String) -> KeyValueView {
        let keyValueView = KeyValueView.loadFromNib() as! KeyValueView
        keyValueView.nameLabel.font = Resource.Font.contentText
        keyValueView.valueLabel.font = Resource.Font.contentText
        keyValueView.nameLabel.textColor = Resource.Color.contentText
        keyValueView.valueLabel.textColor = Resource.Color.contentText
        keyValueView.configure(name: name, value: value)
        return keyValueView
    }
 
}
