//
//  ViewController.m
//  DDYQRCode
//
//  Created by SmartMesh on 2018/5/25.
//  Copyright © 2018年 com.smartmesh. All rights reserved.
//

#import "ViewController.h"
#import "DDYScanVC.h"
#import "DDYQRCodeImgVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton *qrCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qrCodeBtn.frame = CGRectMake(15, 120, 120, 20);
    [qrCodeBtn setBackgroundColor:[UIColor lightGrayColor]];
    [qrCodeBtn setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [qrCodeBtn addTarget:self action:@selector(handleScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qrCodeBtn];
    
    UIButton *myCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    myCodeBtn.frame = CGRectMake(155, 120, 120, 20);
    [myCodeBtn setBackgroundColor:[UIColor lightGrayColor]];
    [myCodeBtn setTitle:@"我的二维码" forState:UIControlStateNormal];
    [myCodeBtn addTarget:self action:@selector(handleMyQRCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myCodeBtn];
}

- (void)handleScan {
    [self.navigationController pushViewController:[[DDYScanVC alloc] init] animated:YES];
}

- (void)handleMyQRCode {
    [self.navigationController pushViewController:[[DDYQRCodeImgVC alloc] init] animated:YES];
}

@end
