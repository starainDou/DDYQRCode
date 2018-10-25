#import "DDYQRCodeManager.h"

@import CoreImage;
@import AssetsLibrary;  // 相册 iOS 6-9
@import Photos;         // 相册 iOS 8+

@interface DDYQRCodeManager ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
/** 捕获会话 */
@property (nonatomic, strong) AVCaptureSession *captureSession;
/** 元数据输出 */
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
/** 预览层 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation DDYQRCodeManager

NSErrorDomain DDYQRError = @"DDYQRError";

#pragma mark - 鉴定权限
#pragma mark 相机使用权限鉴定
+ (void)cameraAuthSuccess:(void (^)(void))success fail:(void (^)(void))fail
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus)
    {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted && success) success();
                    if (!granted && fail) fail();
                });
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            dispatch_async(dispatch_get_main_queue(), ^{ if (fail) fail(); });
        }
            break;
        case AVAuthorizationStatusAuthorized:
            dispatch_async(dispatch_get_main_queue(), ^{ if (success) success(); });
            break;
    }
}

#pragma mark 相册使用权限鉴定
+ (void)albumAuthSuccess:(void (^)(void))success fail:(void (^)(void))fail {
    //    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus]; // 6-9
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];    // 8+
    switch (authStatus)
    {
        case AVAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PHAuthorizationStatusAuthorized && success) success();
                    if (status != PHAuthorizationStatusAuthorized && fail) fail();
                });
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            dispatch_async(dispatch_get_main_queue(), ^{ if (fail) fail(); });
        }
            break;
        case AVAuthorizationStatusAuthorized:
            dispatch_async(dispatch_get_main_queue(), ^{ if (success) success(); });
            break;
    }
}

#pragma mark - 私有方法
#pragma mark 生成原始条形码
+ (CIImage *)generateOriginalBarCodeWithString:(NSString *)string
{
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setValue:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    [filter setValue:@(0.00) forKey:@"inputQuietSpace"];  // 上下左右的margin
    return [filter outputImage];
}

#pragma mark 生成原始二维码
+ (CIImage *)generateOriginalQRCodeWithString:(NSString *)string
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:[string dataUsingEncoding:NSUTF8StringEncoding] forKeyPath:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    return [filter outputImage];
}

#pragma mark 改变前景和背景色
+ (CIImage *)changeColor:(CIImage *)image color:(UIColor *)color bgColor:(UIColor *)bgColor
{
    CIFilter *filter = [CIFilter filterWithName:@"CIFalseColor"];
    [filter setDefaults];
    [filter setValue:image forKey:@"inputImage"];
    [filter setValue:[CIColor colorWithCGColor:bgColor.CGColor] forKey:@"inputColor0"];
    [filter setValue:[CIColor colorWithCGColor:color.CGColor] forKey:@"inputColor1"];
    return [filter outputImage];
}

#pragma mark 改变宽高
+ (UIImage *)changeSizeWithCIImage:(CIImage *)image resultSize:(CGSize)resultSize
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(resultSize.width/CGRectGetWidth(extent), resultSize.height/CGRectGetHeight(extent));
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contentRef = CGBitmapContextCreate(nil, resultSize.width, resultSize.height, 8, 0, colorSpaceRef, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipLast);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
    CGContextScaleCTM(contentRef, scale, scale);
    CGContextDrawImage(contentRef, extent, imageRef);
    CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
    CGContextRelease(contentRef);
    CGImageRelease(imageRef);
    return [UIImage imageWithCGImage:imageRefResized];
}

#pragma mark 添加logo
+ (UIImage *)addLogo:(UIImage *)logo toQRImage:(UIImage *)image logoScale:(CGFloat)logoScale
{
    CGFloat scale = logoScale>0 ? (logoScale<0.3?logoScale:0.3) : 0.25;
    CGFloat logoW = image.size.width * scale;
    CGFloat logoX = (image.size.width-logoW)/2.0;
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [logo drawInRect:CGRectMake(logoX, logoX, logoW, logoW)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}


#pragma mark 将CIImage转成CGImage
+ (CGImageRef)convertCIImageToCGImage:(CIImage *)image
{
    CGRect extent = CGRectIntegral(image.extent);
    
    size_t width = CGRectGetWidth(extent);
    size_t height = CGRectGetHeight(extent);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, 1, 1);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return scaledImage;
}

#pragma mark 将原始图片的所有点的色值保存到二维数组
+ (NSArray <NSArray *>*)getPixelsWithImage:(CGImageRef)image
{
    CGFloat width = CGImageGetWidth(image);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *)calloc(width*width*4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = width*bytesPerPixel;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, width, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, width), image);
    CGContextRelease(context);
    
    NSMutableArray *pixels = [NSMutableArray array];
    for (int y = 0; y < width; y++) {
        NSMutableArray *array = [NSMutableArray array];
        for (int x = 0; x < width; x++) {
            @autoreleasepool {
                NSUInteger byteIndex = bytesPerRow*y + bytesPerPixel*x;
                CGFloat r = (CGFloat)rawData[byteIndex];
                CGFloat g = (CGFloat)rawData[byteIndex + 1];
                CGFloat b = (CGFloat)rawData[byteIndex + 2];
                BOOL display = (r==0 && g==0 && b==0);
                [array addObject:@(display)];
                byteIndex += bytesPerPixel;
            }
        }
        [pixels addObject:[array copy]];
    }
    free(rawData);
    return [pixels copy];
}

#pragma mark 根据像素点数组绘制相应属性的图片
+ (UIImage *)drawWithPoints:(NSArray <NSArray *>*)points
             widthAndHeight:(CGFloat)widthAndHeight
                     colors:(NSArray <UIColor *>*)colors
                       type:(DDYQRCodeGradientType)type
{
    CGFloat delta = widthAndHeight/points.count;
    UIGraphicsBeginImageContext(CGSizeMake(widthAndHeight, widthAndHeight));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (int y = 0; y < points.count; y++) {
        for (int x = 0; x < points[y].count; x++) {
            if ([points[y][x] boolValue]) {
                CGFloat centerX = x*delta + 0.5*delta;
                CGFloat centerY = y*delta + 0.5*delta;
                CGFloat radius = 0.5*delta;
                CGFloat startAngle = 0;
                CGFloat endAngle = M_PI * 2;
                UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
                NSArray <UIColor *> *gradientColors = [self gradientColorWithStartPoint:CGPointMake(x*delta, y*delta)
                                                                               endPoint:CGPointMake((x+1)*delta, (y+1)*delta)
                                                                         widthAndHeight:widthAndHeight
                                                                                 colors:colors
                                                                                   type:type];
                [self drawLinearGradient:ctx path:path.CGPath startColor:gradientColors.firstObject.CGColor endColor:gradientColors.lastObject.CGColor type:type];
                CGContextSaveGState(ctx);
            }
        }
    }
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (NSArray <UIColor *>*)gradientColorWithStartPoint:(CGPoint)startPoint
                                           endPoint:(CGPoint)endPoint
                                     widthAndHeight:(CGFloat)widthAndHeight
                                             colors:(NSArray *)colors
                                               type:(DDYQRCodeGradientType)type
{
    UIColor *color1 = colors.firstObject;
    UIColor *color2 = colors.lastObject;
    const CGFloat *components1 = CGColorGetComponents(color1.CGColor);
    const CGFloat *components2 = CGColorGetComponents(color2.CGColor);
    
    CGFloat r1 = components1[0];
    CGFloat g1 = components1[1];
    CGFloat b1 = components1[2];
    
    CGFloat r2 = components2[0];
    CGFloat g2 = components2[1];
    CGFloat b2 = components2[2];
    
    NSArray <UIColor *> *result = nil;
    switch (type) {
        case DDYQRCodeGradientTypeHorizontal:
        {
            CGFloat startDelta = startPoint.x / widthAndHeight;
            CGFloat endDelta = endPoint.x / widthAndHeight;
            
            CGFloat startR = (1-startDelta)*r1 + startDelta*r2;
            CGFloat startG = (1-startDelta)*g1 + startDelta*g2;
            CGFloat startB = (1-startDelta)*b1 + startDelta*b2;
            
            CGFloat endR = (1-endDelta)*r1 + endDelta*r2;
            CGFloat endG = (1-endDelta)*g1 + endDelta*g2;
            CGFloat endB = (1-endDelta)*b1 + endDelta*b2;
            
            result = @[[UIColor colorWithRed:startR green:startG blue:startB alpha:1], [UIColor colorWithRed:endR green:endG blue:endB alpha:1]];
        }
            break;
        case DDYQRCodeGradientTypeDiagonal:
        {
            CGFloat startDelta = [self calculateTarHeiForPoint:startPoint] / (widthAndHeight*widthAndHeight);
            CGFloat endDelta = [self calculateTarHeiForPoint:endPoint] / (widthAndHeight*widthAndHeight);
            
            CGFloat startR = r1 + startDelta*(r2-r1);
            CGFloat startG = g1 + startDelta*(g2-g1);
            CGFloat startB = b1 + startDelta*(b2-b1);
            
            CGFloat endR = r1 + endDelta*(r2-r1);
            CGFloat endG = g1 + endDelta*(g2-g1);
            CGFloat endB = b1 + endDelta*(b2-b1);
            
            result = @[[UIColor colorWithRed:startR green:startG blue:startB alpha:1], [UIColor colorWithRed:endR green:endG blue:endB alpha:1]];
        }
            break;
        default:
            break;
    }
    return result;
}

+ (CGFloat)calculateTarHeiForPoint:(CGPoint)point
{
    CGFloat tarArvValue = point.x>=point.y ? M_PI_4-atan(point.y/point.x) : M_PI_4-atan(point.x/point.y);
    return cos(tarArvValue) * (point.x*point.x + point.y*point.y);
}

+ (void)drawLinearGradient:(CGContextRef)ctr
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
                      type:(DDYQRCodeGradientType)type
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0, 1};
    
    NSArray *colors = @[(__bridge id)startColor, (__bridge id)endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    switch (type) {
        case DDYQRCodeGradientTypeDiagonal:
        {
            startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMinY(pathRect));
            endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMaxY(pathRect));
        }
            break;
        case DDYQRCodeGradientTypeHorizontal:
        {
            startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect));
            endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMidY(pathRect));
        }
            break;
        default:
            break;
    }
    CGContextSaveGState(ctr);
    CGContextAddPath(ctr, path);
    CGContextClip(ctr);
    CGContextDrawLinearGradient(ctr, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctr);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark 返回一张不超过屏幕尺寸的 image
- (UIImage *)imageSizeInScreen:(UIImage *)image
{
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    if (imageWidth <= [UIScreen mainScreen].bounds.size.width && imageHeight <= [UIScreen mainScreen].bounds.size.height) {
        return image;
    }
    CGFloat max = MAX(imageWidth, imageHeight);
    CGFloat scale = max / ([UIScreen mainScreen].bounds.size.height * 2.0);
    
    CGSize size = CGSizeMake(imageWidth / scale, imageHeight / scale);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark 判断空字符串
+ (BOOL)ddy_blankString:(NSString *)str
{
    if (!str || str==nil || str==NULL || [str isKindOfClass:[NSNull class]] || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

#pragma mark - 生成条形码
#pragma mark 生成普通条形码
+ (void)ddy_BarCodeWithString:(NSString *)string
                         size:(CGSize)size
                      success:(void (^)(UIImage *))success
{
    if ([self ddy_blankString:string]) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIImage *originalImage = [self generateOriginalBarCodeWithString:string];
        UIImage *resultImage = [self changeSizeWithCIImage:originalImage resultSize:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(resultImage);
        });
    });
}

#pragma mark 生成彩色条形码
+ (void)ddy_BarCodeWithString:(NSString *)string
                         size:(CGSize)size
                        color:(UIColor *)color
                      bgColor:(UIColor *)bgColor
                      success:(void (^)(UIImage *))success
{
    if ([self ddy_blankString:string]) return;
    if (!color) color = [UIColor blackColor];
    if (!bgColor) bgColor = [UIColor whiteColor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIImage *originalImage = [self generateOriginalBarCodeWithString:string];
        CIImage *colorImage = [self changeColor:originalImage color:color bgColor:bgColor];
        UIImage *resultImage = [self changeSizeWithCIImage:colorImage resultSize:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(resultImage);
        });
    });
}

#pragma mark - 生成二维码
#pragma mark 生成普通二维码
+ (void)ddy_QRCodeWithString:(NSString *)string
              widthAndHeight:(CGFloat)widthAndHeight
                     success:(void (^)(UIImage *))success
{
    if ([self ddy_blankString:string]) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIImage *originalImage = [self generateOriginalQRCodeWithString:string];
        UIImage *resultImage = [self changeSizeWithCIImage:originalImage resultSize:CGSizeMake(widthAndHeight, widthAndHeight)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(resultImage);
        });
    });
}

#pragma mark 生成logo二维码
+ (void)ddy_QRCodeWithString:(NSString *)string
              widthAndHeight:(CGFloat)widthAndHeight
                   logoImage:(UIImage *)logoImage
                   logoScale:(CGFloat)logoScale
                     success:(void (^)(UIImage *))success
{
    if ([self ddy_blankString:string] || !logoImage) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIImage *originalImage = [self generateOriginalQRCodeWithString:string];
        UIImage *normalQRImage = [self changeSizeWithCIImage:originalImage resultSize:CGSizeMake(widthAndHeight, widthAndHeight)];
        UIImage *resultImage = [self addLogo:logoImage toQRImage:normalQRImage logoScale:logoScale];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(resultImage);
        });
    });
}

#pragma mark 生成彩色二维码
+ (void)ddy_QRCodeWithString:(NSString *)string
              widthAndHeight:(CGFloat)widthAndHeight
                       color:(UIColor *)color
                     bgColor:(UIColor *)bgColor
                     success:(void (^)(UIImage *))success
{
    if ([self ddy_blankString:string]) return;
    if (!color) color = [UIColor blackColor];
    if (!bgColor) bgColor = [UIColor whiteColor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIImage *originalImage = [self generateOriginalQRCodeWithString:string];
        CIImage *colorQRImage = [self changeColor:originalImage color:color bgColor:bgColor];
        UIImage *resultImage = [self changeSizeWithCIImage:colorQRImage resultSize:CGSizeMake(widthAndHeight, widthAndHeight)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(resultImage);
        });
    });
}

#pragma mark 生成圆块二维码
+ (void)ddy_QRCodeCircleStyleWithString:(NSString *)string
                         widthAndHeight:(CGFloat)widthAndHeight
                           gradientType:(DDYQRCodeGradientType)gradientType
                             startColor:(UIColor *)startColor
                               endColor:(UIColor *)endColor
                                success:(void (^)(UIImage *))success
{
    if ([self ddy_blankString:string]) return;
    if (!startColor) startColor = [UIColor blackColor];
    if (!endColor) endColor = [UIColor blackColor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIImage *originalImage = [self generateOriginalQRCodeWithString:string];
        CGImageRef changedImage = [self convertCIImageToCGImage:originalImage];
        NSArray *points = [self getPixelsWithImage:changedImage];
        UIImage *resultImage = [self drawWithPoints:points widthAndHeight:widthAndHeight colors:@[startColor, endColor] type:gradientType];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(resultImage);
        });
    });
}

#pragma mark - 扫描二维码
#pragma mark 拍照扫描二维码
- (void)ddy_ScanQRCodeWithPreview:(UIView *)preview effectiveRect:(CGRect)effectiveRect
{
    if (!preview) return;
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        }
        
        // 视频输入
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if ([_captureSession canAddInput:videoInput]) {
            [_captureSession addInput:videoInput];
        }
        
        // 自动对焦
        if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [videoInput.device lockForConfiguration:nil];
            [videoInput.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [videoInput.device unlockForConfiguration];
        }
        
        dispatch_queue_t ddyQRCodeQueue = dispatch_queue_create("ddy.QRCode.serialQueue", DISPATCH_QUEUE_SERIAL);
        // 元数据输出,放后边比较好 rectOfInterest:扫描范围
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:ddyQRCodeQueue];
        if ([_captureSession canAddOutput:_metadataOutput]) {
            [_captureSession addOutput:_metadataOutput];
        }
        // 必须先加addOutput 并且有权限
        _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                                                AVMetadataObjectTypeCode39Code,
                                                AVMetadataObjectTypeCode39Mod43Code,
                                                AVMetadataObjectTypeEAN13Code,
                                                AVMetadataObjectTypeEAN8Code,
                                                AVMetadataObjectTypeCode93Code,
                                                AVMetadataObjectTypeCode128Code,
                                                AVMetadataObjectTypePDF417Code,
                                                AVMetadataObjectTypeQRCode,
                                                AVMetadataObjectTypeAztecCode,
                                                AVMetadataObjectTypeInterleaved2of5Code,
                                                AVMetadataObjectTypeITF14Code,
                                                AVMetadataObjectTypeDataMatrixCode];
        
        // 光强检测
        AVCaptureVideoDataOutput *lightOutput = [[AVCaptureVideoDataOutput alloc] init];
        [lightOutput setSampleBufferDelegate:self queue:ddyQRCodeQueue];
        if ([_captureSession canAddOutput:lightOutput]) {
            [_captureSession addOutput:lightOutput];
        }
        
        // 预览层
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        // 如果需要旋转屏幕则需要改变视频方向
        // [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        [preview.layer insertSublayer:_previewLayer atIndex:0];
        [self ddy_startRunningSession];
    }
    
    self.previewLayer.frame = preview.bounds;
    // 非常规rect,而是0-1比例,CGRectMake(y/ScreenH, x/ScreenW, scanW/ScreenH, scanW/ScreenW) CGRectMake(0,0,1,1)时表示全范围
    CGFloat scaleX = effectiveRect.origin.y/[UIScreen mainScreen].bounds.size.height;
    CGFloat scaleY = effectiveRect.origin.x/[UIScreen mainScreen].bounds.size.width;
    CGFloat scaleW = effectiveRect.size.height/[UIScreen mainScreen].bounds.size.height;
    CGFloat scaleH = effectiveRect.size.width/[UIScreen mainScreen].bounds.size.width;
    self.metadataOutput.rectOfInterest = CGRectMake(scaleX, scaleY, scaleW, scaleH);
}

#pragma mark 扫描结果回调 AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects && metadataObjects.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
            NSString *resultStr = [obj stringValue];
            BOOL success = metadataObjects && metadataObjects.count && ![DDYQRCodeManager ddy_blankString:resultStr];
            if (success)  {
                [self ddy_stopRunningSession];
                [DDYQRCodeManager ddy_palySoundWithName:@"DDYQRCode.bundle/sound.caf"];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanTimeout) object:nil];
                [self scanQRCodeResult:resultStr scanError:nil];
            }
        });
    }
}

#pragma makr 光强检测回调 AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // 这里因为只添加了视频输出，没添加音频输出 所以可以不判断 captureOutput 类型
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(ddy_QRCodeBrightnessValue:)]) {
            [self.delegate ddy_QRCodeBrightnessValue:brightnessValue];
        } else if (self.brightnessValueBlock) {
            self.brightnessValueBlock(brightnessValue);
        }
    });
}

#pragma mark 开始运行会话
- (void)ddy_startRunningSession {
    if (![_captureSession isRunning]) {
        [_captureSession startRunning];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanTimeout) object:nil];
    [self performSelector:@selector(scanTimeout) withObject:nil afterDelay:6];
}

#pragma mark 停止运行会话
- (void)ddy_stopRunningSession {
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
    }
}

- (void)scanTimeout {
    [self scanQRCodeResult:nil scanError:[NSError errorWithDomain:DDYQRError code:DDYQRErrorCameraNotFount userInfo:nil]];
}

#pragma mark 图片读取二维码
- (void)ddy_scanQRCodeWithImage:(UIImage *)image
{
    if (!image) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *img = [self imageSizeInScreen:image];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:img.CGImage]];
        NSString *resultStr;
        
        for (int i = 0; i<features.count; i++) {
            CIQRCodeFeature *feature = [features objectAtIndex:i];
            resultStr = feature.messageString;
        }
        BOOL success = features && features.count && ![DDYQRCodeManager ddy_blankString:resultStr];
        [self scanQRCodeResult:resultStr scanError:success ? nil : [NSError errorWithDomain:DDYQRError code:DDYQRErrorPhotoNotFount userInfo:nil]];
    });
}

#pragma mark 利用UIImagePickerViewController选取二维码图片
- (void)ddy_scanQRCodeWithImagePickerFromCurrentVC:(UIViewController *)controller
{
    if (!controller) return;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
    imagePicker.delegate = self;
    [controller presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self ddy_scanQRCodeWithImage:info[UIImagePickerControllerOriginalImage]];
    [picker dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)scanQRCodeResult:(NSString *)resultStr scanError:(NSError *)scanError
{
    if ([self.delegate respondsToSelector:@selector(ddy_QRCodeScanResult:scanError:)]) {
        [self.delegate ddy_QRCodeScanResult:resultStr scanError:scanError];
    } else if (self.scanResultBlock) {
        self.scanResultBlock(resultStr, scanError);
    }
}

#pragma mark - 音效和亮灯
#pragma mark 播放音效
void soundCompleteCallback(SystemSoundID soundID, void *clientData) { }

+ (void)ddy_palySoundWithName:(NSString *)soundName
{
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:soundName ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark  打开关闭闪光灯--持续亮灯(非拍照闪灯)
+ (void)ddy_turnOnTorchLight:(BOOL)on
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // hasTorch是持续发光 hasFlash是闪光 （setTorchMode: 和 setFlashMode: 同理）
    if ([device hasTorch] && [device hasFlash])
    {
        // 注意改变设备属性前先加锁,调用完解锁
        [device lockForConfiguration:nil];
        [device setTorchMode: on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

@end
