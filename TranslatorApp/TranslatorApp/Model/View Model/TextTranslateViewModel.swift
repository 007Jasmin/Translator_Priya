//
//  TextTranslateViewModel.swift
//  Translate All
//
//  Created by admin on 09/07/22.
//

import Foundation

struct TextTranslateViewModel {
    
    func translateText(_ isShowLoader: Bool, _ url: String, completion: @escaping (TranslateResponceModel?, Error?) -> Void) {
        APIManager().GET_API(api: url, isShowLoader: isShowLoader) { data in
            var errorAPI: NSError?
            if let data = data {
                do {
                    let success = try JSONDecoder().decode(TranslateResponceModel.self, from: data)
                    completion(success, nil)
                } catch {
                    // displayToast(error.localizedDescription)
                    errorAPI = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong !"])
                    completion(nil, errorAPI)
                }
            } else {
                // debugPrint("Something went wrong !")
                errorAPI = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong !"])
                completion(nil, errorAPI)
            }
        }
    }
}
