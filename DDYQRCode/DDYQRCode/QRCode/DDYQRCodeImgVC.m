//
//  DDYQRCodeImgVC.m
//  DDYQRCode
//
//  Created by SmartMesh on 2018/5/31.
//  Copyright © 2018年 com.smartmesh. All rights reserved.
//

#import "DDYQRCodeImgVC.h"
#import "DDYQRCodeManager.h"
#import "DDYScanResultVC.h"
#import "Masonry.h"
#import "AppDelegate.h"

#define DDYPortrait (([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown))
#define DDYTopH (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)

@interface DDYQRCodeImgVC ()<DDYQRCodeManagerDelegate>

/** 二维码扫描管理器 */
@property (nonatomic, strong) DDYQRCodeManager *qrcodeManager;
/** 几个展示图片的视图 */
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;
@property (nonatomic, strong) UIImageView *imageView4;
@property (nonatomic, strong) UIImageView *imageView5;
@property (nonatomic, strong) UIImageView *imageView6;
/** 原始亮度 */
@property (nonatomic, assign) CGFloat originalBrightness;
/** 逐步调节 */
@property (nonatomic, strong) NSOperationQueue *brightnessQueue;

@end

@implementation DDYQRCodeImgVC

- (DDYQRCodeManager *)qrcodeManager {
    if (!_qrcodeManager) {
        _qrcodeManager = [[DDYQRCodeManager alloc] init];
        _qrcodeManager.delegate = self;
    }
    return _qrcodeManager;
}

- (NSOperationQueue *)brightnessQueue {
    if (!_brightnessQueue) {
        _brightnessQueue = [[NSOperationQueue alloc] init];
        _brightnessQueue.maxConcurrentOperationCount = 1;
    }
    return _brightnessQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _imageView1 = [self imgView];
    _imageView2 = [self imgView];
    _imageView3 = [self imgView];
    _imageView4 = [self imgView];
    _imageView5 = [self imgView];
    _imageView6 = [self imgView];
    
    [self loadImg];
    [self addObserver];
}

#pragma mark 生成图片
- (void)loadImg {
    NSString *pasteBoardString = [UIPasteboard generalPasteboard].string;
    [DDYQRCodeManager ddy_QRCodeWithString:pasteBoardString ? pasteBoardString : @"123456789"
                            widthAndHeight:300
                                   success:^(UIImage *QRCodeImage) {
                                       self.imageView1.image = QRCodeImage;
                                   }];
    
    [DDYQRCodeManager ddy_QRCodeWithString:@"123456789"
                            widthAndHeight:300
                                     color:[UIColor redColor]
                                   bgColor:[UIColor yellowColor]
                                   success:^(UIImage *QRCodeImage) {
                                       self.imageView2.image = QRCodeImage;
                                   }];
    
    [DDYQRCodeManager ddy_QRCodeWithString:@"123456789"
                            widthAndHeight:300
                                 logoImage:[self testLogoImage]
                                 logoScale:0.2
                                   success:^(UIImage *QRCodeImage) {
                                       self.imageView3.image = QRCodeImage;
                                   }];
    
    [DDYQRCodeManager ddy_QRCodeCircleStyleWithString:@"123456789"
                                       widthAndHeight:300
                                         gradientType:DDYQRCodeGradientTypeDiagonal
                                           startColor:[UIColor blueColor]
                                             endColor:[UIColor redColor]
                                              success:^(UIImage *QRCodeImage) {
                                                  self.imageView4.image = QRCodeImage;
                                              }];
    [DDYQRCodeManager ddy_BarCodeWithString:@"123456789"
                                       size:CGSizeMake(240, 80)
                                    success:^(UIImage *barCodeImage) {
                                        self.imageView5.image = barCodeImage;
                                    }];
    
    [DDYQRCodeManager ddy_BarCodeWithString:@"123456789"
                                       size:CGSizeMake(240, 80)
                                      color:[UIColor redColor]
                                    bgColor:[UIColor blueColor]
                                    success:^(UIImage *barCodeImage) {
                                        self.imageView6.image = barCodeImage;
                                    }];
}

#pragma mark 添加监听
- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil]; //监听程序挂起.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];  //监听重新进入.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];  //监听程序销毁.
}

