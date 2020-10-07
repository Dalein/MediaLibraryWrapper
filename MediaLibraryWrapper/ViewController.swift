//
//  ViewController.swift
//  MediaLibraryWrapper
//
//  Created by daleijn on 06.10.2020.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    private lazy var mediaPicker = GIMediaCommonPicker(parentVC: self)    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func chooseImageOrVideoButtonDidTap(_ sender: Any) {
        mediaPicker.showAlertChooseMediaType([.images]) { [weak self] media in
            print("Get media: \(media)")
        }
    }
    
}


private extension ViewController {
    
    func playVideo(from url: URL) {
        print("url: \(url)")
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        self.present(playerVC, animated: true, completion: nil)
    }
    
}
