//
//  CurrencyView.swift
//  Ticker
//
//  Created by Hayder Al-Husseini on 02/07/2020.
//  Copyright © 2020 kodeba•se ltd.
//
//  See LICENSE.md for licensing information.
//

import UIKit

class CurrencyView: UIView {
    private struct Constants {
        static let maximumFontSize: CGFloat = 40.0
    }
    
    @IBOutlet private weak var flagImageView: UIImageView!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var rateLabel: UILabel!
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    var currency: Currency? {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Load the nib
        let name = String(describing: CurrencyView.self)
        let bundle = Bundle(for: CurrencyView.self)
        guard let objects = bundle.loadNibNamed(name, owner: self, options: .none),
            let topView = objects.first as? UIView else {
                return
        }
    
        // Add the top view from the nib to our view's hierarchy
        addSubview(topView)
        translatesAutoresizingMaskIntoConstraints = false
        // Set up the constraints by pinning the top view to it's superview
        topView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([topView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     topView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     topView.topAnchor.constraint(equalTo: topAnchor),
                                     topView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        configureAccessibility()
    }
    
    override func updateConstraints() {
        flagImageView.layer.cornerRadius = flagImageView.frame.size.width * 0.5
        flagImageView.layer.borderWidth = 0.5
        flagImageView.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        super.updateConstraints()
    }
    
    override func didMoveToSuperview() {
        superview?.didMoveToSuperview()
        guard superview != nil else {
            return
        }
        
        update()
        updateConstraints()
    }
    
    private func update() {
        guard let currency = currency else {
            return
        }
        
        flagImageView?.image = UIImage(named: currency.imageName)
        codeLabel?.text = currency.code
        rateLabel?.text = currency.rate
        
        configureAccessibilityElement()
    }
    
    //MARK: - Accessibility

    private func configureAccessibility() {
        // Configure the label's fonts to be accessible
        for label in [codeLabel, rateLabel] {
            if let font = label?.font {
                label?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: font, maximumPointSize: Constants.maximumFontSize)
            }
        }
    }
    
    private func configureAccessibilityElement() {
        guard let currency = currency else {
            return
        }
        
        let element = CurrencyViewAccessibilityElement(accessibilityContainer: self, currency: currency)
        accessibilityElements = [element]
    }
}
