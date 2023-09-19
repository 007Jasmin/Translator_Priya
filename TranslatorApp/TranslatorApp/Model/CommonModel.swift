//
//  CommonModel.swift
//  TranslatorApp
//
//  Created by Priyadarshani on 19/09/23.
//

import Foundation

struct LanguageModel: Codable {
    var code: String
    var name: String
    var img: String
    var isValidToSpeak: Bool
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        img = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        isValidToSpeak = try values.decodeIfPresent(Bool.self, forKey: .isValidToSpeak) ?? false
    }
    
    init(code: String, name: String, img: String, isValidToSpeak: Bool) {
        self.code = code
        self.name = name
        self.img = img
        self.isValidToSpeak = isValidToSpeak
    }
    
    init() {
        code = ""
        name = ""
        img = ""
        isValidToSpeak = false
    }
}

struct HistoryModel: Codable {
    var id: String
    var langModel1: LanguageModel
    var langModel2: LanguageModel
    var strSource: String
    var strDestination: String
    var isSender: Bool
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        langModel1 = try values.decodeIfPresent(LanguageModel.self, forKey: .langModel1) ?? LanguageModel()
        langModel2 = try values.decodeIfPresent(LanguageModel.self, forKey: .langModel2) ?? LanguageModel()
        strSource = try values.decodeIfPresent(String.self, forKey: .strSource) ?? ""
        strDestination = try values.decodeIfPresent(String.self, forKey: .strDestination) ?? ""
        isSender = try values.decodeIfPresent(Bool.self, forKey: .isSender) ?? false
    }
    
    init() {
        id = ""
        langModel1 = LanguageModel()
        langModel2 = LanguageModel()
        strSource = ""
        strDestination = ""
        isSender = false
    }
}
