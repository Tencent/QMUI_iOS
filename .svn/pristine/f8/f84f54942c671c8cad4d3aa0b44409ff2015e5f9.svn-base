//
//  QMUIHelper.m
//  qmui
//
//  Created by QQMail on 14/10/25.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUIHelper.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "UIViewController+QMUI.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+QMUI.h"


NSString *const QMUIResourcesMainBundleName = @"QMUIResources.bundle";
NSString *const QMUIResourcesQQEmotionBundleName = @"QMUI_QQEmotion.bundle";

@implementation QMUIHelper (Bundle)

+ (NSBundle *)resourcesBundle {
    return [QMUIHelper resourcesBundleWithName:QMUIResourcesMainBundleName];
}

+ (NSBundle *)resourcesBundleWithName:(NSString *)bundleName {
    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundleName]];
    if (!bundle) {
        // 动态framework的bundle资源是打包在framework里面的，所以无法通过mainBundle拿到资源，只能通过其他方法来获取bundle资源。
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
        NSDictionary *bundleData = [self parseBundleName:bundleName];
        if (bundleData) {
            bundle = [NSBundle bundleWithPath:[frameworkBundle pathForResource:[bundleData objectForKey:@"name"] ofType:[bundleData objectForKey:@"type"]]];
        }
    }
    return bundle;
}

+ (UIImage *)imageWithName:(NSString *)name {
    NSBundle *bundle = [QMUIHelper resourcesBundle];
    return [QMUIHelper imageInBundle:bundle withName:name];
}

+ (UIImage *)imageInBundle:(NSBundle *)bundle withName:(NSString *)name {
    if (bundle && name) {
        if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
            return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
        } else {
            NSString *imagePath = [[bundle resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
            return [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    return nil;
}

+ (NSDictionary *)parseBundleName:(NSString *)bundleName {
    NSArray *bundleData = [bundleName componentsSeparatedByString:@"."];
    if (bundleData.count == 2) {
        return @{@"name":bundleData[0], @"type":bundleData[1]};
    }
    return nil;
}

@end


@implementation QMUIHelper (DynamicType)

+ (NSNumber *)preferredContentSizeLevel {
    NSNumber *index = nil;
    if ([UIApplication instancesRespondToSelector:@selector(preferredContentSizeCategory)]) {
        NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
        if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraSmall]) {
            index = [NSNumber numberWithInt:0];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategorySmall]) {
            index = [NSNumber numberWithInt:1];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryMedium]) {
            index = [NSNumber numberWithInt:2];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryLarge]) {
            index = [NSNumber numberWithInt:3];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraLarge]) {
            index = [NSNumber numberWithInt:4];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
            index = [NSNumber numberWithInt:5];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
            index = [NSNumber numberWithInt:6];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityMedium]) {
            index = [NSNumber numberWithInt:6];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityLarge]) {
            index = [NSNumber numberWithInt:6];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraLarge]) {
            index = [NSNumber numberWithInt:6];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraLarge]) {
            index = [NSNumber numberWithInt:6];
        } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge]) {
            index = [NSNumber numberWithInt:6];
        } else{
            index = [NSNumber numberWithInt:6];
        }
    } else {
        index = [NSNumber numberWithInt:3];
    }
    
    return index;
}

+ (CGFloat)heightForDynamicTypeCell:(NSArray *)heights {
    NSNumber *index = [QMUIHelper preferredContentSizeLevel];
    return [((NSNumber *)[heights objectAtIndex:[index intValue]]) floatValue];
}
@end

@implementation QMUIHelper (Keyboard)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:[self sharedInstance] selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:[self sharedInstance] selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    });
}

- (void)handleKeyboardWillShow:(NSNotification *)notification {
    self.keyboardVisible = YES;
    self.lastKeyboardHeight = [QMUIHelper keyboardHeightWithNotification:notification];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
    self.keyboardVisible = NO;
}

