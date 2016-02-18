//
//  RandomFunction.swift
//  FlappyClone
//
//  Created by Abraham Sidabutar on 2/17/16.
//  Copyright © 2016 Abraham Sidabutar. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat {
    
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xffffffff)
    }
    
    public static func random(min min : CGFloat, max : CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}