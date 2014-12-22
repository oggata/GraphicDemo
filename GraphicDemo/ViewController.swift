//
//  ViewController.swift
//  GraphicDemo
//
//  Created by Fumitoshi Ogata on 2014/12/16.
//  Copyright (c) 2014年 Fumitoshi Ogata. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imageViewにaddSubViewしたオブジェクトをタッチ可能にする
        //self.imageView.delaysContentTouches = true
        self.imageView.userInteractionEnabled = true
        // Do any additional setup after loading the view, typically from a nib.
/*
        var _planeImageView = UIImageView(image:UIImage(named:"plane.png"))
        _planeImageView.frame = CGRectMake(120*0,120*0,100,100)
        self.imageView.addSubview(_planeImageView)
        
        var _maskImageView = UIImageView(image:UIImage(named:"mask.png"))
        //_maskImageView.frame = CGRectMake(120*1,120*0,100,100)
        //self.imageView.addSubview(_maskImageView)
        
        var _masked = getMaskedImage(_planeImageView.image,maskImage:_maskImageView.image)
        var _maskedImage = UIImageView(image:_masked)
        _maskedImage.frame = CGRectMake(120*1,120*0,100,100)
        self.imageView.addSubview(_maskedImage)

        var _shadowedImage = UIImageView(image:self.getShadowedImage())
        _shadowedImage.frame = CGRectMake(120*2,120*0,100,100)
        self.imageView.addSubview(_shadowedImage)
        
        var _redRect = UIImageView(image:self.getRedRectImage())
        _redRect.frame = CGRectMake(120*0,120*1,100,100)
        self.imageView.addSubview(_redRect)
        
        var _redCirlce = UIImageView(image:self.getRedCircleImage())
        _redCirlce.frame = CGRectMake(120*1,120*1,100,100)
        self.imageView.addSubview(_redCirlce)
        
        var _uisigPath = UIImageView(image:self.getUsingPathImage())
        _uisigPath.frame = CGRectMake(120*2,120*1,100,100)
        self.imageView.addSubview(_uisigPath)
        
        var _evenOdd = UIImageView(image:self.getEvenOddImage())
        _evenOdd.frame = CGRectMake(120*0,120*2,100,100)
        self.imageView.addSubview(_evenOdd)
        
        var _bezierLine = UIImageView(image:self.getImageUsingBezier())
        _bezierLine.frame = CGRectMake(120*1,120*2,100,100)
        self.imageView.addSubview(_bezierLine)
        
        /*
        var _bezierFilled = UIImageView(image:getFilledImageUsingBezier())
        _bezierFilled.frame = CGRectMake(120*2,120*2,100,100)
        self.imageView.addSubview(_bezierFilled)
        */
        var _filledPath = UIImageView(image:getFilledImageUsingPath())
        _filledPath.frame = CGRectMake(120*2,120*2,100,100)
        self.imageView.addSubview(_filledPath)
        
        var _sepia = UIImageView(image:self.getSepiaFilterImage(
            _planeImageView,
            filterName:"CISepiaTone")
        )
        _sepia.frame = CGRectMake(120*0,120*3,100,100)
        self.imageView.addSubview(_sepia)
        
        var _instant = UIImageView(image:self.getSepiaFilterImage(
            _planeImageView,
            filterName:"CIPhotoEffectInstant")
        )
        _instant.frame = CGRectMake(120*1,120*3,100,100)
        self.imageView.addSubview(_instant)
        
        var _transfer = UIImageView(image:self.getSepiaFilterImage(
            _planeImageView,
            filterName:"CIPhotoEffectTransfer")
        )
        _transfer.frame = CGRectMake(120*2,120*3,100,100)
        self.imageView.addSubview(_transfer)

        var _drawView = CanvasView(frame:CGRectMake(120*0,120*4,100,100))
        _drawView.backgroundColor = UIColor.clearColor()
        self.imageView.addSubview(_drawView)
        
        var _drawView2 = CanvasView(frame:CGRectMake(120*1,120*4,100,100))
        _drawView2.backgroundColor = UIColor.clearColor()
        self.imageView.addSubview(_drawView2)
