//
//  GoogleNativeAdsCustomeView1.swift
//  Simple Demo
//
//  Created by Sagar Lukhi on 27/12/22.
//

import UIKit
import GoogleMobileAds

class GoogleNativeAdsCustomeView1: UIView {

    // OUTLET
    @IBOutlet var adUIView: GADNativeAdView!
    @IBOutlet weak var imgIconWidthConstant: NSLayoutConstraint!
    
    // VARIABLE
    var nativeAd: GADNativeAd = GADNativeAd()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GoogleNativeAdsCustomeView1", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Methods
    func setup() {
        
        // Get the ad view from the Cell. The view hierarchy for this cell is defined in
        // UnifiedNativeAdCell.xib.
        let adView : GADNativeAdView = adUIView
        
        // Associate the ad view with the ad object.
        // This is required to make the ad clickable.
        adView.nativeAd = nativeAd
        
        // Populate the ad view with the ad assets.
        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (adView.headlineView as! UILabel).text = nativeAd.headline
        adView.mediaView?.mediaContent = nativeAd.mediaContent
        (adView.bodyView as! UILabel).text = "\t" + (nativeAd.body ?? "")
        
        // The SDK automatically turns off user interaction for assets that are part of the ad, but
        // it is still good to be explicit.
        (adView.callToActionView as! UIButton).isUserInteractionEnabled = false
        (adView.callToActionView as! UIButton).layer.cornerRadius = 20
        (adView.callToActionView as! UIButton).setTitle(nativeAd.callToAction, for: UIControl.State.normal)
//        adView.backgroundColor = UIColor.clear
        let data = (adView.iconView as? UIImageView)?.image?.pngData()
        if data == nil {
            imgIconWidthConstant.constant = 0
        }
    }

}
