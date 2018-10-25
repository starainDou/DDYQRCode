/** MARK: - DDYAuthManager 2018/10/23
 *  !!!: Author: 豆电雨
 *  !!!: QQ/WX:  634778311
 *  !!!: Github: https://github.com/RainOpen/
 *  !!!: Blog:   https://www.jianshu.com/u/a4bc2516e9e5
 *  MARK: - NSBundle+DDYQRCode.m
 */

#import "NSBundle+DDYQRCode.h"
#import "DDYQRCodeManager.h"

@implementation NSBundle (DDYQRCode)

+ (NSBundle *)ddyQRCodeBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[DDYQRCodeManager class]];
    return [NSBundle bundleWithURL:[bundle URLForResource:@"DDYQRCode" withExtension:@"bundle"]];
}

+ (NSString *)ddyLocalizedStringForKey:(NSString *)key {
    return [self ddyLocalizedStringForKey:key value:@""];
}

+ (NSString *)ddyLocalizedStringForKey:(NSString *)key value:(NSString *)value {
    static NSBundle *bundle = nil;
    if (!bundle) {
        NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"DDYLanguages"];
        if (!language) language = [NSLocale preferredLanguages].firstObject;
        if ([language containsString:@"zh-Hans"]) {
            language = @"zh-Hans";
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle ddyQRCodeBundle] pathForResource:language ofType:@"lproj"]];
    }
    return [bundle localizedStringForKey:key value:value table:@"DDYQRCode"];
}

+ (UIImage *)ddyImage:(NSString *)imageName {
    return [UIImage imageWithContentsOfFile:[[NSBundle ddyQRCodeBundle] pathForResource:imageName ofType:@"png"]];
}

@end
