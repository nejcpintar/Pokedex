//
//  Date+jsonString.swift
//  Pokedex
//
//  Created by Nejc on 28.2.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation

extension Date {
    enum DateError: Error {
        case dateFormatInvalid
    }
    
    init(jsonString: String) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        guard let date = formatter.date(from: jsonString) else {
            throw DateError.dateFormatInvalid
        }
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
}
