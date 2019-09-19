//
//  UIImage+Extension.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

enum ImageAsset: String {
    
    //Product page
    case Icons_24px_CollectionView
    case Icons_24px_ListView
    
    //Product size and color picker
    case Image_StrikeThrough
    
    //PlaceHolder
    case Image_Placeholder
    
    //Back button
    case Icons_24px_Back02
    
    //Drop down
    case Icons_24px_DropDown
    case Icons_24px_Drawer //For 下拉秀出各個 list
    
    //Save Star
    case ic_star_border_24px
    case ic_star_filled_24px
    
    case JackAudioInput
    case DeviceInput1
    case DeviceInput2
    case DeviceInput3
    case DeviceInput4
    
    case NodeInputIconNormal
    case NodeInputIconSelected
    
    case PlugInBackgroundView1
    case PlugInBackgroundView2
    case PlugInBackgroundView3
    case PlugInBackgroundView4
    case PlugInBackgroundView5
    case PlugInBackgroundView6
    case PlugInBackgroundView7
    case PlugInBackgroundView8
    
    case PowerSwitchIcon
    
    case BarStatusView
    
    case PickButton
    
    case DownButton
}

// swiftlint:enable identifier_name

extension UIImage {
    
    
    static func asset(_ asset: ImageAsset) -> UIImage? {
        
        return UIImage(named: asset.rawValue)
    }
}
