#import "DDYScanVC.h"
#import "Masonry.h"
#import "DDYQRCodeManager.h"
#import "DDYScanResultVC.h"
#import "DDYQRCodeImgVC.h"
#import "AppDelegate.h"

#define DDYTopH (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)
#define DDYScanWH 240.0
#define DDYScanX ([UIScreen mainScreen].bounds.size.width/2.0 - DDYScanWH/2.0)
#define DDYScanY (DDYTopH + 60)

@interface DDYScanVC ()<DDYQRCodeManagerDelegate, CAAnimationDelegate>
/** 二维码扫描管理器 */
@property (nonatomic, strong) DDYQRCodeManager *qrcodeManager;
/** 镂空遮罩 */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
/** 扫描框带边角视图 */
@property (nonatomic, strong) UIImageView *scanImageView;
/** 扫描线 */
@property (nonatomic, strong) UIImageView *scanLineView;
/** 提示文字 */
@property (nonatomic, strong) UILabel *tipLabel;
/** 补光灯开关按钮 */
@property (nonatomic, strong) UIButton *torchButton;
/** 我的二维码按钮 */
@property (nonatomic, strong) UIButton *myQRCodeButton;
/** 导航分割线 */
@property (nonatomic, strong) UIView *navLine;

@end

@implementation DDYScanVC

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
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
        [path appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(DDYScanX, DDYScanY, DDYScanWH, DDYScanWH)] bezierPathByReversingPath]];
        _shapeLayer.path = path.CGPath;
    }
    return _shapeLayer;
}

- (UIImageView *)scanImageView {
    if (!_scanImageView) {
        _scanImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DDYQRCode.bundle/QRCode"]];
    }
    return _scanImageView;
}

/** 最好不要用 [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];方式隐藏到航线 */
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

- (UIImageView *)scanLineView {
    if (!_scanLineView) {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        basicAnimation.duration = 2;
        basicAnimation.fromValue = @(0);
        basicAnimation.toValue = @(DDYScanWH);
        basicAnimation.repeatCount = CGFLOAT_MAX;
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.fillMode = kCAFillModeForwards;
        
        _scanLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DDYQRCode.bundle/ScanLine"]];
        [_scanLineView.layer addAnimation:basicAnimation forKey:nil];
    }
    return _scanLineView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        [_tipLabel setTextColor:[UIColor whiteColor]];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        [_tipLabel setText:@"将二维码/条码放入框内, 即可自动扫描"];
        [_tipLabel setFont:[UIFont systemFontOfSize:14]];
        [_tipLabel setPreferredMaxLayoutWidth:DDYScanWH];
        [_tipLabel setNumberOfLines:0];
        [_tipLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _tipLabel;
}

- (UIButton *)torchButton {
    if (!_torchButton) {
        _torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_torchButton setTitle:@"打开补光灯" forState:UIControlStateNormal];
        [_torchButton setTitle:@"关闭补光灯" forState:UIControlStateSelected];
        [_torchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_torchButton addTarget:self action:@selector(handleTorch:) forControlEvents:UIControlEventTouchUpInside];
        [_torchButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_torchButton setHidden:YES];
        [_torchButton sizeToFit];
    }
    return _torchButton;
}

- (UIButton *)myQRCodeButton {
    if (!_myQRCodeButton) {
        _myQRCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_myQRCodeButton setTitle:@"我的二维码" forState:UIControlStateNormal];
        [_myQRCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_myQRCodeButton addTarget:self action:@selector(handleMyQRCode:) forControlEvents:UIControlEventTouchUpInside];
        [_myQRCodeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_myQRCodeButton sizeToFit];
    }
    return _myQRCodeButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view.layer addSublayer:self.shapeLayer];
    [self.view addSubview:self.scanImageView];
    [self.scanImageView addSubview:self.scanLineView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.torchButton];
    [self.view addSubview:self.myQRCodeButton];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(handleAlbum)]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBackgroundAlpha:0];
    [self.navLine setHidden:YES];
    [self.qrcodeManager ddy_startRunningSession];
    [_tipLabel setText:@"将二维码/条码放入框内, 即可自动扫描"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setNavigationBackgroundAlpha:1];
    [self.navLine setHidden:NO];
    [self.qrcodeManager ddy_stopRunningSession];
}

- (void)setNavigationBackgroundAlpha:(CGFloat)alpha {
    UIView * barBackground = self.navigationController.navigationBar.subviews.firstObject;
    barBackground.alpha = alpha;
    [barBackground.subviews setValue:@(alpha) forKeyPath:@"alpha"];
}