static char kAssociatedObjectKey_KeyboardVisible;
- (void)setKeyboardVisible:(BOOL)argv {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_KeyboardVisible, @(argv), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isKeyboardVisible {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_KeyboardVisible)) boolValue];
}

+ (BOOL)isKeyboardVisible {
    BOOL visible = [[QMUIHelper sharedInstance] isKeyboardVisible];
    return visible;
}

static char kAssociatedObjectKey_LastKeyboardHeight;
- (void)setLastKeyboardHeight:(CGFloat)argv {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_LastKeyboardHeight, @(argv), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lastKeyboardHeight {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_LastKeyboardHeight)) floatValue];
}

+ (CGFloat)lastKeyboardHeightInApplicationWindowWhenVisible {
    return [[QMUIHelper sharedInstance] lastKeyboardHeight];
}

+ (CGRect)keyboardRectWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 注意iOS8以下的系统在横屏时得到的rect，宽度和高度相反了，所以不建议直接通过这个方法获取高度，而是使用<code>keyboardHeightWithNotification:inView:</code>，因为在后者的实现里会将键盘的rect转换坐标系，转换过程就会处理横竖屏旋转问题。
    return keyboardRect;
}

+ (CGFloat)keyboardHeightWithNotification:(NSNotification *)notification {
    return [QMUIHelper keyboardHeightWithNotification:notification inView:nil];
}

+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification inView:(nullable UIView *)view {
    CGRect keyboardRect = [self keyboardRectWithNotification:notification];
    if (!view) {
        return CGRectGetHeight(keyboardRect);
    }
    CGRect keyboardRectInView = [view convertRect:keyboardRect fromView:view.window];
    CGRect keyboardVisibleRectInView = CGRectIntersection(view.bounds, keyboardRectInView);
    CGFloat resultHeight = CGRectIsNull(keyboardVisibleRectInView) ? 0.0f : CGRectGetHeight(keyboardVisibleRectInView);
    return resultHeight;
}

+ (NSTimeInterval)keyboardAnimationDurationWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    return animationDuration;
}

+ (UIViewAnimationCurve)keyboardAnimationCurveWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    return curve;
}

+ (UIViewAnimationOptions)keyboardAnimationOptionsWithNotification:(NSNotification *)notification {
    UIViewAnimationOptions options = [QMUIHelper keyboardAnimationCurveWithNotification:notification]<<16;
    return options;
}

@end


@implementation QMUIHelper (AudioSession)

+ (void)redirectAudioRouteWithSpeaker:(BOOL)speaker temporary:(BOOL)temporary {
    if (![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        return;
    }
    if (temporary) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:speaker ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:[AVAudioSession sharedInstance].category withOptions:speaker ? AVAudioSessionCategoryOptionDefaultToSpeaker : 0 error:nil];
    }
}

+ (void)setAudioSessionCategory:(nullable NSString *)category {
    
    // 如果不属于系统category，返回
    if (category != AVAudioSessionCategoryAmbient &&
        category != AVAudioSessionCategorySoloAmbient &&
        category != AVAudioSessionCategoryPlayback &&
        category != AVAudioSessionCategoryRecord &&
        category != AVAudioSessionCategoryPlayAndRecord &&
        category != AVAudioSessionCategoryAudioProcessing)
    {
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:category error:nil];
}

