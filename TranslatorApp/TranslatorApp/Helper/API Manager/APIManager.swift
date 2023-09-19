import Foundation
import SystemConfiguration
import Alamofire
import CoreMedia

public class APIManager {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func toJson(_ dict:[String:Any]) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
    
    func networkErrorMsg() {
        showAlert("Error", message: "You are not connected to the internet") {}
    }
    
    func getJsonHeader() -> HTTPHeaders {
        return ["X-RapidAPI-Host": "","X-RapidAPI-Key": ""]
    }
    
    func getMultipartHeader() -> HTTPHeaders {
        return ["Content-Type":"multipart/form-data", "Accept":"application/json"]
    }
    
    func getMultipartHeaderWithRawData() -> HTTPHeaders {
        return ["Content-Type":"multipart/form-data", "Accept":"application/json"]
    }
    
    // MARK: APIs
    func POST_MULTIPART_API(api: String, param: [String: Any], image: Data?, isShowLoader: Bool, _ completion: @escaping (_ data: Data?) -> Void) {
        if !APIManager.isConnectedToNetwork() {
            APIManager().networkErrorMsg()
            return
        }
        
        isShowLoader ? (showLoader()) : nil
        let headerParams = getMultipartHeader()
        
        AF.upload(multipartFormData: { multipartFormData in
            if let image = image {
                multipartFormData.append(image, withName: "image",fileName: "image.jpg", mimeType: "image/jpg")
            }
            for (key, value) in param {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: api, usingThreshold: UInt64.init(), method: .post, headers: headerParams).responseData { response in
            isShowLoader ? (removeLoader()) : nil
            switch response.result {
                case .success(_):
                    if let data = response.data {
                        completion(data)
                        return
                    }
                    break
                
                case .failure(let error):
                    displayToast(error.localizedDescription)
                    break
            }
        }
    }
    
    func POST_API(api: String, param: [String: Any], isShowLoader: Bool, _ completion: @escaping (_ data: Data?) -> Void) {
        if !APIManager.isConnectedToNetwork() {
            APIManager().networkErrorMsg()
            return
        }
        
        isShowLoader ? (showLoader()) : nil
        // let headerParams = getMultipartHeaderWithRawData() // getMultipartHeader()
        
        AF.request(api, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseData { response in
            isShowLoader ? (removeLoader()) : nil
            switch response.result {
                case .success(_):
                    if let data = response.data {
                        completion(data)
                        return
                    }
                    break
                
                case .failure(let error):
                    displayToast(error.localizedDescription)
                    break
            }
        }
    }
    
    func GET_API(api: String, isShowLoader: Bool, _ completion: @escaping (_ data: Data?) -> Void) {
        if !APIManager.isConnectedToNetwork() {
            APIManager().networkErrorMsg()
            return
        }
        
        isShowLoader ? (showLoader()) : nil
        let headerParams = getJsonHeader()
        
        AF.request(api, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headerParams).responseData { response in
            isShowLoader ? (removeLoader()) : nil
            switch response.result {
                case .success(_):
                    if let data = response.data {
                        completion(data)
                        return
                    }
                    break
                
                case .failure(let error):
                    displayToast(error.localizedDescription)
                    break
            }
        }
    }
    
    // MARK: Download
    func DOWNLOAD_ANY_FILE(url: String, isShowLoader: Bool, _ complition: @escaping (_ data: String) -> Void) {
        if !APIManager.isConnectedToNetwork() {
            APIManager().networkErrorMsg()
            return
        }
        
        isShowLoader ? (showLoader()) : nil
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask, options: DownloadRequest.Options.removePreviousFile)
        
        AF.download(url, interceptor: nil, to: destination).downloadProgress { progress in
            debugPrint(progress.fractionCompleted)
        }.response { response in
            isShowLoader ? (removeLoader()) : nil
            if response.error == nil, let filePath = response.fileURL?.path {
                complition(filePath)
            }
        }
    }
    
    //MARK: API Calling
    
//    func GET_MATCHES_DATEWISE(date:Date, isShowLoader: Bool, _ completion: @escaping (_ data: Data?) -> Void){
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = DATE_FORMATE.Formate_7  //"2019-07-29"
//        let dateStr = dateFormatter.string(from: date)
//        let url = String.init(format: API.MATCHES_LIST, dateStr)
//        print("url...",url)
//        self.GET_API(api: url, isShowLoader: isShowLoader) { data in
//            completion(data)
//        }
//    }
  
}
