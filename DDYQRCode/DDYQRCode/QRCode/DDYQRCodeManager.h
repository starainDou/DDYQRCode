
#import <Foundation/Foundation.h>

@import UIKit;
@import AVFoundation;

typedef NS_ENUM(NSInteger, DDYQRCodeGradientType) {
    DDYQRCodeGradientTypeNone,        // 纯色.
    DDYQRCodeGradientTypeHorizontal,  // 水平渐变.
    DDYQRCodeGradientTypeDiagonal,    // 对角线渐变.
};

@protocol DDYQRCodeManagerDelegate <NSObject>

@required
/** 扫描结果delegate */
- (void)ddy_QRCodeScanResult:(NSString *)result scanError:(NSError *)scanError;

@optional
/** 光强检测delegate */
- (void)ddy_QRCodeBrightnessValue:(CGFloat)brightnessValue;

@end

@interface DDYQRCodeManager : NSObject

extern NSErrorDomain DDYQRError;

#define DDYQRErrorNone               0  // 扫描成功
#define DDYQRErrorCameraNotFount    -1  // 相机扫描未发现二维码
#define DDYQRErrorPhotoNotFount     -2  // 图片扫描未发现二维码

/** delegate 优先代理 */
@property (nonatomic, weak) id <DDYQRCodeManagerDelegate> delegate;
/** 扫描结果block 优先代理 */
@property (nonatomic, copy) void (^scanResultBlock)(NSString *resultStr, NSError *scanError);
/** 光强检测block 优先代理 */
@property (nonatomic, copy) void (^brightnessValueBlock)(CGFloat brightnessValue);
/** 是否播放音效 默认播放 */
@property (nonatomic, assign) BOOL playSound;
/** 扫描区域 默认全屏 */
@property (nonatomic, assign) CGRect rectOfInterest;

#pragma mark - /////////////////////////////////////////// 权限鉴定 ///////////////////////////////////////////
/**
 相机使用权限鉴定
 @param success 有权限回调
 @param fail 无权限回调
 */
+ (void)cameraAuthSuccess:(void (^)(void))success fail:(void (^)(void))fail;

/**
 相册使用权限鉴定
 @param success 有权限回调
 @param fail 无权限回调
 */
+ (void)albumAuthSuccess:(void (^)(void))success fail:(void (^)(void))fail;

#pragma mark - ////////////////////////////////////// 二维码(条形码)生成 //////////////////////////////////////
/**
 生成普通条形码
 @param string 需要转成条形码的字符串
 @param size 条形码大小
 @param success 成功回调传出生成的条形码图片
 */
+ (void)ddy_BarCodeWithString:(NSString *_Nonnull)string
                         size:(CGSize)size
                      success:(void (^)(UIImage *barCodeImage))success;

/**
 生成彩色条形码
 @param string 需要转成条形码的字符串
 @param size 条形码大小
 @param color 前景色
 @param bgColor 背景色
 @param success 成功回调传出生成的条形码图片
 */
+ (void)ddy_BarCodeWithString:(NSString *_Nonnull)string
                         size:(CGSize)size
                        color:(UIColor *_Nonnull)color
                      bgColor:(UIColor *_Nonnull)bgColor
                      success:(void (^)(UIImage *barCodeImage))success;

/**
 生成普通二维码
 @param string 需要转成二维码的字符串
 @param widthAndHeight 二维码正方形宽高
 @param success 成功回调传出生成的二维码图片
 */
+ (void)ddy_QRCodeWithString:(NSString *_Nonnull)string
              widthAndHeight:(CGFloat)widthAndHeight
                     success:(void (^)(UIImage *QRCodeImage))success;

/**
 生成logo二维码
 @param string 需要转成二维码的字符串
 @param widthAndHeight 二维码正方形宽高
 @param logoImage 中心logo图片
 @param logoScale logo相对比例 推荐0.2
 @param success 成功回调传出生成的二维码图片
 */
+ (void)ddy_QRCodeWithString:(NSString *_Nonnull)string
              widthAndHeight:(CGFloat)widthAndHeight
                   logoImage:(UIImage *_Nonnull)logoImage
                   logoScale:(CGFloat)logoScale
                     success:(void (^)(UIImage *QRCodeImage))success;

/**
 生成彩色二维码
 @param string 需要转成二维码的字符串
 @param widthAndHeight 二维码正方形宽高
 @param color 前景色
 @param bgColor 背景色
 @param success 成功回调传出生成的二维码图片
 */
+ (void)ddy_QRCodeWithString:(NSString *_Nonnull)string
              widthAndHeight:(CGFloat)widthAndHeight
                       color:(UIColor *_Nonnull)color
                     bgColor:(UIColor *_Nonnull)bgColor
                     success:(void (^)(UIImage *QRCodeImage))success;

/**
 生成圆块二维码
 @param string 需要转成二维码的字符串
 @param widthAndHeight 二维码正方形宽高
 @param gradientType 变化类型
 @param startColor 起始颜色
 @param endColor 结束颜色
 @param success 成功回调传出生成的二维码图片
 */
+ (void)ddy_QRCodeCircleStyleWithString:(NSString *_Nonnull)string
                         widthAndHeight:(CGFloat)widthAndHeight
                           gradientType:(DDYQRCodeGradientType)gradientType
                             startColor:(UIColor *_Nonnull)startColor
                               endColor:(UIColor *_Nonnull)endColor
                                success:(void (^)(UIImage *QRCodeImage))success;

#pragma mark - ////////////////////////////////////// 二维码(条形码)扫描 //////////////////////////////////////
/**
 相机扫描二维码
 使用前要权限鉴定
 @param preview 预览层将要放置的视图(不为空)
 @param effectiveRect 扫描范围 CGRectMake(y/ScreenH, x/ScreenW, scanW/ScreenH, scanW/ScreenW)
 */
- (void)ddy_ScanQRCodeWithPreview:(UIView *)preview effectiveRect:(CGRect)effectiveRect;

/** 开始运行会话 */
- (void)ddy_startRunningSession;

/** 停止运行会话 */
- (void)ddy_stopRunningSession;

/**
 图片读取二维码
 @param image 要扫描的图片(不为空)
 */
- (void)ddy_scanQRCodeWithImage:(UIImage *_Nonnull)image;

/**
 利用UIImagePickerViewController选取二维码图片
 也可以改为三方图片选择器,如TZImagePickerController
 
 @param controller 传入当前控制器以供跳转
 */
- (void)ddy_scanQRCodeWithImagePickerFromCurrentVC:(UIViewController *_Nonnull)controller;

#pragma mark - ////////////////////////////////////// 音效和亮灯 //////////////////////////////////////
/**
 播放音效
 @param soundName mainBundle中音效名称
 */
+ (void)ddy_palySoundWithName:(NSString *_Nonnull)soundName;

/**
 打开关闭闪光灯--持续亮灯(非拍照闪灯)
 @param on 开关状态
 */
+ (void)ddy_turnOnTorchLight:(BOOL)on;

@end
