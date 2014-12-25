//
//  Extension.swift
//  GraphicDemo
//
//  Created by Fumitoshi Ogata on 2014/12/16.
//  Copyright (c) 2014年 Fumitoshi Ogata. All rights reserved.
//

import UIKit

extension UIColor {

    //明るさを取得
    func getBrightness() -> CGFloat{
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        var _r = 77 * r * 255
        var _g = 28 * g * 255
        var _b = 151 * b * 255
        return CGFloat((_r+_g+_b)/256)
    }
    
    //RGBを取得
    func getRGB() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (red: (r * 255.0), green: (g * 255.0), blue: (b * 255.0), alpha: a)
    }
    
    //２つの色がほぼ同じならtrue
    func isAlmostSameColor(firstColor:UIColor,secondColor:UIColor) -> Bool{
        var _firstColorRGB = firstColor.getRGB()
        for _r in 1...3 {
            var _rangeR = _firstColorRGB.red - CGFloat(_r-2)
            for _g in 1...3 {
                var _rangeG = _firstColorRGB.green - CGFloat(_g-2)
                for _b in 1...3 {
                    var _rangeB = _firstColorRGB.blue - CGFloat(_b-2)
                    var _color = UIColor(
                        red:_rangeR/255,
                        green:_rangeG/255,
                        blue:_rangeB/255,
                        alpha:1
                    )
                    if(_color == secondColor){
                        return true
                    }
                }
            }
        }
        return false
    }
}

extension UIImage {
    
