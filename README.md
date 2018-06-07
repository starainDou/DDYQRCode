# DDYQRCode


 *  相机模块属于耗电模块，在iOS严格管控下，如果长时间运行会自动关闭会话，页面静止
 *  条形码源字符有严格要求，如果是因为字符集原因导致无法生成或扫描请自行解决
 *  二维码容量并非无限，所以生成二维码的字符不应该过多，防止出错。
 *  iOS原生二维码扫描对编码格式有严格要求，如果确定编码格式导致扫描不出，请尝试其他扫描方式
 *  因为UI中文字不是很多，如需国际化请自行配置
 *  统计表明横屏二维码扫描是不必要的，若您需要横屏扫描，请自行处理UI逻辑和myOrientation计算（建议横屏下全屏范围）
 *  本工程属于demo形式，可自行调整UI或者自建UI调用DDYQRCodeManager处理事务
 *  一个二维码更改样式库 https://github.com/EyreFree/EFQRCode

#### 生成

 * 生成普通二维码

```
[DDYQRCodeManager ddy_QRCodeWithString:@"123456789"
                            widthAndHeight:300
                                   success:^(UIImage *QRCodeImage) {
                                       self.imageView1.image = QRCodeImage;
                                   }];
```

 * 生成彩色二维码

```
    [DDYQRCodeManager ddy_QRCodeWithString:@"123456789"
                            widthAndHeight:300
                                     color:[UIColor redColor]
                                   bgColor:[UIColor yellowColor]
                                   success:^(UIImage *QRCodeImage) {
                                       self.imageView2.image = QRCodeImage;
                                   }];
```

 * 生成logo二维码
```
    [DDYQRCodeManager ddy_QRCodeWithString:@"123456789"
                            widthAndHeight:300
                                 logoImage:[self testLogoImage]
                                 logoScale:0.2
                                   success:^(UIImage *QRCodeImage) {
                                       self.imageView3.image = QRCodeImage;
                                   }];
```

 * 生成圆块二维码
```
    [DDYQRCodeManager ddy_QRCodeCircleStyleWithString:@"123456789"
                                       widthAndHeight:300
                                         gradientType:DDYQRCodeGradientTypeDiagonal
                                           startColor:[UIColor blueColor]
                                             endColor:[UIColor redColor]
                                              success:^(UIImage *QRCodeImage) {
                                                  self.imageView4.image = QRCodeImage;
                                              }];
```                                              

 * 生成普通条形码
```
[DDYQRCodeManager ddy_BarCodeWithString:@"123456789"
                                       size:CGSizeMake(240, 80)
                                    success:^(UIImage *barCodeImage) {
                                        self.imageView5.image = barCodeImage;
                                    }];
```

* * 生成彩色条形码
```    
    [DDYQRCodeManager ddy_BarCodeWithString:@"123456789"
                                       size:CGSizeMake(240, 80)
                                      color:[UIColor redColor]
                                    bgColor:[UIColor blueColor]
                                    success:^(UIImage *barCodeImage) {
                                        self.imageView6.image = barCodeImage;
                                    }];
```                                    
                 
                 
#### 扫描    

 * 竖屏扫描

```
// 如果需要横屏请修改源码（横屏metadataOutput.rectOfInterest重新计算或全屏方式扫描），不建议添加横屏扫描
[self.qrcodeManager ddy_ScanQRCodeWithPreview:self.view effectiveRect:CGRectMake(DDYScanX, DDYScanY, DDYScanWH, DDYScanWH)];
```

 * 图片扫描

```
// 可以长按扫描或者相册选择扫描用
[self.qrcodeManager ddy_scanQRCodeWithImage:image]];
```

 * 原生imagePicker选择扫描

```
// 推荐使用TZImagePickerController回调中用图片扫描方式
 [self.qrcodeManager ddy_scanQRCodeWithImagePickerFromCurrentVC:self];
```

 * 扫描结果回调

```
// 需要遵循<DDYQRCodeManagerDelegate>,别设置 _qrcodeManager.delegate = self;
- (void)ddy_QRCodeScanResult:(NSString *)result scanError:(NSError *)scanError;
// 或者利用block (两者都设置优先delegate) scanResultBlock
```

#### 附加功能

 * 鉴定相机权限

```
[DDYQRCodeManager cameraAuthSuccess:^{ NSLog(@"这里可以添加扫描了");} fail:^{ NSLog(@"未授权时处理，例如弹窗/返回"); }];
```

 * 鉴定相册权限

```
[DDYQRCodeManager albumAuthSuccess:^{ NSLog(@"可以保存了");} fail:^{ NSLog(@"未授权时处理，例如弹窗"); }];
```

 * 扫描完毕播放音效

```
// 如果只让相机扫描有声音，图片扫描无声音可以将声音播放放到 -captureOutput:didOutputMetadataObjects:fromConnection:
[DDYQRCodeManager ddy_palySoundWithName:@"DDYQRCode.bundle/sound.caf"];
```

 * 光强检测

```
// delegate回调或者block,用来显隐补光灯开关，如果一直显示则可以不用光强检测
-ddy_QRCodeBrightnessValue：
.brightnessValueBlock
```

 * 补光灯

```
[DDYQRCodeManager ddy_turnOnTorchLight:(button.selected = !button.selected)];
```