*/
        var _drawView3 = CanvasView(frame:CGRectMake(0,0,300,300))
        _drawView3.backgroundColor = UIColor.clearColor()
        self.imageView.addSubview(_drawView3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //赤色の矩形
    func getRedRectImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100),false,0.0);
        var _context : CGContextRef = UIGraphicsGetCurrentContext();
        CGContextSetRGBStrokeColor(_context,1,0,0,1);
        CGContextStrokeRectWithWidth(_context,CGRectMake(0,0,100,100),5);
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return _uiImage
    }
    
    //赤色の円
    func getRedCircleImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100),false,0.0)
        var _context : CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(_context,UIColor(red:1,green:0,blue:0,alpha:1).CGColor)
        CGContextFillEllipseInRect(_context,CGRectMake(0,0,100,100))
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();        
        return _uiImage
    }
    
    //パスを使った描画
    func getUsingPathImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(300,300),false, 0.0)
        var _context : CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(_context,0,1,0,1)
        CGContextSetRGBStrokeColor(_context,0,0,0,1)
        //楕円形パスを追加
        CGContextAddEllipseInRect(_context,CGRectMake(40,40,240,240))
        //楕円形を枠線のみにしたい場合は下記+
        CGContextReplacePathWithStrokedPath(_context)
        //四角形パスを追加
        CGContextMoveToPoint(_context,60,240)
        CGContextAddLineToPoint(_context,60,60)
        CGContextAddLineToPoint(_context,260,60)
        CGContextAddLineToPoint(_context,260,260)
        CGContextClosePath(_context)
        //枠線と塗りつぶし
        CGContextDrawPath(_context,kCGPathFillStroke)
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();        
        return _uiImage
    }
    
    //EvenOddで合成した画像を作成する
    func getEvenOddImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(300,300),false, 0.0)
        var _context : CGContextRef = UIGraphicsGetCurrentContext()
        CGContextAddEllipseInRect(_context,CGRectMake(60,60,200,200))
        CGContextAddEllipseInRect(_context,CGRectMake(40,120,100,100))
        CGContextDrawPath(_context,kCGPathEOFill)
        
        CGContextClosePath(_context)
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();        
        return _uiImage
    }

    //ベジェ曲線を使う(塗りつぶさない)
    func getImageUsingBezier() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(300,300),false, 0.0)
        var _context : CGContextRef = UIGraphicsGetCurrentContext()

        //1
        CGContextMoveToPoint(_context,20,240)
        CGContextAddQuadCurveToPoint(_context,60,80,300,200)
        
        //2
        //CGContextMoveToPoint(_context,20,240)
        //CGContextAddCurveToPoint(_context,60,80,260,100,300,200)
    
        //塗りつぶしたい場合はReplacePathWithStrokedPathをコメントアウト
        CGContextReplacePathWithStrokedPath(_context)
        CGContextDrawPath(_context,kCGPathFillStroke)
        
        CGContextClosePath(_context)
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();        
        return _uiImage
    }

    //ベジェ曲線を使う(塗りつぶし)
    func getFilledImageUsingBezier() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(300,300),false, 0.0)
        var _context : CGContextRef = UIGraphicsGetCurrentContext()
        
        //1
        CGContextMoveToPoint(_context,20,240)
        CGContextAddQuadCurveToPoint(_context,60,80,300,200)
        
        //2
        //CGContextMoveToPoint(_context,20,240)
        //CGContextAddCurveToPoint(_context,60,80,260,100,300,200)
        
        //塗りつぶしたい場合はReplacePathWithStrokedPathをコメントアウト
        CGContextDrawPath(_context,kCGPathFillStroke)
        
        CGContextClosePath(_context)
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();        
        return _uiImage
    }
    
    //パスを使う(塗りつぶし)
    func getFilledImageUsingPath() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(300,300),false, 0.0)
        var _context : CGContextRef = UIGraphicsGetCurrentContext()
                
        CGContextSetRGBFillColor(_context,1,1,0,1)
        CGContextSetRGBStrokeColor(_context,1,0,1,1)
        CGContextSetLineWidth(_context,10)
        
        var _path :CGMutablePathRef =  CGPathCreateMutable()
        CGPathMoveToPoint(_path,nil,160,100)
        CGPathAddLineToPoint(_path,nil,260,200)
        CGPathAddLineToPoint(_path,nil,60,200)
        CGPathAddLineToPoint(_path,nil,160,100)
        CGPathCloseSubpath(_path)
        
        CGContextAddPath(_context,_path)
        //CGPathRelease(_path)
        
        CGContextDrawPath(_context,kCGPathFillStroke)
        
        CGContextClosePath(_context)
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();        
        return _uiImage
    }
    
    //マスクされた画像を作成
    func getMaskedImage(originalImage:UIImage!,maskImage:UIImage!) -> UIImage {        
        let maskImageReference:CGImage? = maskImage?.CGImage
        let mask = CGImageMaskCreate(CGImageGetWidth(maskImageReference),
            CGImageGetHeight(maskImageReference),
            CGImageGetBitsPerComponent(maskImageReference),
            CGImageGetBitsPerPixel(maskImageReference),
            CGImageGetBytesPerRow(maskImageReference),
            CGImageGetDataProvider(maskImageReference),nil,false)
        let maskedImageReference = CGImageCreateWithMask(originalImage?.CGImage, mask)
        let maskedImage = UIImage(CGImage: maskedImageReference)
        return maskedImage!
    }
    
    //影を付ける
    func getShadowedImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100),false,0.0)
        var _context : CGContextRef = UIGraphicsGetCurrentContext()
        //画像の右下8の方向に影を描画する
        CGContextSetShadowWithColor(
            _context,
            CGSizeMake(6,6),
            8,
            UIColor(red:0,green:0,blue:0,alpha:1).CGColor
        )
        CGContextDrawImage(
            _context,
            CGRectMake(0,0,80,80),
            UIImage(named:"plane.png")?.CGImage
        )
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();        
        return _uiImage
    }
    
    //画像にフィルターをかける
    func getSepiaFilterImage(baseImage:UIImageView,filterName:String) -> UIImage?{
        var filter = CIFilter(name:filterName)
        var unfilteredImage = CIImage(CGImage:baseImage.image?.CGImage)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        var context = CIContext(options: nil)
        var filteredImage: CIImage = filter.outputImage
        var extent = filteredImage.extent()
        var cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        var finalImage = UIImage(CGImage: cgImage)
        return finalImage
    }
    
    
    
    
    
}

