/** MARK: - DDYQRCodeManager 2018/10/23
 *  !!!: Author: 豆电雨
 *  !!!: QQ/WX:  634778311
 *  !!!: Github: https://github.com/RainOpen/
 *  !!!: Blog:   https://www.jianshu.com/u/a4bc2516e9e5
 *  MARK: - 二维码镂空框部分(边角、扫描线)
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DDYQRCodeScanViewStyle) {
    DDYQRCodeScanViewStyleLine, // 单线样式
    DDYQRCodeScanViewStyleGrid, // 网格样式
};

@interface DDYQRCodeScanView : UIView
/** 扫描样式 */
@property (nonatomic, assign) DDYQRCodeScanViewStyle style;

@end