- (UIImageView *)imgView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [imageView setUserInteractionEnabled:YES];
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressScan:)];
    [longGes setMinimumPressDuration:1];
    [imageView addGestureRecognizer:longGes];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:imageView];
    return imageView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [(AppDelegate *)[UIApplication sharedApplication].delegate ddy_ShouldAutorotate:YES myOrientation:UIInterfaceOrientationUnknown];
    self.originalBrightness = [UIScreen mainScreen].brightness;
    [self graduallySetBrightness:MAX(0.7, self.originalBrightness) animation:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [(AppDelegate *)[UIApplication sharedApplication].delegate ddy_ShouldAutorotate:NO myOrientation:UIInterfaceOrientationPortrait];
    [self graduallySetBrightness:self.originalBrightness animation:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (DDYPortrait)
    {
        [self.imageView1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(14);
            make.width.mas_equalTo(self.imageView2);
            make.top.mas_equalTo(self.view.mas_top).offset(DDYTopH+30);
            make.height.mas_equalTo(self.imageView1.mas_width);
        }];
        [self.imageView2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.imageView1.mas_right).offset(14);
            make.right.mas_equalTo(self.view).offset(-14);
            make.top.mas_equalTo(self.imageView1);
            make.height.mas_equalTo(self.imageView2.mas_width);
        }];
        [self.imageView3 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.imageView1);
            make.top.mas_equalTo(self.imageView1.mas_bottom).offset(60);
            make.height.mas_equalTo(self.imageView3.mas_width);
        }];
        [self.imageView4 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.imageView2);
            make.top.mas_equalTo(self.imageView3);
            make.height.mas_equalTo(self.imageView4.mas_width);
        }];
        [self.imageView5 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.imageView3);
            make.top.mas_equalTo(self.imageView3.mas_bottom).offset(60);
            make.height.mas_equalTo(self.imageView5.mas_width).multipliedBy(0.33);
        }];
        [self.imageView6 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.imageView4);
            make.top.mas_equalTo(self.imageView5);
            make.height.mas_equalTo(self.imageView5.mas_height);
        }];
    }
    else
    {
        [self.imageView1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(14);
            make.width.mas_equalTo(self.imageView2);
            make.top.mas_equalTo(self.view).offset(DDYTopH+20);
            make.height.mas_equalTo(self.imageView1.mas_width);
        }];
        [self.imageView2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.imageView1.mas_right).offset(14);
            make.width.equalTo(self.imageView3.mas_width);
            make.top.mas_equalTo(self.imageView1);
            make.height.mas_equalTo(self.imageView2.mas_width);
        }];
        [self.imageView3 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.imageView2.mas_right).offset(14);
            make.width.equalTo(self.imageView4.mas_width);
            make.top.mas_equalTo(self.imageView1);
            make.height.mas_equalTo(self.imageView3.mas_width);
        }];
        [self.imageView4 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.imageView3.mas_right).offset(14);
            make.right.mas_equalTo(self.view).offset(-14);
            make.top.mas_equalTo(self.imageView3);
            make.height.mas_equalTo(self.imageView4.mas_width);
        }];
        [self.imageView5 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.imageView1);
            make.top.mas_equalTo(self.imageView1.mas_bottom).offset(14);
            make.height.mas_equalTo(self.imageView5.mas_width).multipliedBy(0.33);
        }];
        [self.imageView6 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.imageView2);
            make.top.mas_equalTo(self.imageView5);
            make.height.mas_equalTo(self.imageView6.mas_width).multipliedBy(0.33);
        }];
    }
}

#pragma mark 进入前台
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self graduallySetBrightness:MAX(0.7, self.originalBrightness) animation:YES];
}

#pragma mark 挂起程序
- (void)applicationWillResignActive:(UIApplication *)application {
    [self graduallySetBrightness:self.originalBrightness animation:NO];
}

#pragma mark 销毁程序
- (void)applicationWillTerminate:(UIApplication *)application {
    [self graduallySetBrightness:self.originalBrightness animation:NO];
}

- (void)longPressScan:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.qrcodeManager ddy_scanQRCodeWithImage:[(UIImageView *)longPress.view image]];
    }
}

#pragma mark DDYQRCodeManagerDelegate
- (void)ddy_QRCodeScanResult:(NSString *)result scanError:(NSError *)scanError {
    if (!scanError) {
        DDYScanResultVC *resultVC = [[DDYScanResultVC alloc] init];
        resultVC.resultStr = result;
        [self.navigationController pushViewController:resultVC animated:YES];
    }
}

- (UIImage *)testLogoImage
{
    NSString *drawStr = @"我来占位";
    UIColor *color = [UIColor colorWithRed:100./255. green:190./255. blue:230./255. alpha:1.];
    CGRect rectCircle = CGRectMake(0.f, 0.f, 140, 140);
    UIGraphicsBeginImageContext(rectCircle.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rectCircle);
    
    CGRect rectWord = CGRectMake(5, 5, 130, 130);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    style.baseWritingDirection = NSWritingDirectionNatural;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:50],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:[UIColor redColor]};
    [drawStr drawInRect:rectWord withAttributes:dic];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)graduallySetBrightness:(CGFloat)brightness animation:(BOOL)animation {
    [self.brightnessQueue cancelAllOperations];
    if (animation) {
        CGFloat currentBrightness = [UIScreen mainScreen].brightness;
        CGFloat stepValue = 0.005 * ((brightness > currentBrightness) ? 1 : -1);
        int times = fabs((brightness - currentBrightness) / 0.005);
        for (int i = 1; i < times + 1; i++) {
            [self.brightnessQueue addOperationWithBlock:^{
                [NSThread sleepForTimeInterval:0.005];
                [UIScreen mainScreen].brightness = currentBrightness + i * stepValue;
            }];
        }
    } else {
        [UIScreen mainScreen].brightness = brightness;
    }
}

#pragma mark - 控制旋转屏幕
#pragma mark 支持旋转的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
#pragma mark 是否支持自动旋转
- (BOOL)shouldAutorotate {
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
