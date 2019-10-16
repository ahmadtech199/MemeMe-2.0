//
//  AddImageViewController.swift
//  MemeMe 1.0
//
//  Created by Ahmad on 03/10/2019.
//  Copyright © 2019 Ahmad. All rights reserved.
//

import UIKit

class AddImageViewController: UIViewController, UITextFieldDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var topNavBar: UINavigationBar!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    var memeSentFromMain: Meme?
     
     override var prefersStatusBarHidden: Bool {
         return true
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(textField: topTextField)
        configureTextField(textField: bottomTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let memeFromDetail = memeSentFromMain as Meme? {
                  imagePickerView.image = memeFromDetail.image
              }
        
        if let _ = imagePickerView.image {
            shareButton.isEnabled = true
            cancelButton.isEnabled = true
            
        } else {
            shareButton.isEnabled = false
            cancelButton.isEnabled = false
            
        }
        
        //To enable or disable camera bar button if camera is available for use or not
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        //TO show keyboard
        self.subscribeToKeyboardNotifications()
    }
    
    // Mark: - Hide keyboard
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    
    @IBAction func takeImage(_ sender: UIButton) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        if (sender.tag == 0){
            imagePicker.sourceType = .camera
        }
        else {
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker,animated: true,completion: nil)
    }
    
    
    // MARK: - Text related
    func configureTextField(textField: UITextField) {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -4.0
        ]
        
        topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: memeTextAttributes)
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: memeTextAttributes)
        textField.textAlignment = .center
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Keyboard
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            print("keyboardWillShow Bottom")
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            print("keyboardWillHide Bottom")
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddImageViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddImageViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    //MARK: - Share
    @IBAction func share(_ sender: Any) {
        //generate a memed image
        let memedImage = generateMemedImage()
        
        //define an instance of ActivityViewController
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        // pass the ActivityViewController a memedImage as an activity item
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
        //present the VC
        present(activityVC, animated: true, completion: nil)
    }
    
    
    //MARK: - Cancel
    @IBAction func cancel(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        cancelButton.isEnabled = false
        shareButton.isEnabled = false
        dismiss(animated: true, completion: nil)

    }
    
    //MARK: - Meme related
    func generateMemedImage() -> UIImage {
        //Hide Toolbar And Navigation Bar
        setNavBarVisibilty(true)
        //        topNavBar.isHidden = true
        //        toolbar.isHidden = true
        // Render View To An Image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show Toolbar and Navigation Bar
        setNavBarVisibilty(false)
        //        topNavBar.isHidden = false
        //        toolbar.isHidden = false
        return memedImage
    }
    
    // shortCut method about navbar and toolBar
    func setNavBarVisibilty(_ value:Bool) {
        topNavBar.isHidden = !value
        toolbar.isHidden = !value
    }
    
    func save() {
        // Create The Meme
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image, memedImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
    }
    
    //MARK: - open photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        if let image = info[.originalImage] as? UIImage {
            // Set photoImageView to display the selected image.
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
        }
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}


