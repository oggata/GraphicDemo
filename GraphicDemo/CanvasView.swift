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
    var drawImage : UIImage!
    var baseImageView : UIImageView!
    var drawImageView : UIImageView!
    
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
        
        self.baseImage = UIImage(named:"plane.png")
        self.baseImageView = UIImageView(image:self.baseImage)
        self.baseImageView.frame = CGRect(
            x:0,
            y:0,
            width:frame.size.width,
            height:frame.size.height
        )
        self.addSubview(self.baseImageView)
        
        //self.drawImage = self.getBlankUIImage()
        self.drawImage = UIImage(named:"black.png")
        self.drawImageView = UIImageView(image:self.drawImage)
        //読み込み画像を表示領域にあわせる必要がある
        self.drawImageView.frame = CGRect(
            x:0,
            y:0,
            width:frame.size.width,
            height:frame.size.height
        )
        self.addSubview(self.drawImageView)
self.drawImageView.hidden = true
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
println(_uiColor)
        
        /*
        var testImage = UIImageView(image:self.getRedCircleImage(_uiColor!))
        //読み込み画像を表示領域にあわせる必要がある
        testImage.frame = CGRectMake(0,0,50,50)
        self.addSubview(testImage)
        */
        
        
        //タッチした先の色の箇所を全走査する
        self.baseImage?.fitnessBetweenImages(_uiColor!)
        //self.baseImage?.fitnessBetweenImages(UIColor.redColor())
        
        //var _rgb = _uiColor?.getRGB().red
        //println(_rgb)
    
        //全走査した箇所でhitした分を全部drawImageに白で塗りつぶす
        self.newMaskImage = self.baseImage?.getMaskImageFromTappedColor(_uiColor!)
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
        
        
        self.drawImage = self.drawImage?.drawPathsWithOption(
            self.frame,
            paths:self.paths,
            drawWidth:10,
            drawCGColor:UIColor(red:1,green:1,blue:1,alpha:1).CGColor
        )        
        self.drawImageView.image = self.drawImage
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
            maskImage:self.drawImage)
        */
        
        self.baseImageView.image = self.newMaskImage
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