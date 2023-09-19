import UIKit

extension String {
    public func length() -> Int {
        return self.lengthOfBytes(using: String.Encoding.utf8)
    }
    
    func equalsIgnoreCase (str : String) -> Bool {
        return self.compare(str, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil) == .orderedSame
    }
    
    func sizeOfString (width: CGFloat, font : UIFont) -> CGSize {
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
    
    var removeExcessiveSpaces: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespaces)
        let filtered = components.filter({!$0.isEmpty})
        return filtered.joined(separator: " ")
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidUrl : Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }
    
    var trimmed:String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var encoded:String {
        let str = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let data: Data? = str.data(using: String.Encoding.nonLossyASCII)
        let Value = String(data: data!, encoding: String.Encoding.utf8)
        return Value ?? ""
    }
    
    var urlEncoded:String {
        let data: Data? = self.data(using: String.Encoding.nonLossyASCII)
        let Value = String(data: data!, encoding: String.Encoding.utf8)
        return Value ?? ""
    }
    
    var decoded: String {
        let str = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let data: Data? = str.data(using: String.Encoding.utf8)
        let Value = String(data: data!, encoding: String.Encoding.nonLossyASCII)
        return Value ?? ""
    }
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension Collection {
    func toJSONString() -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) {
            return String(data: theJSONData, encoding: .utf8)
        }
        return nil
    }
}
