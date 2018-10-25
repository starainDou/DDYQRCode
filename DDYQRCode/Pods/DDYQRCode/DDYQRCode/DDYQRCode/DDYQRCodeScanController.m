/** MARK: - DDYQRCodeManager 2018/10/23
 *  !!!: Author: 豆电雨
 *  !!!: QQ/WX:  634778311
 *  !!!: Github: https://github.com/RainOpen/
 *  !!!: Blog:   https://www.jianshu.com/u/a4bc2516e9e5
 *  MARK: - DDYQRCodeScanController.m
 */

#import "DDYQRCodeScanController.h"
#import "NSBundle+DDYQRCode.h"

#define DDYScanW 240.0
#define DDYScanX ([UIScreen mainScreen].bounds.size.width/2.0 - DDYScanW/2.0)
#define DDYScanY (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 60)
#define DDYScanRect CGRectMake(DDYScanX, DDYScanY, DDYScanW, DDYScanW)

@interface DDYQRCodeScanController ()<DDYQRCodeManagerDelegate, CAAnimationDelegate>
/** 扫描管理器 */
@property (nonatomic, strong) DDYQRCodeManager *qrcodeManager;
/** 镂空遮罩 */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
/** 扫描视图 */
@property (nonatomic, strong) DDYQRCodeScanView *scanView;
/** 提示文字 */
@property (nonatomic, strong) UILabel *tipLabel;
/** 补光灯开关按钮 */
@property (nonatomic, strong) UIButton *torchButton;
/** 相册按钮 */
@property (nonatomic, strong) UIBarButtonItem *rightBar;
/** 导航分割线 */
@property (nonatomic, strong) UIView *navLine;

@end

@implementation DDYQRCodeScanController

- (DDYQRCodeManager *)qrcodeManager {
    if (!_qrcodeManager) {
        _qrcodeManager = [[DDYQRCodeManager alloc] init];
        _qrcodeManager.delegate = self;
    }
    return _qrcodeManager;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
        UIBezierPath *pathOut = [UIBezierPath bezierPathWithRect:self.view.bounds];
        UIBezierPath *pathIn  = [UIBezierPath bezierPathWithRect:DDYScanRect];
        [pathOut appendPath:[pathIn bezierPathByReversingPath]];
        _shapeLayer.path = pathOut.CGPath;
    }
    return _shapeLayer;
}

- (DDYQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[DDYQRCodeScanView alloc] initWithFrame:DDYScanRect];
        _scanView.style = self.style;
    }
    return _scanView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        [_tipLabel setTextColor:[UIColor whiteColor]];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        [_tipLabel setText:DDYQRCodeI18n(@"DDYQRCodeScanTip")];
        [_tipLabel setFont:[UIFont systemFontOfSize:14]];
        [_tipLabel setPreferredMaxLayoutWidth:DDYScanW];
        [_tipLabel setNumberOfLines:0];
        [_tipLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _tipLabel;
}

- (UIButton *)torchButton {
    if (!_torchButton) {
        _torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_torchButton setImage:[NSBundle ddyImage:@"LightOff"] forState:UIControlStateNormal];
        [_torchButton setImage:[NSBundle ddyImage:@"LightOn"] forState:UIControlStateSelected];
        [_torchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_torchButton addTarget:self action:@selector(handleTorch:) forControlEvents:UIControlEventTouchUpInside];
        [_torchButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_torchButton setHidden:YES];
        [_torchButton sizeToFit];
    }
    return _torchButton;
}

- (UIBarButtonItem *)rightBar {
    if (!_rightBar) {
        _rightBar = [[UIBarButtonItem alloc] initWithTitle:DDYQRCodeI18n(@"DDYQRCodeAlbum")
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(handleAlbum)];
    }
    return _rightBar;
}

