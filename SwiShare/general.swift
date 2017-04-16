//
//  general.swift
//  SwiShare
//
//  Created by Turcu Ciprian on 17/04/2017.
//  Copyright © 2017 ToolAxy One S.R.L. All rights reserved.
//

import Foundation
import UIKit

class ssGeneral{
    
    func clipboardData(QRVal:String) -> String{
        
            
            let pasteboardString: String? = UIPasteboard.general.string
            
            if let theString: String = pasteboardString {
                
                return theString
            }
            return "Clipboard Empty on Device"
        
    }
}
