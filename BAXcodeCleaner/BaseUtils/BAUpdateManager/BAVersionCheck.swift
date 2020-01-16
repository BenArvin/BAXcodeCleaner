//
//  BAVersionCheck.swift
//  BAXcodeCleaner
//
//  Created by BenArvin on 2020/1/15.
//  Copyright © 2020 BenArvin. All rights reserved.
//

import Foundation

public class BAVersionCheck {
    public class func currentVersion() -> String? {
        if Bundle.main.infoDictionary == nil {
            return nil
        }
        let result = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        return result
    }
    
    public class func queryLatestVersion(_ completion: ((_ : Bool, _: String?) -> ())?) {
        self._requestRepoInfo { (successed, infoStr) in
            if successed == false || infoStr == nil {
                if completion != nil {
                    completion!(false, nil)
                }
                return
            }
            let infoDic: [String: Any?]? = self._analyzeRepoInfo(infoStr!)
            if infoDic == nil {
                if completion != nil {
                    completion!(false, nil)
                }
                return
            }
            let tagName: String? = infoDic!["tag_name"] as? String ?? nil
            let version: String? = self._analyzeTagName(tagName)
            if completion != nil {
                completion!(!(version == nil || version!.isEmpty), version)
            }
        }
    }
}

extension BAVersionCheck {
    private class func _requestRepoInfo(_ completion: ((_: Bool, _: String?) -> ())?) {
        let requestUrl: URL? = URL.init(string: BAUpdateManager.Constants.Repo.LatestRelase)
        if requestUrl == nil {
            if completion != nil {
                completion!(false, nil)
            }
        }
        let requestTmp: NSMutableURLRequest = NSMutableURLRequest.init(url: requestUrl!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30)
        requestTmp.httpMethod = "GET"
        requestTmp.setValue("curl/7.64.1", forHTTPHeaderField: "User-Agent")
        requestTmp.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        let request: URLRequest = requestTmp as URLRequest
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil || data == nil || response == nil {
                if completion != nil {
                    completion!(false, nil)
                }
                return
            }
            let responseTmp: HTTPURLResponse = response! as! HTTPURLResponse
            let dataStr = String(data: data!, encoding: String.Encoding.utf8)
            if completion != nil {
                if responseTmp.statusCode == 200 {
                    completion!(true, dataStr)
                } else {
                    completion!(false, nil)
                }
            }
        }.resume()
    }
    
    private class func _analyzeRepoInfo(_ infoStr: String?) -> [String: Any?]? {
        if infoStr == nil || infoStr!.isEmpty {
            return nil
        }
        let jsonData: Data? = infoStr!.data(using: String.Encoding.utf8)
        if jsonData == nil {
            return nil
        }
        var result: [String: Any?]? = nil
        do {
            try result = JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as? [String : Any?] ?? nil
        } catch {
            return nil
        }
        return result
    }
    
    private class func _analyzeTagName(_ tagName: String?) -> String? {
        if tagName == nil || tagName!.isEmpty {
            return nil
        }
        var expression: NSRegularExpression? = nil
        do {
            try expression = NSRegularExpression.init(pattern: "^v[0-9]*.[0-9]*.[0-9]*$")
        } catch {
            return nil
        }
        if expression == nil {
            return nil
        }
        let checkResult: [NSTextCheckingResult] = expression!.matches(in: tagName!, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange.init(location: 0, length: tagName!.count))
        if checkResult.count == 0 {
            return nil
        }
        let resultTmp = tagName![tagName!.index(tagName!.startIndex, offsetBy: 1)..<tagName!.index(tagName!.startIndex, offsetBy: tagName!.count)]
        return String(resultTmp)
    }
}
