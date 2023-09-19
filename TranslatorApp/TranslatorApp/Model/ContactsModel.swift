//
//  ContactsModel.swift
//  TheMessenger
//
//  Created by Jasmin Upadhyay on 23/02/23.
//

import Foundation
import UIKit

class ContactsModel : NSObject {
    let givenName: String
    let familyName: String
    let phoneNumber: [String]
    let emailAddress: String
    var identifier: String
    
    init(givenName:String, familyName:String, phoneNumber:[String], emailAddress:String, identifier:String)
    {
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.identifier = identifier
    }
}
