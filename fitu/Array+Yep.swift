//
//  Array+Yep.swift
//  Yep
//
//  Created by NIX on 15/7/30.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

extension Array {

    subscript (safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}