+ (UInt32)categoryForLowVersionWithCategory:(NSString *)category {
    if ([category isEqualToString:AVAudioSessionCategoryAmbient]) {
        return kAudioSessionCategory_AmbientSound;
    }
    if ([category isEqualToString:AVAudioSessionCategorySoloAmbient]) {
        return kAudioSessionCategory_SoloAmbientSound;
    }
    if ([category isEqualToString:AVAudioSessionCategoryPlayback]) {
        return kAudioSessionCategory_MediaPlayback;
    }
    if ([category isEqualToString:AVAudioSessionCategoryRecord]) {
        return kAudioSessionCategory_RecordAudio;
    }
    if ([category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        return kAudioSessionCategory_PlayAndRecord;
    }
    if ([category isEqualToString:AVAudioSessionCategoryAudioProcessing]) {
        return kAudioSessionCategory_AudioProcessing;
    }
    return kAudioSessionCategory_AmbientSound;
}

@end


@implementation QMUIHelper (UIGraphic)

static CGFloat pixelOne = -1.0f;
+ (CGFloat)pixelOne {
    if (pixelOne < 0) {
        pixelOne = 1 / [[UIScreen mainScreen] scale];
    }
    return pixelOne;
}

+ (void)inspectContextSize:(CGSize)size {
    if (size.width < 0 || size.height < 0) {
        NSAssert(NO, @"QMUI CGPostError, %@:%d %s, 非法的size：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, NSStringFromCGSize(size), [NSThread callStackSymbols]);
    }
}

+ (void)inspectContextIfInvalidatedInDebugMode:(CGContextRef)context {
    if (!context) {
        // crash了就找zhoon或者molice
        NSAssert(NO, @"QMUI CGPostError, %@:%d %s, 非法的context：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, context, [NSThread callStackSymbols]);
    }
}

+ (BOOL)inspectContextIfInvalidatedInReleaseMode:(CGContextRef)context {
    if (context) {
        return YES;
    }
    return NO;
}

@end

@implementation QMUIHelper (Device)

static NSInteger isIPad = -1;
+ (BOOL)isIPad {
    if (isIPad < 0) {
        // [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] 无法判断模拟器，改为以下方式
        isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0;
    }
    return isIPad > 0;
}

static NSInteger isIPadPro = -1;
+ (BOOL)isIPadPro {
    if (isIPadPro < 0) {
        isIPadPro = [QMUIHelper isIPad] ? (DEVICE_WIDTH == 1024 && DEVICE_HEIGHT == 1366 ? 1 : 0) : 0;
    }
    return isIPadPro > 0;
}

static NSInteger isIPod = -1;
+ (BOOL)isIPod {
    if (isIPod < 0) {
        isIPod = [[[UIDevice currentDevice] model] qmui_includesString:@"iPod touch"] ? 1 : 0;
    }
    return isIPod > 0;
}

static NSInteger isIPhone = -1;
+ (BOOL)isIPhone {
    if (isIPhone < 0) {
        isIPhone = [[[UIDevice currentDevice] model] qmui_includesString:@"iPhone"] ? 1 : 0;
    }
    return isIPhone > 0;
}

static NSInteger isSimulator = -1;
+ (BOOL)isSimulator {
    if (isSimulator < 0) {
#if TARGET_OS_SIMULATOR
        isSimulator = 1;
#else
        isSimulator = 0;
#endif
    }
    return isSimulator > 0;
}

static NSInteger is55InchScreen = -1;
+ (BOOL)is55InchScreen {
    if (is55InchScreen < 0) {
        is55InchScreen = (DEVICE_WIDTH == self.screenSizeFor55Inch.width && DEVICE_HEIGHT == self.screenSizeFor55Inch.height) ? 1 : 0;
    }
    return is55InchScreen > 0;
}

static NSInteger is47InchScreen = -1;
+ (BOOL)is47InchScreen {
    if (is47InchScreen < 0) {
        is47InchScreen = (DEVICE_WIDTH == self.screenSizeFor47Inch.width && DEVICE_HEIGHT == self.screenSizeFor47Inch.height) ? 1 : 0;
    }
    return is47InchScreen > 0;
}

static NSInteger is40InchScreen = -1;
+ (BOOL)is40InchScreen {
    if (is40InchScreen < 0) {
        is40InchScreen = (DEVICE_WIDTH == self.screenSizeFor40Inch.width && DEVICE_HEIGHT == self.screenSizeFor40Inch.height) ? 1 : 0;
    }
    return is40InchScreen > 0;
}

static NSInteger is35InchScreen = -1;
+ (BOOL)is35InchScreen {
    if (is35InchScreen < 0) {
        is35InchScreen = (DEVICE_WIDTH == self.screenSizeFor35Inch.width && DEVICE_HEIGHT == self.screenSizeFor35Inch.height) ? 1 : 0;
    }
    return is35InchScreen > 0;
}

+ (CGSize)screenSizeFor55Inch {
    return CGSizeMake(414, 736);
}

+ (CGSize)screenSizeFor47Inch {
    return CGSizeMake(375, 667);
}

+ (CGSize)screenSizeFor40Inch {
    return CGSizeMake(320, 568);
}

+ (CGSize)screenSizeFor35Inch {
    return CGSizeMake(320, 480);
}

static NSInteger isHighPerformanceDevice = -1;
+ (BOOL)isHighPerformanceDevice {
    if (isHighPerformanceDevice < 0) {
        isHighPerformanceDevice = (IOS_VERSION >= 8.0 && PreferredVarForUniversalDevices(YES, YES, YES, NO, NO)) ? 1 : 0;
    }
    return isHighPerformanceDevice > 0;
}

@end

@implementation QMUIHelper (Orientation)

+ (CGFloat)angleForTransformWithInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGFloat angle;
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    return angle;
}

+ (CGAffineTransform)transformForCurrentInterfaceOrientation {
    return [QMUIHelper transformWithInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

+ (CGAffineTransform)transformWithInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGFloat angle = [QMUIHelper angleForTransformWithInterfaceOrientation:orientation];
    return CGAffineTransformMakeRotation(angle);
}

@end

@implementation QMUIHelper (ViewController)

+ (nullable UIViewController *)visibleViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *visibleViewController = [rootViewController qmui_visibleViewControllerIfExist];
    return visibleViewController;
}

@end

@implementation QMUIHelper (UIApplication)

+ (void)renderStatusBarStyleDark {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

+ (void)renderStatusBarStyleLight {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

+ (void)dimmedApplicationWindow {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    window.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    [window tintColorDidChange];
}

+ (void)resetDimmedApplicationWindow {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    window.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    [window tintColorDidChange];
}

@end

NSString *const QMUISpringAnimationKey = @"QMUISpringAnimationKey";

@implementation QMUIHelper (Animation)

+ (void)actionSpringAnimationForView:(UIView *)view {
    NSTimeInterval duration = 0.6;
    CAKeyframeAnimation *springAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    springAnimation.values = @[@.85, @1.15, @.9, @1.0,];
    springAnimation.keyTimes = @[@(0.0 / duration), @(0.15 / duration) , @(0.3 / duration), @(0.45 / duration),];
    springAnimation.duration = duration;
    [view.layer addAnimation:springAnimation forKey:QMUISpringAnimationKey];
}

@end

@implementation QMUIHelper (Log)

- (void)printLogWithCalledFunction:(nonnull const char *)func log:(nonnull NSString *)log, ... {
    va_list args;
    va_start(args, log);
    NSString *logString = [[NSString alloc] initWithFormat:log arguments:args];
    if ([self.helperDelegate respondsToSelector:@selector(QMUIHelperPrintLog:)]) {
        [self.helperDelegate QMUIHelperPrintLog:[NSString stringWithFormat:@"QMUI - %@. Called By %s", logString, func]];
    } else {
        NSLog(@"QMUI - %@. Called By %s", logString, func);
    }
    va_end(args);
}

@end

@implementation QMUIHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static QMUIHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        // 先设置默认值，不然可能变量的指针地址错误
        instance.keyboardVisible = NO;
        instance.lastKeyboardHeight = 0;
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)dealloc {
    // QMUIHelper (Keyboard)里用到消息监听，所以在dealloc的时候注销一下
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
