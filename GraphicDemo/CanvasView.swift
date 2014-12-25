//
//  CanvasView.swift
//  GraphicDemo
//
//  Created by Fumitoshi Ogata on 2014/12/16.
//  Copyright (c) 2014年 Fumitoshi Ogata. All rights reserved.
//
import UIKit

class CanvasView: UIView {
    
    var baseImage : UIImage!
    var maskImage : UIImage!
    var baseImageView : UIImageView!
    var maskImageView : UIImageView!
    
    var newMaskImage : UIImage!
    
    var paths: [Path] = []
    private var currentPath: Path?
    
    // MARK: - init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var gesture: UIPinchGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //写真を表示するUIImageをaddする
        self.baseImage = UIImage(named:"plane.png") 
        //self.baseImage = UIImage(named:"test_color.png")
        var bFrame = CGSizeMake(frame.size.width,frame.size.height)
        //self.baseImage = self.baseImage.scaleToSize(bFrame)        
        self.baseImageView = UIImageView(image:self.baseImage)
        self.baseImageView.frame = CGRect(
            x:0,
            y:0,
            width:self.baseImage.size.width,
            height:self.baseImage.size.height
        )
        self.addSubview(self.baseImageView)
        

        //マスクするためのUIImageをaddする
        self.maskImage = UIImage(named:"black.png")
        self.maskImageView = UIImageView(image:self.maskImage)
        //読み込み画像を表示領域にあわせる必要がある
        self.maskImageView.frame = CGRect(
            x:0,
            y:0,
            width:frame.size.width,
            height:frame.size.height
        )
        self.addSubview(self.maskImageView)
        self.maskImageView.hidden = true
        self.maskImageView.userInteractionEnabled = false
    }
    
    func setImage(image: UIImage){
        self.baseImage = image
        self.baseImageView.image = self.baseImage
        self.baseImageView.frame = CGRect(
            x:0,
            y:0,
            width:self.baseImage.size.width,
            height:self.baseImage.size.height
        )
    }

    //赤色の円
    func getRedCircleImage(tColor:UIColor) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100),false,0.0)
        var _context : CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(_context,tColor.CGColor)
        CGContextFillEllipseInRect(_context,CGRectMake(0,0,100,100))
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();        
        return _uiImage
    }
    
    // MARK: - タッチ開始時の入力制御
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let t = touches.anyObject() as UITouch
        let point = t.locationInView(self)
        println("touchBegan")
        self.paths = []
        self.currentPath = Path()
        paths.append(currentPath!)
        addToPath(touches)

        //タッチした先の色を取得する
        var _cgPoint : CGPoint = CGPointMake(point.x,point.y)        
        var _uiColor : UIColor? = self.baseImage?.getPixelColor(_cgPoint)
        //var testImage = UIImageView(image:self.getRedCircleImage(_uiColor!))
        //読み込み画像を表示領域にあわせる必要がある
        //testImage.frame = CGRectMake(300,0,50,50)
        //self.addSubview(testImage)
                
        //タッチした先の色の箇所を全走査して、
        //self.baseImage?.fitnessBetweenImages(_uiColor!)
    
        //全走査した箇所でhitした分を全部drawImageに白で塗りつぶす
        self.baseImage = self.baseImage?.getMaskImageFromTappedColor(_uiColor!)
        self.baseImageView.image = self.baseImage
        //self.baseImageView.image = self.maskImage
        /*
        self.baseImage.isAlmostSameColor(
            UIColor(red:1,green:1,blue:1,alpha:1),
            secondColor:UIColor(red:1,green:1,blue:1,alpha:1)
        )*/
    }
    
    // MARK: - タッチ移動時の入力制御
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)  {
        let t = touches.anyObject() as UITouch
        let point = t.locationInView(self)
        println("touchMove")
        

        addToPath(touches)
        self.setNeedsDisplay()
    
        /*
        //線を描く
        self.drawImage = self.drawImage?.drawPaths(
            self.frame,
            paths:self.paths
        )*/
        self.maskImage = self.maskImage?.drawPathsWithOption(
            self.frame,
            paths:self.paths,
            drawWidth:10,
            drawCGColor:UIColor(red:1,green:1,blue:1,alpha:1).CGColor
        )
        self.maskImageView.image = self.maskImage
    }
    
    // MARK: - タッチ終了時の入力制御
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
println("touchEnd")
        self.currentPath = nil
        self.paths = []
        /*
        self.baseImageView.image = self.getMaskedImage(
            UIImage(named:"plane.png"),
            maskImage:UIImage(named:"white.png"))
        */
        
        /*
        self.baseImageView.image = self.getMaskedImage(
            UIImage(named:"plane.png"),
            maskImage:self.maskImage)
        */
        
        //self.baseImageView.image = self.newMaskImage
        //self.drawImageView = UIImageView(image:self.drawImage)
    }

    private func addToPath(touches: NSSet) {
        let t = touches.anyObject() as UITouch
        let point = t.locationInView(self)
        self.currentPath!.add(point)
    }
    
    func clear() {
        self.paths = []
        self.setNeedsDisplay()
    }
    
    func getBlankUIImage()->UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100),false,0.0);
        var image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
    
    //マスクされた画像を作成
    func getMaskedImage(originalImage:UIImage!,maskImage:UIImage!) -> UIImage {
        
        //precondition(originalImage.size == maskImage.size, "Images must have the same size")
        //precondition(originalImage.scale == maskImage.scale, "Images must have the same scale")
        
        let maskImageReference:CGImage? = maskImage?.CGImage
        let mask = CGImageMaskCreate(CGImageGetWidth(maskImageReference),
            CGImageGetHeight(maskImageReference),
            CGImageGetBitsPerComponent(maskImageReference),
            CGImageGetBitsPerPixel(maskImageReference),
            CGImageGetBytesPerRow(maskImageReference),
            CGImageGetDataProvider(maskImageReference), nil, false)
        let maskedImageReference = CGImageCreateWithMask(originalImage?.CGImage, mask)
        let maskedImage = UIImage(CGImage: maskedImageReference)
        return maskedImage!
    }
}


class Path {
    var points: [CGPoint] = []
    var color: UIColor
    init() {
        //self.color = color
        self.color = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    }
    
    func add(point: CGPoint) {
        points.append(point)
    }
}
