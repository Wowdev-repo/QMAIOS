//
//  CPSessionManager.swift
//  QatarMuseums
//
//  Created by Musheer on 4/14/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation
import Alamofire

class CPSessionManager {
    
    static let sharedInstance = CPSessionManager()
    private var manager : SessionManager?
    
    
    func apiManager() -> SessionManager? {
        
        if let instance = self.manager {
            
            return instance
            
        } else {
            
            let hostURL = "qm.org.qa"
            
            print("\n HOST URL: \(hostURL)")
            
            
            /// Using Alamofire method to generate serverTrustPolicies
            
            let serverTrustPolicies: [String: ServerTrustPolicy] = [
                
                hostURL: ServerTrustPolicy.pinPublicKeys(
                    
                    publicKeys:savedPublicKeys(),
                    
                    validateCertificateChain:true,
                    
                    validateHost:true
                    
                )]
            
            let configuration = URLSessionConfiguration.default
            
            /// Configuring Alamofire SessionManager.
            
            self.manager = SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
            
            /// Checking the session manager instance.
            
            if self.manager != nil {
                
                return self.manager
                
            } else {
                
                return nil
                
            }
            
        }
        
    }
    
    
    
    /// Fetching public keys from avail Certificates.
    
    private func savedPublicKeys() -> [SecKey]    {
        
        var publicKeys:[SecKey] = []
        
        let clientBundle:Bundle? = Bundle.main
        
        /// Reading Publickeys from Main Bundle using Alamofire method.
        
        for localKey in ServerTrustPolicy.publicKeys(in: clientBundle!) {
            
            publicKeys.append(localKey)
            
        }
        print("\n PUBLIC KEYS: \(publicKeys)")
        
        return publicKeys
        
    }
    
    func enableCertificatePinning() {
        //    let certificates: [SecCertificate] = []
        let certificates = getCertificates()
        let trustPolicy = ServerTrustPolicy.pinCertificates(
            certificates: certificates,
            validateCertificateChain: true,
            validateHost: true)
        let trustPolicies = [ "qm.org.qa": trustPolicy ]
        let policyManager =  ServerTrustPolicyManager(policies: trustPolicies)
        manager = SessionManager(
            configuration: .default,
            serverTrustPolicyManager: policyManager)
    }
    
    private func getCertificates() -> [SecCertificate] {
        let url = Bundle.main.url(forResource: "qmcert", withExtension: "cer")!
        let localCertificate = try! Data(contentsOf: url) as CFData
        guard let certificate = SecCertificateCreateWithData(nil, localCertificate)
            else { return [] }
        
        return [certificate]
    }
    
}


