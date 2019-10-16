//
//  DetailMemeVC.swift
//  MemeMe 1.0
//
//  Created by Ahmad on 15/10/2019.
//  Copyright © 2019 Ahmad. All rights reserved.
//

import UIKit

class DetailMemeVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = meme.memedImage
    }
    @IBAction func editAction(_ sender: Any) {
        
            let mainVC = storyboard!.instantiateViewController(withIdentifier: "AddImageViewController") as! AddImageViewController
            mainVC.memeSentFromMain = self.meme
            self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }


