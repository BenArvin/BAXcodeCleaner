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
            guard successed, let infoStr = infoStr else {
                if completion != nil {
                    completion!(false, nil)
                }
                return
            }
            do {
                let regexp = try NSRegularExpression.init(pattern: "href=\\\"\\/BenArvin\\/BAXcodeCleaner\\/releases\\/tag\\/.*?\"")
                let checkResult: [NSTextCheckingResult] = regexp.matches(in: infoStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange.init(location: 0, length: infoStr.count))
                guard let fullStrRange = checkResult.first?.range else {
                    if let completion = completion {
                        completion(false, nil)
                    }
                    return
                }
                let fullStr = (infoStr as NSString).substring(with: fullStrRange)
                let lastDivRange = (fullStr as NSString).range(of: "/", options: .backwards)
                if lastDivRange.length != 1 {
                    if let completion = completion {
                        completion(false, nil)
                    }
                    return
                }
                let versionStrTmp = (fullStr as NSString).substring(from: lastDivRange.location + 1)
                if let completion = completion {
                    completion(true, versionStrTmp.replacingOccurrences(of: "\"", with: ""))
                }
            } catch {
                if let completion = completion {
                    completion(false, nil)
                }
                return
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
}