- (UIView *)navLine {
    if (!_navLine) {
        _navLine = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    }
    return _navLine;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (CGRect)effectiveRect {
    // 非常规rect,而是0-1比例,CGRectMake(y/ScreenH, x/ScreenW, scanW/ScreenH, scanW/ScreenW) CGRectMake(0,0,1,1)时表示全范围
    CGFloat scaleX = DDYScanRect.origin.y/[UIScreen mainScreen].bounds.size.height;
    CGFloat scaleY = DDYScanRect.origin.x/[UIScreen mainScreen].bounds.size.width;
    CGFloat scaleW = DDYScanRect.size.height/[UIScreen mainScreen].bounds.size.height;
    CGFloat scaleH = DDYScanRect.size.width/[UIScreen mainScreen].bounds.size.width;
    return self.isEffectRectOnlyInScanview ? CGRectMake(scaleX, scaleY, scaleW, scaleH) : CGRectMake(0,0,1,1);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view.layer addSublayer:self.shapeLayer];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.torchButton];
    [self.navigationItem setRightBarButtonItem:self.rightBar];
    [self.navigationItem setTitle:DDYQRCodeI18n(@"DDYQRCodeScanTitle")];
    [self.navigationItem setTitle:DDYQRCodeI18n(@"DDYQRCodeScanTitle")];
    [DDYQRCodeManager cameraAuthSuccess:^{
        [self.qrcodeManager ddy_ScanQRCodeWithPreview:self.view effectiveRect:[self effectiveRect]];
    } fail:^{  }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scanView.frame = CGRectMake(DDYScanX, DDYScanY, DDYScanW, DDYScanW);
    self.tipLabel.frame = CGRectMake(DDYScanX, CGRectGetMaxY(self.scanView.frame)+20, DDYScanW, 30);
    self.torchButton.frame = CGRectMake(DDYScanX, CGRectGetMaxY(self.scanView.frame)-30, DDYScanW, 20);
    [self.tipLabel sizeToFit];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBackgroundAlpha:0];
    [self.navLine setHidden:YES];
    [self.qrcodeManager ddy_startRunningSession];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setNavigationBackgroundAlpha:1];
    [self.navLine setHidden:NO];
    [self.qrcodeManager ddy_stopRunningSession];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
}

- (void)setNavigationBackgroundAlpha:(CGFloat)alpha {
    UIView * barBackground = self.navigationController.navigationBar.subviews.firstObject;
    barBackground.alpha = alpha;
    [barBackground.subviews setValue:@(alpha) forKeyPath:@"alpha"];
}

#pragma mark - 事件处理
#pragma mark 补光灯开关
- (void)handleTorch:(UIButton *)button {
    [DDYQRCodeManager ddy_turnOnTorchLight:(button.selected = !button.selected)];
}

#pragma mark 相册二维码
- (void)handleAlbum {
    [self.qrcodeManager ddy_scanQRCodeWithImagePickerFromCurrentVC:self];
}

#pragma mark - DDYQRCodeManagerDelegate
#pragma mark 扫面结果
- (void)ddy_QRCodeScanResult:(NSString *)result scanError:(NSError *)scanError {
    if (scanError.code == DDYQRErrorCameraNotFount) {
        [self shakeWarning:DDYQRCodeI18n(@"DDYQRCodeFailTip")];
    } else if (scanError.code == DDYQRErrorPhotosNotFount) {
        [self.qrcodeManager ddy_stopRunningSession];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:DDYQRCodeI18n(@"DDYQRCodeFailTip") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:DDYQRCodeI18n(@"DDYQRCodeFailOK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.qrcodeManager ddy_startRunningSession];
        }]];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    } else if (scanError.code == DDYQRErrorCameraSuccess || scanError.code == DDYQRErrorPhotosSuccess) {
        [DDYQRCodeManager ddy_palySoundWithResource:@"DDYQRCode.bundle/ScanSuccess.caf"];
        if ([self.delegate respondsToSelector:@selector(ddy_QRCodeScanResult:scanError:scanVC:)]) {
            [self.delegate ddy_QRCodeScanResult:result scanError:scanError scanVC:self];
        } else if (self.scanResultBlock) {
            self.scanResultBlock(result, scanError, self);
        }
    }
}

#pragma mark 光强检测
- (void)ddy_QRCodeBrightnessValue:(CGFloat)brightnessValue {
    __weak __typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        if (brightnessValue > 0 && !strongSelf.torchButton.hidden && !strongSelf.torchButton.selected) {
            strongSelf.torchButton.hidden = YES;
        } else if (brightnessValue < 0 && strongSelf.torchButton.hidden) {
            strongSelf.torchButton.hidden = NO;
        }
    });
}

#pragma mark 未识别时警示
- (void)shakeWarning:(NSString *)msg {
    [_tipLabel setTextColor:[UIColor redColor]];
    [_tipLabel setText:msg];
    CAKeyframeAnimation *frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    frameAnimation.values = @[@(-4),@(0),@(4),@(0),@(-4),@(0),@(4),@(0)];
    frameAnimation.duration = 0.4f;
    frameAnimation.repeatCount = 2;
    frameAnimation.removedOnCompletion = YES;
    frameAnimation.fillMode = kCAFillModeForwards;
    frameAnimation.delegate = self;
    [_tipLabel.layer addAnimation:frameAnimation forKey:@"shake"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [_tipLabel setTextColor:[UIColor whiteColor]];
    }
}

#pragma mark - 控制旋转屏幕
#pragma mark 支持旋转的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark 是否支持自动旋转
- (BOOL)shouldAutorotate {
    return YES;
}

@end
