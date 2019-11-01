//
//  ViewController.swift
//  Split
//
//  Created by Nathan Bala on 10/28/19.
//  Copyright © 2019 Nathan Bala. All rights reserved.
//

import UIKit
import Vision
import VisionKit


class ScanController: UIViewController, VNDocumentCameraViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var values = [Item]()
    var taxVal = Item(itemName: "tax", itemPrice: 0.0, itemAmount: 0, itemShared: true)
    
    @IBAction func nextButton(_ sender: Any) {
        performSegue(withIdentifier: "sharing", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! pickViewViewController
        var removeIndex = -1
        for (index, element) in self.values.enumerated(){
            if element.itemName.contains("Tax"){
                self.taxVal.itemPrice = element.itemPrice
                removeIndex = index
            }
        }
        if removeIndex != -1{
            self.values.remove(at: removeIndex)
        }
        vc.finalValues = self.values
        vc.taxVal = self.taxVal
    }
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
    }

    @IBAction func btnTakePicture(_ sender: Any) {
        
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    
    
    private func setupVision() {
        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            var tupList:[(text: String, location: Float)] = []
            var detectedText = ""
            for observation in observations {
                let loc = Float(observation.bottomLeft.y)
                guard let topCandidate = observation.topCandidates(1).first else { return }
                tupList += [(text: topCandidate.string, location: loc)]
                detectedText += topCandidate.string
                detectedText += "\n"
            }
            tupList.sort(by: {$0.location > $1.location})
            var Lines = [Line]()
            let firstTup = tupList[0]
            
            var currLine = Line(median:firstTup.location)
            var currLoc = firstTup.location
            currLine.lineArray.append(firstTup.text)
            
            for (index, element) in tupList.enumerated() {
                if index >= 1 {
                    currLoc = element.location
                    let offSet = abs(currLine.median - currLoc)
                    if offSet < 0.0095 {
                        currLine.lineArray.append(element.text)
                    }else{
                        Lines.append(currLine)
                        currLine = Line(median:currLoc)
                        currLine.lineArray.insert(element.text, at: 0)
                    }
                }
            }
            Lines.append(currLine)
            
            var finalLines = [Line]()
            var currIndex = 0
            while currIndex < Lines.count {
                let thisLine = Lines[currIndex].lineArray
                var flag = false
                for item in thisLine{
                    if item.count > 40 && item.count < 3{
                        continue
                    }
                    if item.contains("."){
                        flag = true
                    }
                    
                }
                if flag == true{
                    if thisLine.count > 1{
                        var priceFlag = false
                        for pos in thisLine {
                            if pos.range(of: #"(?=.*?\d)^\$?(([1-9]\d{0,2}(,\d{3})*)|\d+)?(\.\d{1,2})?$"#, options: .regularExpression) != nil{
                                    priceFlag = true
                            }
                        }
                        if priceFlag == true{
                            finalLines.append(Lines[currIndex])
                        }
                    }
                }
                currIndex += 1
            }
            self.values = [Item]()
            let finalText = ""
            for possiblePrice in finalLines{
                let currItem = Item(itemName: "", itemPrice: 0.0, itemAmount: 1, itemShared: false)
                var addFlag = true
                for part in possiblePrice.lineArray{
                    if part.range(of: #"(?=.*?\d)^\$?(([1-9]\d{0,2}(,\d{3})*)|\d+)?(\.\d{1,2})?$"#, options: .regularExpression) != nil{
                        currItem.itemPrice = Float(part) ?? 0
                    }else{
                        if part.contains("Amount") || part.contains("Subtotal") || part.contains("Total"){
                            addFlag = false
                        }
                        currItem.itemName += part
                    }
                }
                if addFlag == true{
                   self.values.append(currItem)
                }
            }
            
            DispatchQueue.main.async {
                self.textView.text = finalText
                self.textView.flashScrollIndicators()

            }
        }

        textRecognitionRequest.recognitionLevel = .accurate
    }
    
    private func processImage(_ image: UIImage) {
        imageView.image = image
        recognizeTextInImage(image)
        
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        textView.text = ""
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        let originalImage = scan.imageOfPage(at: 0)
        let newImage = compressedImage(originalImage)
        controller.dismiss(animated: true)
        
        processImage(newImage)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func compressedImage(_ originalImage: UIImage) -> UIImage {
        guard let imageData = originalImage.jpegData(compressionQuality: 1),
            let reloadedImage = UIImage(data: imageData) else {
                return originalImage
        }
        return reloadedImage
    }
}
