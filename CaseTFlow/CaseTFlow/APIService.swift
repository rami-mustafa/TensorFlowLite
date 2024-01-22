import Alamofire
import UIKit
import Foundation

class APIService {
    
    static let shared = APIService()

     private let baseURL = "http://localhost:3000/api"
     
     // Kullanıcı Girişi Yap
     func login(organizationCode: String, email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
         let url = "\(baseURL)/authenticate/sign-in"
         let parameters = [
             "organizationCode": organizationCode,
             "email": email,
             "password": password
         ]

         AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
             switch response.result {
             case .success(let value):
                 if let json = value as? [String: Any], let data = json["data"] as? [String: Any], let accessToken = data["accessToken"] as? [String: Any], let token = accessToken["token"] as? String {
                    
                     completion(.success(token))
                 } else {
                     completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                 }
             case .failure(let error):
                 completion(.failure(error))
             }
         }
     }
    
    // Resim Yükleme
    func uploadImage(token: String, image: UIImage, classname: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = "http://localhost:3000/api/object-detection/upload"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "multipart/form-data"
        ]

        AF.upload(multipartFormData: { multipartFormData in
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            }
            multipartFormData.append(Data(classname.utf8), withName: "classname")
        }, to: url, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
