//
//  CaptureImageVC.swift
//  Translate All
//
//  Created by Jasmin Upadhyay on 30/05/23.
//

import UIKit
import Vision
import VisionKit

class CaptureImageVC: UIViewController {

    @IBOutlet var image1: UIImageView!
    @IBOutlet var btnDone:UIButton!
    @IBOutlet var btnRetake:UIButton!
    
    var img1:UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFromImage(imgVal: img1.fixOrientation()!)
        self.btnDone.setTitle("Done".localized(), for: .normal)
        self.btnRetake.setTitle("Retake".localized(), for: .normal)
    }
    
    func textFromImage(imgVal:UIImage){
        guard let cgImage = imgVal.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let size = CGSize(width: cgImage.width, height: cgImage.height)
            let bounds = CGRect(origin: .zero, size: size)
        let request = VNRecognizeTextRequest { [self] request, error in
                guard
                    let results = request.results as? [VNRecognizedTextObservation],
                    error == nil
                else { return }

                let rects = results.map {
                    convert(boundingBox: $0.boundingBox, to: CGRect(origin: .zero, size: size))
                }

                let string1 = results.compactMap {
                    $0.topCandidates(1).first?.string
                }.joined(separator: "\n")

                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                let final = UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
                    imgVal.draw(in: bounds)
                    UIColor.red.setStroke()
                    for rect in rects {
                        let path = UIBezierPath(rect: rect)
                        path.lineWidth = 5
                        path.stroke()
                    }
                }

                DispatchQueue.main.async { [self] in
                    image1.image = final
                }
            }
//        request.recognitionLevel = .accurate
//                request.recognitionLanguages = langCode
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try requestHandler.perform([request])
                } catch {
                    print("Failed to perform image request: \(error)")
                    return
                }
            }
        }

        /// Convert Vision coordinates to pixel coordinates within image.
        ///
        /// Adapted from `boundingBox` method from
        /// [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
        /// This flips the y-axis.
        ///
        /// - Parameters:
        ///   - boundingBox: The bounding box returned by Vision framework.
        ///   - bounds: The bounds within the image (in pixels, not points).
        ///
        /// - Returns: The bounding box in pixel coordinates, flipped vertically so 0,0 is in the upper left corner

        func convert(boundingBox: CGRect, to bounds: CGRect) -> CGRect {
            let imageWidth = bounds.width
            let imageHeight = bounds.height

            // Begin with input rect.
            var rect = boundingBox

            // Reposition origin.
            rect.origin.x *= imageWidth
            rect.origin.x += bounds.minX
            rect.origin.y = (1 - rect.maxY) * imageHeight + bounds.minY

            // Rescale normalized coordinates.
            rect.size.width *= imageWidth
            rect.size.height *= imageHeight

            return rect
        }

        ///  Scale and orient picture for Vision framework
        ///
        ///  From [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
        ///
        ///  - Parameter image: Any `UIImage` with any orientation
        ///  - Returns: An image that has been rotated such that it can be safely passed to Vision framework for detection.

        func scaleAndOrient(image: UIImage) -> UIImage {

            // Set a default value for limiting image size.
            let maxResolution: CGFloat = 640

            guard let cgImage = image.cgImage else {
                print("UIImage has no CGImage backing it!")
                return image
            }

            // Compute parameters for transform.
            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)
            var transform = CGAffineTransform.identity

            var bounds = CGRect(x: 0, y: 0, width: width, height: height)

            if width > maxResolution ||
                height > maxResolution {
                let ratio = width / height
                if width > height {
                    bounds.size.width = maxResolution
                    bounds.size.height = round(maxResolution / ratio)
                } else {
                    bounds.size.width = round(maxResolution * ratio)
                    bounds.size.height = maxResolution
                }
            }

            let scaleRatio = bounds.size.width / width
            let orientation = image.imageOrientation
            switch orientation {
            case .up:
                transform = .identity
            case .down:
                transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
            case .left:
                let boundsHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundsHeight
                transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
            case .right:
                let boundsHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundsHeight
                transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
            case .upMirrored:
                transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
            case .downMirrored:
                transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
            case .leftMirrored:
                let boundsHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundsHeight
                transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
            case .rightMirrored:
                let boundsHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundsHeight
                transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
            default:
                transform = .identity
            }

            return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
                let context = rendererContext.cgContext

                if orientation == .right || orientation == .left {
                    context.scaleBy(x: -scaleRatio, y: scaleRatio)
                    context.translateBy(x: -height, y: 0)
                } else {
                    context.scaleBy(x: scaleRatio, y: -scaleRatio)
                    context.translateBy(x: 0, y: -height)
                }
                context.concatenate(transform)
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        }
        
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else { return }
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
    }
    
    @IBAction func btnRetake(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDone(_ sender:UIButton){
        let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: CameraTranslationVC.className) as! CameraTranslationVC
        vc.img1 = image1.image ?? UIImage()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
