//
//  String+FirstLetter.swift
//  CampusWalk
//
//  Created by Watson Li on 10/16/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import Foundation

extension String {
    func firstLetter() -> String? {
        return (self.isEmpty ? nil : self.substring(to: self.characters.index(after: self.startIndex)))
    }
}
