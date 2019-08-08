//
//  CPSettingsViewController+Mail.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Firebase
import UIKit
import MessageUI

extension CPSettingsViewController: MFMailComposeViewControllerDelegate {
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch (result)
        {
        case .cancelled:
            DDLogInfo("Mail cancelled: you cancelled the operation and no email message was queued.");
            controller.dismiss(animated: true, completion: nil)
            self.view.makeToast(NSLocalizedString("EMAIL_CANCELLED", comment: ""))
            //            self.view.hideAllToasts()
            break;
        case .saved:
            DDLogInfo("Mail saved: you saved the email message in the drafts folder.");
            controller.dismiss(animated: true, completion: nil)
            self.view.makeToast(NSLocalizedString("EMAIL_SAVED", comment: ""))
            break;
        case .sent:
            DDLogInfo("Mail send: the email message is queued in the outbox. It is ready to send.");
            controller.dismiss(animated: true, completion: nil)
            self.view.makeToast(NSLocalizedString("EMAIL_SENT", comment: ""))
            break;
        case .failed:
            DDLogInfo("Mail failed: the email message was not saved or queued, possibly due to an error.");
            controller.dismiss(animated: true, completion:{
                let sendMailErrorAlert = UIAlertController.init(title: NSLocalizedString("EMAIL_FAILED_TITLE", comment: ""),
                                                                message: NSLocalizedString("EMAIL_FAILED_MESSAGE", comment: ""), preferredStyle: .alert)
                
                sendMailErrorAlert.addAction(UIAlertAction.init(title: NSLocalizedString("OK", comment: ""),
                                                                style: .default, handler: nil))
                self.present(sendMailErrorAlert,
                             animated: true, completion: nil)
            })
            break;
        default:
            DDLogInfo("Mail not sent.");
            break;
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func openEmail(email : String) {
        let mailComposeViewController = configuredMailComposeViewController(emailId:email)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
            DDLogInfo("Opening email for problem report ..")
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController(emailId:String) -> MFMailComposeViewController {
        
        //Set up a default body
        
        var infoDictionary = Bundle.main.infoDictionary
        let name = infoDictionary?["CFBundleDisplayName"] as? String
        let version = infoDictionary?["CFBundleShortVersionString"] as? String
        let build = infoDictionary?["CFBundleVersion"] as? String
        let label = String(format: "What were you doing?\n1.\n2.\n3.\n\n\nVersion Information:\n%@ v%@ (build %@)", name ?? "", version ?? "", build ?? "")
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([emailId])
        mailComposerVC.setSubject("Please describe your problem:")
        mailComposerVC.setMessageBody(label, isHTML: false)
        
        let data: Data? = snapshotAndZipLogs(true)
        if data != nil {
            //Send piz to get through e-mail filters!
            if let data = data {
                mailComposerVC.addAttachmentData(data, mimeType: "application/zip", fileName: "logs.piz")
                DDLogInfo("Logs attached successfully")
                
            }
        } else {
            DDLogWarn("No logs attached")
        }
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        DDLogInfo(NSStringFromClass(type(of: self)) + " " + "Function: \(#function)")
        
        let sendMailErrorAlert = UIAlertController(title: NSLocalizedString("EMAIL_DEVICE_CONFIG_TITLE", comment: ""), message: NSLocalizedString("EMAIL_DEVICE_CONFIG_MESSAGE", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            DDLogInfo("You pressed OK on send email alert")
        }
        sendMailErrorAlert.addAction(okAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
}