    //人物切り抜きフィルタ
    func getKirinuki() -> UIImage {
        var _rtnImage : UIImage!
        var _maskImage : UIImage!
        //1.base画像の色を濃くしたものをmask画像に設定
        _maskImage = self.getColorControlsFilterImage()
        
        //2.二値化画像をmask画像に設定する
        _maskImage = _maskImage.getThresholdingImage(0)
        
        //3.base画像とmask画像を合成させて、base画像に出力する
        _rtnImage = self.getMaskedImage(_maskImage)

        return _rtnImage
    }
    
    
    //影を付ける
    func getShadowedImage() -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width + 50,self.size.height + 50),false,0.0)
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
            CGRectMake(0,0,self.size.width,self.size.height),
            self.CGImage
        )
        var _uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();        
        return _uiImage
    }
    
    //画像にフィルターをかける
    func getFilteredImage(filterName:String) -> UIImage?{
        var filter = CIFilter(name:filterName)
        var unfilteredImage = CoreImage.CIImage(CGImage:self.CGImage)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        var context = CIContext(options: nil)
        var filteredImage: CoreImage.CIImage = filter.outputImage
        var extent = filteredImage.extent()
        var cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        var finalImage = UIImage(CGImage: cgImage)
        return finalImage
    }
    
    //マスクされた画像を作成
    func getMaskedImage(maskImage:UIImage!) -> UIImage {        
        let maskImageReference:CoreImage.CGImage? = maskImage?.CGImage
        let mask = CGImageMaskCreate(CGImageGetWidth(maskImageReference),
            CGImageGetHeight(maskImageReference),
            CGImageGetBitsPerComponent(maskImageReference),
            CGImageGetBitsPerPixel(maskImageReference),
            CGImageGetBytesPerRow(maskImageReference),
            CGImageGetDataProvider(maskImageReference),nil,false)
        let maskedImageReference = CGImageCreateWithMask(self.CGImage, mask)
        let maskedImage = UIImage(CGImage: maskedImageReference)
        return maskedImage!
    }
    
    //カラーコントロールフィルタで画像変換
    func getColorControlsFilterImage()-> UIImage?{
        var filter = CIFilter(name:"CIColorControls")
        filter.setValue(3.4, forKey: "inputSaturation")
        filter.setValue(0.6, forKey: "inputBrightness")
        filter.setValue(3.0, forKey: "inputContrast")
        var unfilteredImage = CoreImage.CIImage(CGImage:self.CGImage)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        var context = CIContext(options: nil)
        var filteredImage: CoreImage.CIImage = filter.outputImage
        var extent = filteredImage.extent()
        var cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        var finalImage = UIImage(CGImage: cgImage)
        return finalImage
    }
    
    //モノクロームフィルタで画像変換
    func getMonochromeFilterImage(baseImage:UIImageView)->UIImage?{
        var filter = CIFilter(name:"CIColorMonochrome")
        //filter.setValue(CIColor(red:0, green:0, blue:0),forKey:kCIInputColorKey)
        filter.setValue(CGFloat(0.8),forKey: kCIInputIntensityKey)
        var unfilteredImage = CoreImage.CIImage(CGImage:self.CGImage)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        var context = CIContext(options: nil)
        var filteredImage: CoreImage.CIImage = filter.outputImage
        var extent = filteredImage.extent()
        var cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        var finalImage = UIImage(CGImage: cgImage)
        return finalImage
    }
    
    //トーンカーブフィルタで画像変換
    func getToneCurveFilterImage()->UIImage?{
        var filter = CIFilter(name:"CIToneCurve")
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0.0, y: 0.0), forKey: "inputPoint0")
        filter.setValue(CIVector(x: 0.25, y: 0.1), forKey: "inputPoint1")
        filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
        filter.setValue(CIVector(x: 0.75, y: 0.9), forKey: "inputPoint3")
        filter.setValue(CIVector(x: 1.0, y: 1.0), forKey: "inputPoint4")
        var unfilteredImage = CoreImage.CIImage(CGImage:self.CGImage)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        var context = CIContext(options: nil)
        var filteredImage: CoreImage.CIImage = filter.outputImage
        var extent = filteredImage.extent()
        var cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        var finalImage = UIImage(CGImage: cgImage)
        return finalImage
    }
    
    //二値化したが画像を取得する
    func getThresholdingImage(inputThreshold : CGFloat ) -> UIImage?{
        var _width = Int(self.size.width)
        var _height = Int(self.size.height)
        var _imageData = self.imageData()
        var imageBytes : UnsafeMutablePointer<Byte>;
        let newByteLength = _width * _height * 4
        imageBytes = UnsafeMutablePointer<Byte>.alloc(newByteLength)
        
        var _threshold = inputThreshold
        if(inputThreshold == 0){
            //入力値が0のときは敷居値を平均から決める
            var _brightnessPrameter : CGFloat = 0
            var _cnt : CGFloat = 0
            for x in 0..<_width {
                for y in 0..<_height {
                    var point = (x, y)
                    var color = UIImage.colorAtPoint(
                        point,
                        imageWidth: _width,
                        withData: _imageData
                    )
                    _brightnessPrameter += color.getBrightness()
                    _cnt++
                }
            }
            _threshold = CGFloat(_brightnessPrameter / _cnt)
        }

        //敷居値の平均から、上の場合は白、下の場合は黒に振り分ける
        for x in 0..<_width {
            for y in 0..<_height {
                var point = (x, y)
                var color = UIImage.colorAtPoint(
                    point,
                    imageWidth: _width,
                    withData: _imageData
                )
                var i: Int = ((Int(_width) * Int(y)) + Int(x)) * 4
                
                if(color.getBrightness() >= _threshold){
                    imageBytes[i] = Byte(255) // red
                    imageBytes[i+1] = Byte(255); // green
                    imageBytes[i+2] = Byte(255); // blue
                    imageBytes[i+3] = Byte(255); // alpha
                }else{
                    imageBytes[i] = Byte(0) // red
                    imageBytes[i+1] = Byte(0); // green
                    imageBytes[i+2] = Byte(0); // blue
                    imageBytes[i+3] = Byte(255); // alpha
                }
            }
        } 
        var provider = CGDataProviderCreateWithData(nil,imageBytes, UInt(newByteLength), nil)
        var bitsPerComponent:UInt = 8
        var bitsPerPixel:UInt = bitsPerComponent * 4
        var bytesPerRow:UInt = UInt(4) * UInt(_width)
        var colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGBitmapInfo.ByteOrderDefault
        var renderingIntent = kCGRenderingIntentDefault
        // make the cgimage
        var cgImage = CGImageCreate(UInt(_width), UInt(_height), bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, nil, false, renderingIntent)
        return UIImage(CGImage: cgImage)
    }
    
    //入力した色と同じ色を白に塗りつぶす
    func getMaskImageFromTappedColor(_tColor:UIColor) -> UIImage? {
        var _image = self
        var _width = Int(_image.size.width)
        var _height = Int(_image.size.height)
        var _imageData = _image.imageData()
        var imageBytes : UnsafeMutablePointer<Byte>;
        let newByteLength = _width * _height * 4
        imageBytes = UnsafeMutablePointer<Byte>.alloc(newByteLength)
        var _cnt = 0;
        for x in 0..<_width {
            for y in 0..<_height {
                var point = (x, y)
                var color = UIImage.colorAtPoint(
                    point,
                    imageWidth: _width,
                    withData: _imageData
                )
                var i: Int = ((Int(_width) * Int(y)) + Int(x)) * 4
                /*
                var _isOK = _tColor.isAlmostSameColor(_tColor,secondColor:color)
                if(_isOK == true){
                    imageBytes[i] = Byte(255) // red
                    imageBytes[i+1] = Byte(255); // green
                    imageBytes[i+2] = Byte(255); // blue
                    imageBytes[i+3] = Byte(255); // alpha
                }else{
                    imageBytes[i]   = Byte(color.getRGB().red) // red
                    imageBytes[i+1] = Byte(color.getRGB().green); // green
                    imageBytes[i+2] = Byte(color.getRGB().blue); // blue
                    imageBytes[i+3] = Byte(255); // alpha
                }*/
                if(color == _tColor){
                    imageBytes[i] = Byte(255) // red
                    imageBytes[i+1] = Byte(255); // green
                    imageBytes[i+2] = Byte(255); // blue
                    imageBytes[i+3] = Byte(255); // alpha
                }else{
                    imageBytes[i]   = Byte(color.getRGB().red) // red
                    imageBytes[i+1] = Byte(color.getRGB().green); // green
                    imageBytes[i+2] = Byte(color.getRGB().blue); // blue
                    imageBytes[i+3] = Byte(255); // alpha
                }
            }
        } 
        var provider = CGDataProviderCreateWithData(nil,imageBytes, UInt(newByteLength), nil)
        var bitsPerComponent:UInt = 8
        var bitsPerPixel:UInt = bitsPerComponent * 4
        var bytesPerRow:UInt = UInt(4) * UInt(_width)
        var colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGBitmapInfo.ByteOrderDefault
        var renderingIntent = kCGRenderingIntentDefault
        // make the cgimage
        var cgImage = CGImageCreate(UInt(_width), UInt(_height), bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, nil, false, renderingIntent)
        return UIImage(CGImage: cgImage)
    }
    
    func imageFromSceneKitViewOriginal(bytes: UnsafeMutablePointer<Byte>) -> UIImage? {
        var imageBytes : UnsafeMutablePointer<Byte>;
        imageBytes = nil;
        //var w:UInt = UInt(sceneKitView.bounds.size.width * UIScreen.mainScreen().scale)
        //var h:UInt = UInt(sceneKitView.bounds.size.height * UIScreen.mainScreen().scale)
        var w:UInt = 10
        var h:UInt = 10
        
        let myDataLength:UInt = w * h * UInt(4)
        //var bytes = UnsafeMutablePointer<CGFloat>(calloc(myDataLength, UInt(sizeof(CUnsignedChar))))
        //glReadPixels(0, 0, GLint(w), GLint(h), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), bytes)
        
        var provider = CGDataProviderCreateWithData(nil, bytes, UInt(myDataLength), nil)
        var bitsPerComponent:UInt = 8
        var bitsPerPixel:UInt = 32
        var bytesPerRow:UInt = UInt(4) * UInt(w)
        var colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGBitmapInfo.ByteOrderDefault
        var renderingIntent = kCGRenderingIntentDefault
        
        // make the cgimage
        var cgImage = CGImageCreate(UInt(w), UInt(h), bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, nil, false, renderingIntent)
        return UIImage(CGImage: cgImage)
    }
    
    //特定した場所のピクセル色を取得する
    class func colorAtPoint(point:(x:Int,y: Int),imageWidth: Int,withData data: UnsafePointer<UInt8>) -> UIColor {
        let offset = 4 * ((imageWidth * point.y) + point.x)
        var r = CGFloat(data[offset])
        var g = CGFloat(data[offset + 1])
        var b = CGFloat(data[offset + 2])
        //return (red: r, green: g, blue: b)
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    //スケールした画像を取得する
    func scaleToSize(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize,false, 0.0)
        drawInRect(CGRectMake(0, 0, toSize.width, toSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func imageData() -> UnsafePointer<UInt8> {
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        return CFDataGetBytePtr(pixelData)
    }    

    func getPixelColor(pos: CGPoint) -> UIColor {        
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        var r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        var g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        var b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        var a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func fitnessBetweenImages(_tColor:UIColor) -> Void {
        var _image = self
        var _imageSize = _image.size
        var _width = Int(_imageSize.width)
        var _height = Int(_imageSize.height)
        var _imageData = _image.imageData()
        var _cnt = 0
        for x in 0..<_width {
            for y in 0..<_height {
                var point = (x, y)
                var color = UIImage.colorAtPoint(
                    point,
                    imageWidth: _width,
                    withData: _imageData
                )
                if(color == _tColor){
                    println("atari!")
                }
                _cnt++
            }
        }
        //println(_cnt)
    }

    func drawPaths(frame:CGRect,paths:[Path]) -> UIImage{
        var frame:CGRect = CGRect(
            x:0,
            y:0,
            width:frame.size.width,
            height:frame.size.height
        )
        UIGraphicsBeginImageContextWithOptions(frame.size,false, 0.0)
        //既にある画像を表示する
        drawInRect(
            CGRectMake(
                0,
                0,
                frame.size.width,
                frame.size.height
            )
        )
        let context = UIGraphicsGetCurrentContext()
        //塗りつぶし
        //var rect : CGRect = CGRectMake(0,0,300,300);
        //CGContextSetFillColorWithColor(context,UIColor.whiteColor().CGColor);
        //CGContextFillRect(context,rect);
        for path in paths {
            let points = path.points
            for i in 0..<points.count-1 {
                let p1 = points[i]
                let p2 = points[i+1]
                /*
                // 線の描画開始座標をセット
                CGContextMoveToPoint(context, p1.x, p1.y)
                // 線の描画終了座標をセット
                CGContextAddLineToPoint(context, p2.x, p2.y)
                */
                // 線の描画開始座標をセット
                CGContextMoveToPoint(
                    context,
                    p1.x - frame.origin.x,
                    p1.y - frame.origin.y
                )
                // 線の描画終了座標をセット
                CGContextAddLineToPoint(
                    context,
                    p2.x - frame.origin.x,
                    p2.y - frame.origin.y
                )
            }
            
            //線の太さを指定
            CGContextSetLineWidth(context,5)
            
            //線の色を指定
            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
            /*
            //線の色を指定
            CGContextSetFillColorWithColor(
                context,
                UIColor(red: 1, green: 0, blue: 0, alpha: 1).CGColor
            )*/
            //終端の形を指定(丸) //kCGLineCapRound	丸 | kCGLineCapButt 四角 | kCGLineCapSquare 四角くっつける
            CGContextSetLineCap(context, kCGLineCapRound);
            // 描画の開始～終了座標まで線を引く
            CGContextStrokePath(context)
        }
        let currentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return currentImage
    }

    func drawPathsWithOption(frame:CGRect,paths:[Path],drawWidth:Int,drawCGColor:CGColor) -> UIImage{
        var frame:CGRect = CGRect(
            x:0,
            y:0,
            width:frame.size.width,
            height:frame.size.height
        )
        UIGraphicsBeginImageContextWithOptions(frame.size,false,0.0)
        //既にある画像を表示する
        drawInRect(CGRectMake(0,0,frame.size.width,frame.size.height)
        )
        let context = UIGraphicsGetCurrentContext()
        for path in paths {
            let points = path.points
            for i in 0..<points.count-1 {
                let p1 = points[i]
                let p2 = points[i+1]
                // 線の描画開始座標をセット
                CGContextMoveToPoint(
                    context,
                    p1.x - frame.origin.x,
                    p1.y - frame.origin.y
                )
                // 線の描画終了座標をセット
                CGContextAddLineToPoint(
                    context,
                    p2.x - frame.origin.x,
                    p2.y - frame.origin.y
                )
            }
            //線の太さを指定
            CGContextSetLineWidth(context,CGFloat(drawWidth))
            //線の色を指定
            CGContextSetStrokeColorWithColor(
                context,
                drawCGColor
            )
            CGContextSetLineCap(context, kCGLineCapRound);
            // 描画の開始～終了座標まで線を引く
            CGContextStrokePath(context)
        }
        //CGContextDrawPath(context,kCGPathFillStroke)
        
        let currentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return currentImage
    }
}

