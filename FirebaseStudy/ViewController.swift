//
//  ViewController.swift
//  FirebaseStudy
//
//  Created by Châu Hiệp on 05/12/2022.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var googleAuth: GIDSignInButton!
    @IBOutlet var imageView:UIImageView!
    @IBOutlet var label: UILabel!
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.googleAuth.addGestureRecognizer(gesture)

        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
            let url = URL(string: urlString) else{
                return
            }

        label.text = urlString
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else{
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.image = image
            }

        })
        task.resume()
    }
    //MARK: Storage
    @IBAction func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated:  true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        
        guard let imageData = image.pngData() else{
            return
        }
        
        let pathRef = storage.child("images/file.png")
        pathRef.putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else{
                print("Failed to upload")
                return
            }
            pathRef.downloadURL(completion: {url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.label.text = urlString
                }
                
                print("Download URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
            })
        })
        //upload image data
        //get download
        //save download url to userDefaults
    }

     func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Google Auth
    @objc func checkAction(sender : UITapGestureRecognizer) {
        performGoogleSignInFlow()
    }
    private func performGoogleSignInFlow() {
      guard let clientID = FirebaseApp.app()?.options.clientID else { return }

      // Create Google Sign In configuration object.
      let config = GIDConfiguration(clientID: clientID)

      // Start the sign in flow!
      GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

        guard
          let authentication = user?.authentication,
          let idToken = authentication.idToken
        else {
          let error = NSError(
            domain: "GIDSignInError",
            code: -1,
            userInfo: [
              NSLocalizedDescriptionKey: "Unexpected sign in result: required authentication data is missing.",
            ]
          )
            print(error)
          return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { result, error in
          guard error == nil else {
              print(error)
              return
          }

          // At this point, our user is signed in
        }
      }
    }

}

