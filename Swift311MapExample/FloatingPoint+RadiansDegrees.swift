//
//  FloatingPoint+RadiansDegrees.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 3/5/18.
//  Copyright © 2018 NYC DoITT. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}
