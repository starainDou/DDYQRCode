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

