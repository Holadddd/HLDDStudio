//
//  UIColor+Extension.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

private enum STColor: String {
    
    // swiftlint:disable identifier_name
    case B1 = "0b0d12"
    
    case B2
    
    case B3
    
    case B4
    
    case B5
    
    case B6
    
    case G1
    // swiftlint:enable identifier_name
    case pickerViewCoponemtBackground
    
    case pickerViewBackground = "darkGray"
}

extension UIColor {
    
    static let B1 = STColor(.B1)
    
    static let B2 = STColor(.B2)
    
    static let B4 = STColor(.B4)
    
    static let B5 = STColor(.B6)
    
    static let G1 = STColor(.G1)
    
    static let PBG = STColor(.pickerViewCoponemtBackground)
    
    private static func STColor(_ color: STColor) -> UIColor? {
        
        return UIColor.hexStringToUIColor(hex: color.rawValue)
    }
    
    static func hexStringToUIColor(hex: String) -> UIColor {
        
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count) != 6 {
            
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    
   convenience init(red: Int, green: Int, blue: Int) {
    
       assert(red >= 0 && red <= 255, "Invalid red component")
    
       assert(green >= 0 && green <= 255, "Invalid green component")
    
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
    
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
