//
//  AlamofireHTTPS.swift
//  MyTestApp
//
//  Created by yxliu on 2018/12/3.
//  Copyright © 2018 cusc. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireHTTPS {

    enum IdentityError: Error {
        case pathError
        case passwordError
        case undefinedError
    }

    //定义一个结构体，存储认证相关信息
    struct IdentityAndTrust {
        var identityRef: SecIdentity
        var trust: SecTrust
        var certArray: AnyObject
    }

    func challenge(_ cerPath: String, _ p12Path: String, _ password: String) {

        let manager = SessionManager.default

        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {//服务器证书认证

                let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
                let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!

                let cerUrl = URL(fileURLWithPath: cerPath)
                let localCertificateData = try! Data(contentsOf: cerUrl)

                if remoteCertificateData.isEqual(localCertificateData) {
                    let credential = URLCredential(trust: serverTrust)
                    challenge.sender?.use(credential, for: challenge)
                    return(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))

                } else {

                    return (.cancelAuthenticationChallenge, nil)

                }

            } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {//客户端证书验证

                let identityAndTrust: IdentityAndTrust = try! self.extractIdentity(p12Path, password)

                let urlCredential = URLCredential(identity: identityAndTrust.identityRef, certificates: identityAndTrust.certArray as? [Any], persistence: URLCredential.Persistence.forSession)

                return (.useCredential, urlCredential)

            }

            return (.cancelAuthenticationChallenge, nil)

        }
    }

    //获取客户端证书p12相关信息
    func extractIdentity(_ path: String, _ password: String) throws -> IdentityAndTrust {

        var identityAndTrust: IdentityAndTrust!
        var securityError: OSStatus = errSecSuccess

        guard let PKCS12Data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            throw IdentityError.pathError
        }

        let key: NSString = kSecImportExportPassphrase as NSString
        let options = [key: password]

        var items: CFArray?
        securityError = SecPKCS12Import(PKCS12Data as CFData, options as CFDictionary, &items)

        if securityError == errSecSuccess {
            let certItems: CFArray = items!
            let certItemsArray: Array = certItems as Array
            let dict: AnyObject? = certItemsArray.first
            if let certEntry: Dictionary = dict as? Dictionary<String, AnyObject> {

                let identityPointer: AnyObject? = certEntry["identity"]
                let secIdentityRef: SecIdentity = identityPointer as! SecIdentity

                let trustPointer: AnyObject? = certEntry["trust"]
                let trustRef: SecTrust = trustPointer as! SecTrust

                let chainPointer = certEntry["chain"]
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray: chainPointer!)

            }
        } else {

            throw IdentityError.passwordError

        }

        return identityAndTrust

    }

}