#pragma mark 如果不用masonry可以用这段代码绝对布局
- (void)layoutView {
    self.scanImageView.frame = CGRectMake(DDYScanX, DDYScanY, DDYScanWH, DDYScanWH);
    self.scanLineView.frame = CGRectMake(0, 0, DDYScanWH, 2);
    self.tipLabel.frame = CGRectMake(DDYScanX, CGRectGetMaxY(self.scanImageView.frame)+20, DDYScanWH, 30);
    [self.tipLabel sizeToFit];
    self.torchButton.frame = CGRectMake(DDYScanX, CGRectGetMaxY(self.scanImageView.frame)-30, DDYScanWH, 20);
    self.myQRCodeButton.frame = CGRectMake(0, 0, 120, 30);
    [self.myQRCodeButton sizeToFit];
    self.myQRCodeButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2., [UIScreen mainScreen].bounds.size.height-30);
    [DDYQRCodeManager cameraAuthSuccess:^{
        [self.qrcodeManager ddy_ScanQRCodeWithPreview:self.view effectiveRect:CGRectMake(DDYScanX, DDYScanY, DDYScanWH, DDYScanWH)];
    } fail:^{ NSLog(@"未授权时处理，例如弹窗/返回"); }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // 未构成循环引用的别乱用weak
    [self.scanImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(DDYScanX);
        make.top.mas_equalTo(self.view).offset(DDYScanY);
        make.width.height.mas_equalTo(DDYScanWH);
    }];

    [self.scanLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scanImageView);
        make.top.mas_equalTo(self.scanImageView);
        make.width.mas_equalTo(DDYScanWH);
        make.height.mas_equalTo(2);
    }];

    [self.tipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scanImageView.mas_bottom).offset(20);
        make.left.mas_equalTo(self.scanImageView.mas_left);
        make.right.mas_equalTo(self.scanImageView.mas_right);
    }];

    [self.torchButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(15);
        make.bottom.mas_equalTo(self.view).offset(-15);
    }];

    [self.myQRCodeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-15);
        make.bottom.mas_equalTo(self.view).offset(-15);
    }];

    [DDYQRCodeManager cameraAuthSuccess:^{
        [self.qrcodeManager ddy_ScanQRCodeWithPreview:self.view effectiveRect:CGRectMake(DDYScanX, DDYScanY, DDYScanWH, DDYScanWH)];
    } fail:^{ NSLog(@"未授权时处理，例如弹窗/返回"); }];
}

#pragma mark - 事件处理
#pragma mark 补光灯开关
- (void)handleTorch:(UIButton *)button {
    [DDYQRCodeManager ddy_turnOnTorchLight:(button.selected = !button.selected)];
}

#pragma mark 我的二维码
- (void)handleMyQRCode:(UIButton *)button {
    [self.navigationController pushViewController:[[DDYQRCodeImgVC alloc] init] animated:YES];
}

#pragma mark - DDYQRCodeManagerDelegate
#pragma mark 扫面结果
- (void)ddy_QRCodeScanResult:(NSString *)result scanError:(NSError *)scanError {
    if (scanError) {
        if (scanError.code == DDYQRErrorCameraNotFount) {
            [self shakeWarning:@"未识别到有效内容，请换个姿势试试"];
        } else if (scanError.code == DDYQRErrorPhotoNotFount) {
            [self.qrcodeManager ddy_stopRunningSession];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"未识别到有效内容" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.qrcodeManager ddy_startRunningSession];
            }]];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
    } else {
        // 如果只让相机扫描有声音，图片扫描无声音可以将声音播放放到 -captureOutput:didOutputMetadataObjects:fromConnection:
        [DDYQRCodeManager ddy_palySoundWithName:@"DDYQRCode.bundle/sound.caf"];
        DDYScanResultVC *resultVC = [[DDYScanResultVC alloc] init];
        resultVC.resultStr = result;
        [self.navigationController pushViewController:resultVC animated:YES];
    }
}

#pragma mark 光强检测
- (void)ddy_QRCodeBrightnessValue:(CGFloat)brightnessValue {NSLog(@"%lf",brightnessValue);
    // 可以在扫描框设置轻点照亮
    __weak __typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        if (brightnessValue > 0 && !strongSelf.torchButton.hidden && !strongSelf.torchButton.selected) { // 弱光，按钮没有隐藏且不是开灯状态
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

- (void)handleAlbum {
    [self.qrcodeManager ddy_scanQRCodeWithImagePickerFromCurrentVC:self];
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

@end

/**
 *  相机模块属于耗电模块，在iOS严格管控下，如果长时间运行会自动关闭会话，页面静止
 *
 *  条形码源字符有严格要求，如果是因为字符集原因导致无法生成或扫描请自行解决
 *
 *  二维码容量并非无限，所以生成二维码的字符不应该过多，防止出错。
 *
 *  iOS原生二维码扫描对编码格式有严格要求，如果确定编码格式导致扫描不出，请尝试其他扫描方式
 *
 *  因为UI中文字不是很多，如需国际化请自行配置
 *
 *  统计表明横屏二维码扫描是不必要的，若您需要横屏扫描，请自行处理UI逻辑和myOrientation计算（建议横屏下全屏范围）
 *
 *  本工程属于demo形式，可自行调整UI或者自建UI调用DDYQRCodeManager处理事务
 *
 *  一个二维码更改样式库 https://github.com/EyreFree/EFQRCode
 */
