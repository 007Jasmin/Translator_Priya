//
//  AdsManager.swift
//  Simple Demo
//
//  Created by Sagar Lukhi on 27/12/22.
//
import Foundation
import UIKit
import GoogleMobileAds
import SVProgressHUD
import AppTrackingTransparency
import AdSupport


protocol AdsManagerDelegate {
    func NativeAdLoad()
    func DidDismissFullScreenContent()
    func NativeAdsDidFailedToLoad()
}

var interstitialAd: GADInterstitialAd?
var isNativeLoad : Bool = false

var NATIVE_ADS:GADNativeAd?

class AdsManager: NSObject {
    
    static let shared = AdsManager()
    var delegate: AdsManagerDelegate?
    
    var adLoader: GADAdLoader!
    var arrNativeAds = [GADNativeAd]()
    
    var appOpenAd :GADAppOpenAd?
    var loadTime = Date()
    
    //MARK:- TOP VIEW CONTROLLER
    
    var topMostViewController: UIViewController? {
        var currentVc = UIApplication.shared.keyWindow?.rootViewController
        while let presentedVc = currentVc?.presentedViewController {
            if let navVc = (presentedVc as? UINavigationController)?.viewControllers.last {
                currentVc = navVc
            } else if let tabVc = (presentedVc as? UITabBarController)?.selectedViewController {
                currentVc = tabVc
            } else {
                currentVc = presentedVc
            }
        }
        return currentVc
    }
    
    //MARK: - App Tracking
    
    func requestIDFA() {
      if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            
        })
      } else {
      }
    }

    
    //MARK: - LOAD INTERSTITIAL ADS
    func loadInterstitialAd(){
        
        if !APIManager.isConnectedToNetwork() && isUserSubscribe() {
            return
        }
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: GOOGLE_ADS.INTERSITIAL_ADS_ID, request: request) { [self] (ad, error) in
            if error != nil {
                print("Interstitial load error \(error?.localizedDescription ?? "")")
            } else {
                print("Interstitial load")
                interstitialAd = ad
                interstitialAd?.fullScreenContentDelegate = self
            }
        }
        
    }
    
    //MARK: - LOAD NATIVE ADS
    
    func createAndLoadNativeAds(numberOfAds: Int) {
        
        if !APIManager.isConnectedToNetwork() && isUserSubscribe(){
            return
        }
        arrNativeAds.removeAll()
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = numberOfAds
        
        adLoader = GADAdLoader(adUnitID: GOOGLE_ADS.NATIVE_ADS_ID, rootViewController: topMostViewController,
                               adTypes: [GADAdLoaderAdType.native],
                               options: [multipleAdsOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    //MARK:- LOAD APP OPEN ADS
    
    func tryToPresentAppOpenAd() {
        if isUserSubscribe(){
            return
        }
        let ad = appOpenAd
        appOpenAd = nil

        if let ad = ad {
            let rootController = appDelegate.window?.rootViewController
            ad.present(fromRootViewController: rootController!)
            requestAppOpenAd()
        } else {
             requestAppOpenAd()
        }
    }
    
    func requestAppOpenAd() {
        if isUserSubscribe(){
            return
        }
        appOpenAd = nil
        GADAppOpenAd.load(
            withAdUnitID: GOOGLE_ADS.APP_OPEN_AD,
            request: GADRequest(),
            orientation: UIInterfaceOrientation.portrait,
            completionHandler: { [self] appOpenAd, error in
                if let error = error {
                    print("Failed to load app open ad: \(error)")
                    return
                }
                self.appOpenAd = appOpenAd
                self.appOpenAd?.fullScreenContentDelegate = self
                self.loadTime = Date()
            })
    }
    
    //MARK: - PRESENT (INTERSITITAL, NATIVE) ADS
    func showInterstitialAd (_ isLoader:Bool = false, isRandom:Bool = false, ratio:Int = 3,shouldMatchRandom : Int = 2){
        
        
        if interstitialAd != nil {
            if isLoader {
                SVProgressHUD.show(withStatus: "Loading Ads...")
                
                SVProgressHUD.dismiss(withDelay: 0.5) {
                    self.checkRandomAndPresentInterstitial(isRandom: isRandom, ratio: ratio, shouldMatchRandom: shouldMatchRandom)
                }
            }
            else{
                self.checkRandomAndPresentInterstitial(isRandom: isRandom, ratio: ratio, shouldMatchRandom: shouldMatchRandom)
            }
            
        } else {
            print("intersisital Ad wasn't ready")
            if isNativeLoad{
                if arrNativeAds.count > 0{
                    //show here native as intertitals
//                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//                    if let customAdVc = storyBoard.instantiateViewController(withIdentifier: "CustomInterstitialViewController") as? CustomInterstitialViewController {
//                        customAdVc.arrNativeAds = arrNativeAds
//                        customAdVc.modalPresentationStyle = .overFullScreen
//                        topMostViewController?.present(customAdVc, animated: true, completion: nil)
//                    }
                }
            }else {
                print("native Ad wasn't ready")
            }
        }
        
        
    }
    
    func checkRandomAndPresentInterstitial( isRandom:Bool, ratio:Int,shouldMatchRandom :Int){
        if isRandom{
            let isRandomMatch = Int.random(in: 1 ... ratio) == shouldMatchRandom
            if isRandomMatch {
                self.presentInterstitialAd()
            }
        }
        else {
            self.presentInterstitialAd()
        }
    }
    
    func presentInterstitialAd() {
        if isUserSubscribe(){
            return
        }
        DispatchQueue.main.async {
            let rootController = appDelegate.window?.rootViewController
            interstitialAd?.present(fromRootViewController: rootController!)
            
        }
    }
    
    func presentInterstitialAd1(vc:UIViewController) {
        if isUserSubscribe(){
            return
        }
        DispatchQueue.main.async {
            if interstitialAd != nil {
                interstitialAd!.present(fromRootViewController: vc)
            }else{
                print("intersitial not load")
            }
        }
    }
    
    
}


// MARK: - Interstitial Delegate
extension AdsManager: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.", error.localizedDescription)
        loadInterstitialAd()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.DidDismissFullScreenContent()
    }
    
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        loadInterstitialAd()
    }
    
}

