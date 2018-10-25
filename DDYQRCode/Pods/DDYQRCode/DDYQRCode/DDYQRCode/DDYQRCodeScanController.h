/** MARK: - DDYQRCodeManager 2018/10/23
 *  !!!: Author: 豆电雨
 *  !!!: QQ/WX:  634778311
 *  !!!: Github: https://github.com/RainOpen/
 *  !!!: Blog:   https://www.jianshu.com/u/a4bc2516e9e5
 *  MARK: - 二维码扫描控制器 当不能满足实际需求时可以自定义一个控制器，然后直接使用DDYQRCodeManager
 */

#import <UIKit/UIKit.h>
#import "DDYQRCodeScanView.h"
#import "DDYQRCodeManager.h"
#import "DDYQRCodeResultController.h"

@protocol DDYQRCodeScanDelegate <NSObject>
@required
/** 扫描结果delegate */
- (void)ddy_QRCodeScanResult:(NSString *)result scanError:(NSError *)scanError scanVC:(UIViewController *)scanVC;

@end

@interface DDYQRCodeScanController : UIViewController
/** delegate 优先代理 */
@property (nonatomic, weak) id <DDYQRCodeScanDelegate> delegate;
/** 扫描结果block 优先代理 */
@property (nonatomic, copy) void (^scanResultBlock)(NSString *resultStr, NSError *scanError, UIViewController *scanVC);

/** 扫描样式 默认DDYQRCodeScanViewStyleLine */
@property (nonatomic, assign) DDYQRCodeScanViewStyle style;
/** 有效区域是否只限扫描框内 默认全屏范围 */
@property (nonatomic, assign) BOOL isEffectRectOnlyInScanview;

@end
