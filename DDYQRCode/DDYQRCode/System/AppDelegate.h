//
//  AppDelegate.h
//  DDYQRCode
//
//  Created by SmartMesh on 2018/5/25.
//  Copyright © 2018年 com.smartmesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDYNavigationController : UINavigationController

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** 是否允许旋转 */ 
@property (nonatomic, assign, readonly) BOOL myAutorotate;
/** 屏幕方向 */
@property (nonatomic, assign, readonly) UIInterfaceOrientation myOrientation;

- (void)ddy_ShouldAutorotate:(BOOL)autorotate myOrientation:(UIInterfaceOrientation)myOrientation;

@end

