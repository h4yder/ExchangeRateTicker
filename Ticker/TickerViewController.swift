//
//  TickerViewController.swift
//  Ticker
//
//  Created by Hayder Al-Husseini on 06/07/2020.
//  Copyright © 2020 kodeba•se ltd.
//
//  See LICENSE.md for licensing information.
//

import UIKit

class TickerViewController: UIViewController {
    @IBOutlet private var scrollView: UIScrollView!
    
    private var lastXOffset: CGFloat?
    private var currencies: [Currency] = [] {
        didSet {
            configureCurrencyViews()
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
    }

    var displayLink: CADisplayLink?
    
    var recommendedHeight: CGFloat {
        guard !currencies.isEmpty else {
            return CGFloat(90.0)
        }
        view.layoutIfNeeded()
        return scrollView.contentSize.height
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let bundle = Bundle(for: TickerViewController.self)
        _ = bundle.loadNibNamed(String(describing: TickerViewController.self),
                                     owner: self,
                                     options: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatusChanged), name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
    }
    
    @objc func voiceOverStatusChanged() {
        if UIAccessibility.isVoiceOverRunning {
            stopAnimationTimer()
        } else {
            startAnimationTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ForexService().latestPrices { [weak self] currencies in
            self?.currencies = currencies
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if scrollView.contentSize.width > scrollView.frame.size.width {
            startAnimationTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimationTimer()
    }
    
    private func configureCurrencyViews() {
        var lastView: CurrencyView?
        let currentImages = ["aed", "cad", "cny", "dkk", "egp", "eur", "gbp", "inr", "jpy", "pln", "rub"]
        
        for currency in currencies {
            // Only display the currency views that have an image
            guard currentImages.contains(currency.imageName) == true else {
                continue
            }
            
            let currencyView = CurrencyView()
            scrollView.addSubview(currencyView)
            // Add top and bottom constraints
            NSLayoutConstraint.activate([
                currencyView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0),
                currencyView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0)
            ])

            let leadingConstraint: NSLayoutConstraint
            
            if lastView == nil {
                // This is the first currency view to be added.
                // Pin it's leading to the scroll view's leading
                leadingConstraint = NSLayoutConstraint(item: currencyView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0.0)
            } else {
                // There is a currency view that preceeds this one.
                // Pin this view's leading to the previous view's trailing
                leadingConstraint = NSLayoutConstraint(item: currencyView, attribute: .leading, relatedBy: .equal, toItem: lastView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            }
            
            scrollView.addConstraint(leadingConstraint)
            currencyView.currency = currency
            
            // Store this leading constraint, we'll need it when animating
            currencyView.leadingConstraint = leadingConstraint
                
            // Store the current view, we'll need it to add the next view
            lastView = currencyView
        }
        
        // We've added all our views. Let's pin the last view's trailing to the scroll view's trailling
        let trailingConstraint = NSLayoutConstraint(item: lastView!, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
     
        lastView?.trailingConstraint = trailingConstraint
        scrollView.addConstraint(trailingConstraint)
        scrollView.layoutIfNeeded()
        
        currencySubviews().forEach {
            if let element = $0.accessibilityElements?.first as? UIAccessibilityElement {
                element.accessibilityFrameInContainerSpace = $0.bounds
            }
        }
        
        // If total width of the views exceeds the width of the scroll view, animate the scroll view
        if scrollView.contentSize.width > scrollView.frame.size.width {
            startAnimationTimer()
        }
    }
    
    fileprivate func startAnimationTimer() {
        guard UIAccessibility.isVoiceOverRunning == false else {
            return
        }
        
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(update))
            displayLink?.add(to: RunLoop.current, forMode: .default)
        }
    }
    
    fileprivate func stopAnimationTimer() {
        if displayLink != nil {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    @objc func update() {
        var contentOffset = scrollView.contentOffset
        contentOffset.x += 0.5
        
        scrollView.contentOffset = contentOffset
    }
}

extension TickerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastOffset = lastXOffset else {
            lastXOffset = scrollView.contentOffset.x
            return
        }
        
        if lastOffset > scrollView.contentOffset.x {
            // Dragging right
            moveLastViewToTheBeginningIfNeeded()
        } else {
            // Dragging left
            moveFirstViewToTheEndIfNeeded()
        }
        
        lastXOffset = scrollView.contentOffset.x
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAnimationTimer()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startAnimationTimer()
    }
    
    func currencySubviews() -> [CurrencyView] {
        return scrollView.subviews.filter {
            guard let _ = $0 as? CurrencyView else {
                return false
            }
            return true
            } as! [CurrencyView]
    }
    
    func moveFirstViewToTheEndIfNeeded() {
        let subviews = currencySubviews()
        
        let count = subviews.count
        guard count > 2 else {
            return
        }
        
        let first = subviews[0]
        let second = subviews[1]
        let last = subviews[count - 1]
        let firstFrame = first.frame

        var contentOffset = scrollView.contentOffset
        
        if first.frame.origin.x + first.frame.size.width < contentOffset.x {
            first.removeFromSuperview()
            
            let secondLeading = NSLayoutConstraint(item: second, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0)
            second.leadingConstraint = secondLeading
            scrollView.addConstraint(secondLeading)
            
            scrollView.addSubview(first)
            if let lastTrailing = last.trailingConstraint {
                scrollView.removeConstraint(lastTrailing)
                last.trailingConstraint = nil
            }
            
            NSLayoutConstraint.activate([
                first.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0),
                first.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0)
            ])
         
            let firstTrailing = NSLayoutConstraint(item: first, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            
            first.trailingConstraint = firstTrailing
            scrollView.addConstraint(firstTrailing)
            
            let firstLeading = NSLayoutConstraint(item: last, attribute: .trailing, relatedBy: .equal, toItem: first, attribute: .leading, multiplier: 1.0, constant: 0.0)
            
            first.leadingConstraint = firstLeading
            scrollView.addConstraint(firstLeading)
            contentOffset.x -= firstFrame.origin.x + firstFrame.size.width
            scrollView.contentOffset = contentOffset
        }
    }
    
    func moveLastViewToTheBeginningIfNeeded() {
        let subviews = currencySubviews()
        
        let count = subviews.count
        guard count > 2 else {
            return
        }
        
        let first = subviews[0]
        let last = subviews[count - 1]
        let b4last = subviews[count - 2]

        if scrollView.contentOffset.x < 0 && last.frame.origin.x > scrollView.frame.size.width {
            last.removeFromSuperview()
            var contentOffset = scrollView.contentOffset
            let b4lastTrailingConstraint = NSLayoutConstraint(item: b4last, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0)
            b4last.trailingConstraint = b4lastTrailingConstraint
            scrollView.addConstraint(b4lastTrailingConstraint)
            
            
            scrollView.insertSubview(last, at: 0)
            if let firstLeading = first.leadingConstraint {
                scrollView.removeConstraint(firstLeading)
                first.leadingConstraint = nil
            }
            
            NSLayoutConstraint.activate([
                last.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0),
                last.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0)
            ])
            
            let trailing = NSLayoutConstraint(item: last, attribute: .trailing, relatedBy: .equal, toItem: first, attribute: .leading, multiplier: 1.0, constant: 0.0)
            
            last.trailingConstraint = trailing
            scrollView.addConstraint(trailing)
            
            let leading = NSLayoutConstraint(item: last, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0.0)
            
            last.leadingConstraint = leading
            scrollView.addConstraint(leading)
            contentOffset.x += last.frame.size.width
            scrollView.contentOffset = contentOffset
        }
    }
}
