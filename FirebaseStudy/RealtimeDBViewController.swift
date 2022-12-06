//
//  RealtimeDBViewController.swift
//  FirebaseStudy
//
//  Created by Châu Hiệp on 06/12/2022.
//

import UIKit
import Firebase
import FirebaseDatabase
class RealtimeDBViewController: UIViewController {
    
    var ref: DatabaseReference!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        observeData()
    }
    
    @IBAction func stopObserve(_ sender: Any) {
        self.ref.child("MYRTDB").child("users").removeAllObservers()
        self.textView.text = ""
    }
    @IBAction func didButtonClick(_ sender: Any) {
        if(textField.text != ""){
            self.ref.child("MYRTDB").child("users").child(textField.text!).setValue(textField.text!)
            textField.text = ""
        }
    }
    
    func observeData()
    {
        self.ref.child("MYRTDB").child("users").observe(.value, with: {(snapshot) in
            self.textView.text = ""
            
            if let oSnapShot = snapshot.children.allObjects as? [DataSnapshot] {
                for oSnap in oSnapShot {
                    if let sName = oSnap.value as? String {
                        print("NameL \(sName)")
                        self.textView.text = self.textView.text + sName + "\n"
                    }
                }
            }
        })
    }
}
