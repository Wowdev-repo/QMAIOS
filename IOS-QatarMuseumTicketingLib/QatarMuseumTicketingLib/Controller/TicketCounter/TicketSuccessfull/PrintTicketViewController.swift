//
//  PrintTicketViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 26/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import JGProgressHUD
import WebKit
import PDFKit
import Toast_Swift

class PrintTicketViewController: UIViewController {

    //MARK:- Decleration
    var toastStyle = ToastStyle()
    
    let pdfView = PDFView()

    let hud = JGProgressHUD(style: .extraLight)
    var tabViewController = QMTLTabViewController()
        
    var isFromMyVisits = false
    var ticketForIdStr = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.lightGray
        
        toastStyle.messageColor = .white
        toastStyle.backgroundColor = .darkGray
        
        //MARK:- IBOutlet
        let rightButtonItem = UIBarButtonItem.init(
            title: getLocalizedStr(str: "Share"),
            style: .done,
            target: self,
            action: #selector(shareButtonAction(sender:))
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        
        self.navigationItem.title = getLocalizedStr(str: "VisitTicket")
      //  rightButtonItem.hidde
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        
        
        //ptWebView.load(URLRequest(url: URL(string: urlStr)!))
        
        hud.show(in: self.view)
        
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.topTabBarView.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Add PDFView to view controller.
        
        pdfView.frame = self.view.bounds
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(pdfView)
        
        // Fit content in PDFView.
        pdfView.autoScales = true
        
        var urlStr = ""
        
        if isFromMyVisits {
            urlStr = "\(QMTLConstants.GantnerAPI.PDFGenETicketByOrganisedVisit)\(QMTLConstants.AuthCreds.shopID)/en/\(ticketForIdStr)"
            
        }else{
            urlStr = "\(QMTLConstants.GantnerAPI.PDFGenETickets)\(QMTLConstants.AuthCreds.shopID)/en/\(ticketForIdStr)"
        }
        
        print("print ticket url = \(urlStr)")
        
        if let document = PDFDocument(url: URL(string: urlStr)!) {
            pdfView.document = document
           // self.navigationItem.rightBarButtonItem = rightButtonItem;
            hud.dismiss()
        }
        
        if pdfView.document == nil {
            
            hud.dismiss()
            showToast(message: "Ticket PDF not generated")
            self.navigationItem.rightBarButtonItem?.title = "";
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
            NSLog("share button disbale");
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                self.navigationController?.popViewController(animated: true)
            })
            
        }
       else {
            NSLog("share button enable");
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabViewController.topTabBarView.isHidden = false
    }
    
    
    
    @objc func shareButtonAction(sender: UIBarButtonItem)
    {
       if (pdfView.document != nil) {
         NSLog("share button click");
            let documento = pdfView.document?.dataRepresentation()
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView=self.view
            present(activityViewController, animated: true, completion: nil)
       }
    }
    
    
    //MARK:- Show Toast
    
    func showToast(message : String){
        self.view.makeToast(getLocalizedStr(str: message), duration: 2.0, position: .center, style: toastStyle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.view.hideAllToasts()
        })
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
