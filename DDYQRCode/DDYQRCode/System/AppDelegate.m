//                       .::::.
//                     .::::::::.
//                    :::::::::::
//                 ..:::::::::::'
//              '::::::::::::'
//                .::::::::::
//           '::::::::::::::..
//                ..::::::::::::.
//              ``::::::::::::::::
//               ::::``:::::::::'        .:::.
//              ::::'   ':::::'       .::::::::.
//            .::::'      ::::     .:::::::'::::.
//           .:::'       :::::  .:::::::::' ':::::.
//          .::'        :::::.:::::::::'      ':::::.
//         .::'         ::::::::::::::'         ``::::.
//     ...:::           ::::::::::::'              ``::.
//    ```` ':.          ':::::::::'                  ::::..
//                       '.:::::'                    ':'````..
//
#import "AppDelegate.h"
#import "ViewController.h"

@implementation DDYNavigationController

#pragma mark - 控制旋转屏幕
#pragma mark 支持旋转的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    return appDelegate.myAutorotate ? [self.topViewController supportedInterfaceOrientations] : UIInterfaceOrientationMaskPortrait;
}
#pragma mark 是否支持自动旋转
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setRootViewController:[[DDYNavigationController alloc] initWithRootViewController:[[ViewController alloc] init]]];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"%s", __FUNCTION__);
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"%s", __FUNCTION__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"%s", __FUNCTION__);
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%s", __FUNCTION__);
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark 部分页面横屏
- (void)ddy_ShouldAutorotate:(BOOL)myAutorotate myOrientation:(UIInterfaceOrientation)myOrientation {
    _myAutorotate = myAutorotate;
    _myOrientation = myOrientation;
    if (!_myAutorotate && [[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setArgument:&myOrientation atIndex:2];
        [invocation invoke];
    }
    [UIViewController attemptRotationToDeviceOrientation];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (_myAutorotate) {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
            return UIInterfaceOrientationMaskLandscapeLeft;
        } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
            return UIInterfaceOrientationMaskLandscapeRight;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    } else {
        if (_myOrientation == UIInterfaceOrientationLandscapeRight) {
            return UIInterfaceOrientationMaskLandscapeRight;
        } else if (_myOrientation == UIInterfaceOrientationLandscapeLeft) {
            return UIInterfaceOrientationMaskLandscapeLeft;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}

@end
