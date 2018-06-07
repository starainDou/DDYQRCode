//
//  DDYScanResultVC.m
//  DDYQRCode
//
//  Created by SmartMesh on 2018/5/31.
//  Copyright © 2018年 com.smartmesh. All rights reserved.
//

#import "DDYScanResultVC.h"
#import "Masonry.h"


#define DDYTopH (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)

@interface DDYScanResultVC ()

@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, strong) UIButton *copyButton;

@end

@implementation DDYScanResultVC

- (UILabel *)resultLabel {
    if (!_resultLabel) {
       _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 300)];
        [_resultLabel setFont:[UIFont systemFontOfSize:15]];
        [_resultLabel setTextAlignment:NSTextAlignmentCenter];
        [_resultLabel setNumberOfLines:0];
        [_resultLabel setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];
        [_resultLabel setPreferredMaxLayoutWidth:([UIScreen mainScreen].bounds.size.width - 15 * 2)];
        [_resultLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_resultLabel setText:_resultStr];
        [self.view addSubview:_resultLabel];
    }
    return _resultLabel;
}

- (UIButton *)copyButton {
    if (!_copyButton) {
        _copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_copyButton setTitle:@"复制" forState:UIControlStateNormal];
        [_copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_copyButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_copyButton addTarget:self action:@selector(handleCopy) forControlEvents:UIControlEventTouchUpInside];
        [_copyButton setBackgroundColor:[UIColor blueColor]];
        [_copyButton.layer setCornerRadius:6];
        [_copyButton.layer setMasksToBounds:YES];
        [self.view addSubview:_copyButton];
    }
    return _copyButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(DDYTopH+40);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
    }];
    
    [self.copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.resultLabel.mas_bottom).offset(25);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.height.mas_equalTo(40);
    }];
}

- (void)handleCopy {
    [[UIPasteboard generalPasteboard] setString:self.resultStr];
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
