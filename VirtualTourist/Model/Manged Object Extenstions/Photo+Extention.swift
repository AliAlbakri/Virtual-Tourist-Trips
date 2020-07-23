//
//  Photo+Extention.swift
//  VirtualTourist
//
//  Created by Ali Ahmad on 16/07/2020.
//  Copyright © 2020 Ali Ahmed. All rights reserved.
//

import Foundation

extension Photo{
    public override func awakeFromInsert() {
           super.awakeFromInsert()
           downloadDate = Date()
       }
}
