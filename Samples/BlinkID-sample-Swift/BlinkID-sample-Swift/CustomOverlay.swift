//
//  CustomOverlay.swift
//  pdf417-sample-Swift
//
//  Created by Dino Gustin on 06/03/2018.
//  Copyright © 2018 Dino. All rights reserved.
//

import Microblink

class CustomOverlay: MBCustomOverlayViewController, MBScanningRecognizerRunnerViewControllerDelegate, MBFirstSideFinishedRecognizerRunnerViewControllerDelegate {
    
    @IBOutlet weak var tooltipLabel: UILabel!

    static func initFromStoryboardWith() -> CustomOverlay {
        let customOverlay: CustomOverlay = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomOverlay") as! CustomOverlay
        return customOverlay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.scanningRecognizerRunnerViewControllerDelegate = self
        super.metadataDelegates.firstSideFinishedRecognizerRunnerViewControllerDelegate = self

        self.tooltipLabel.text = "Scan Front Side"
    }
    
    func recognizerRunnerViewController(_ recognizerRunnerViewController: UIViewController & MBRecognizerRunnerViewController, didFinishScanningWith state: MBRecognizerResultState) {
        /** This is done on background thread */
        if state == MBRecognizerResultState.valid {
            recognizerRunnerViewController.pauseScanning()
            
            DispatchQueue.main.async {
                
                var message: String = ""
                var title: String = ""
                
                for recognizer in self.recognizerCollection.recognizerList {
                    if ( recognizer.baseResult?.resultState == MBRecognizerResultState.valid ) {
                        if recognizer is MBBlinkIdRecognizer {
                            let blinkIdRecognizer = recognizer as? MBBlinkIdRecognizer
                            title = "BlinkID"
                            message = (blinkIdRecognizer?.result.description)!
                        }
                        if recognizer is MBBlinkIdCombinedRecognizer {
                            let blinkIdRecognizer = recognizer as? MBBlinkIdCombinedRecognizer
                            title = "BlinkID Combined"
                            message = (blinkIdRecognizer?.result.description)!
                        }
                    }
                }
                
                let alertController: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                
                let okAction: UIAlertAction = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default,
                                                                 handler: { (action) -> Void in
                                                                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func recognizerRunnerViewControllerDidFinishRecognition(ofFirstSide recognizerRunnerViewController: UIViewController & MBRecognizerRunnerViewController) {

        DispatchQueue.main.async {
            self.tooltipLabel.text = "Scan Back Side"
        }
    }

    @IBAction func didTapClose(_ sender: Any) {
        self.recognizerRunnerViewController?.overlayViewControllerWillCloseCamera(self)
        self.dismiss(animated: true, completion: nil)
    }
    
}
