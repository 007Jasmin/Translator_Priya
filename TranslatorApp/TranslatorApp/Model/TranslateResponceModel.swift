//
//  TextTranslateViewModel.swift
//  Translate All
//
//  Created by admin on 09/07/22.
//

/* (Responce)
 
 {
     "sentences": [
         {
             "trans": "હેલો આ પ્રતિક છે?",
             "orig": "hello this is pratik ?"
         }
     ],
     "alternative_translations": [
         {
             "src_phrase": "hello this is pratik ?",
             "alternative": [
                 {
                     "word_postproc": "હેલે"
                 }
             ]
         }
     ]
 }
 
 */

import Foundation

struct TranslateResponceModel: Codable {
    var sentences: [Sentence]
    var alternativeTranslations: [AlternativeTranslation]

    enum CodingKeys: String, CodingKey {
        case sentences
        case alternativeTranslations = "alternative_translations"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sentences = try values.decodeIfPresent([Sentence].self, forKey: .sentences) ?? []
        alternativeTranslations = try values.decodeIfPresent([AlternativeTranslation].self, forKey: .alternativeTranslations) ?? []
    }
    
    init() {
        sentences = []
        alternativeTranslations = []
    }
    
    // MARK: - AlternativeTranslation
    struct AlternativeTranslation: Codable {
        var srcPhrase: String
        var alternative: [Alternative]

        enum CodingKeys: String, CodingKey {
            case srcPhrase = "src_phrase"
            case alternative
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            srcPhrase = try values.decodeIfPresent(String.self, forKey: .srcPhrase) ?? ""
            alternative = try values.decodeIfPresent([Alternative].self, forKey: .alternative) ?? []
        }
        
        init() {
            srcPhrase = ""
            alternative = []
        }
    }

    // MARK: - Alternative
    struct Alternative: Codable {
        var wordPostproc: String

        enum CodingKeys: String, CodingKey {
            case wordPostproc = "word_postproc"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            wordPostproc = try values.decodeIfPresent(String.self, forKey: .wordPostproc) ?? ""
        }
        
        init() {
            wordPostproc = ""
        }
    }

    // MARK: - Sentence
    struct Sentence: Codable {
        var trans, orig: String
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            trans = try values.decodeIfPresent(String.self, forKey: .trans) ?? ""
            orig = try values.decodeIfPresent(String.self, forKey: .orig) ?? ""
        }
        
        init() {
            trans = ""
            orig = ""
        }
    }
}