// MARK: - NativeAd Loader Delegate
extension AdsManager: GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        //        print("did Receive Native Ad \(nativeAd)")
        isNativeLoad = true
        arrNativeAds.append(nativeAd)
        self.delegate?.NativeAdLoad()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        isNativeLoad = false
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {

    }
    
}


// MARK: - Google Banner Ads -

class GoogleBannerAds: NSObject, GADBannerViewDelegate {
    
    var view: GADBannerView!
    
    func loadAds(vc: UIViewController, view : GADBannerView) {
        if isUserSubscribe(){
            return
        }
        view.isHidden = true
        let viewWidth = view.frame.size.width
        
        self.view = view
        self.view.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        self.view.adUnitID = GOOGLE_ADS.BANNER_ADS_ID
        self.view.rootViewController = vc
        self.view.delegate = self
        self.view.load(GADRequest())
    }
    
    // MARK: GADBannerViewDelegate Methods
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        view.isHidden = false
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        view.isHidden = true
    }

}


// MARK: - Google Native Ads -
class GoogleNativeAds: NSObject, GADNativeAdLoaderDelegate {
    
    var completion: ((GADNativeAd) -> Void)?
    var adLoader: GADAdLoader!
    
    func loadAds(_ vc: UIViewController, _ completion: @escaping (GADNativeAd) -> Void) {
        if isUserSubscribe(){
            return
        }
        self.completion = completion
        
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        self.adLoader = GADAdLoader(adUnitID: GOOGLE_ADS.NATIVE_ADS_ID, rootViewController: vc, adTypes: [GADAdLoaderAdType.native], options: [multipleAdsOptions])
        self.adLoader.load(GADRequest())
        self.adLoader.delegate = self
    }
    
    // MARK: - GADNativeAdLoaderDelegate Methods
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        completion!(nativeAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        debugPrint("Error: \(error.localizedDescription)")
    }
    
    // MARK: - Load View Methods
    
    let googleNativeAdsCustomeView1: GoogleNativeAdsCustomeView1 = GoogleNativeAdsCustomeView1.instanceFromNib() as! GoogleNativeAdsCustomeView1
    /// Load big native ads
    func showAdsView1(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView1)
        googleNativeAdsCustomeView1.nativeAd = nativeAd
        googleNativeAdsCustomeView1.setup()
    }
    
    let googleNativeAdsCustomeView2: GoogleNativeAdsCustomeView2 = GoogleNativeAdsCustomeView2.instanceFromNib() as! GoogleNativeAdsCustomeView2
    /// Load Ads like table view cell (Like Banner Ads)
    func showAdsView2(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView2)
        googleNativeAdsCustomeView2.nativeAd = nativeAd
        googleNativeAdsCustomeView2.setup()
    }
    
    let googleNativeAdsCustomeView4: GoogleNativeAdsCustomeView4 = GoogleNativeAdsCustomeView4.instanceFromNib() as! GoogleNativeAdsCustomeView4
    /// Load Ads like table view cell (Like Banner Ads)
    func showAdsView4(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView4)
        googleNativeAdsCustomeView4.nativeAd = nativeAd
        googleNativeAdsCustomeView4.setup()
    }
    
    let googleNativeAdsCustomeView3: GoogleNativeAdsCustomeView3 = GoogleNativeAdsCustomeView3.instanceFromNib() as! GoogleNativeAdsCustomeView3
    /// Load Ads like table view cell (Like Banner Ads)
    func showAdsView3(nativeAd: GADNativeAd, view: UIView) {
        view.isHidden = false
        displaySubViewtoParentView(view, subview: googleNativeAdsCustomeView3)
        googleNativeAdsCustomeView3.nativeAd = nativeAd
        googleNativeAdsCustomeView3.setup()
    }
    
    
}
