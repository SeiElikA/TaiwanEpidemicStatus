//
//  IAPManager.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/14.
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    static let shared = IAPManager()
    var products = [SKProduct]()
    fileprivate var productRequest: SKProductsRequest!
    
    func isDeviceCanPay() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func getProductIDs() -> [String] {
        ["com.seielika.TaiwanEpidemicStatus.SmallCoffee",
        "com.seielika.TaiwanEpidemicStatus.RemoveGoogleAds"]
//        [
//            "com.temporary.id.removeAds"
//        ]
    }
    
    func getProducts() {
        let productIds = getProductIDs()
        let productIdsSet = Set(productIds)
        productRequest = SKProductsRequest(productIdentifiers: productIdsSet)
        
        productRequest.delegate = self
        productRequest.start()
    }
    
    func buy(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("Payment Error")
        }
    }
    
    private func saveRemoveAdsStatus(isRemove: Bool) {
        UserDefaults().set(isRemove, forKey: Global.removeAdsProductID)
    }
    
    public func getRemoveAdsStatus() -> Bool {
        return UserDefaults().bool(forKey: Global.removeAdsProductID)
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach {
            print($0.localizedTitle, $0.regularPrice!, $0.localizedDescription)
        }
        
        self.products = response.products
    }
}

extension SKProduct {
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            print($0.payment.productIdentifier, $0.transactionState.rawValue)
            switch $0.transactionState {
            case .purchased:
                if $0.payment.productIdentifier == Global.removeAdsProductID {
                    saveRemoveAdsStatus(isRemove: true)
                }
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                print($0.error ?? "")
                if ($0.error as? SKError)?.code != .paymentCancelled {
                    // show Error
                    let alertController = UIAlertController(title: NSLocalizedString("BuyFailure", comment: ""), message: NSLocalizedString("BuyFailureReason", comment: ""), preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .cancel)
                    alertController.addAction(alertAction)
                    SettingsTableViewController.instance?.present(alertController, animated: true)
                    if $0.payment.productIdentifier == Global.removeAdsProductID {
                        saveRemoveAdsStatus(isRemove: false)
                    }
                }
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                if $0.payment.productIdentifier == Global.removeAdsProductID {
                    saveRemoveAdsStatus(isRemove: true)
                }
                SKPaymentQueue.default().finishTransaction($0)
            case .purchasing, .deferred:
                break
                
            @unknown default:
                break
            }
        }
    }
}
