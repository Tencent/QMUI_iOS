//
//  QMUIKeyboardManager.m
//  qmui
//
//  Created by zhoonchen on 2017/3/23.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import "QMUIKeyboardManager.h"
#import "QMUICore.h"
#import "QMUILog.h"

// iOS 8 下当键盘已经升起的时候再聚焦另一个输入框，此时系统不会再发出键盘通知，导致一些逻辑不准确，这里修复系统这个 bug。iOS 9 及以后没问题。
// 对应的 issue：https://github.com/QMUI/QMUI_iOS/issues/348
static QMUIKeyboardManager *kKeyboardManagerInstance;

@interface QMUIKeyboardManager ()

@property(nonatomic, strong) NSMutableArray <NSValue *> *targetResponderValues;

@property(nonatomic, strong) QMUIKeyboardUserInfo *lastUserInfo;

@property(nonatomic, weak) UIResponder *currentResponder;
@property(nonatomic, weak) UIResponder *currentResponderWhenResign;

@property(nonatomic, assign) BOOL debug;

@end


@interface UIView (KeyboardManager)

- (id)qmui_findFirstResponder;

@end

@implementation UIView (KeyboardManager)

- (id)qmui_findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView qmui_findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

@end


@implementation UIResponder (KeyboardManager)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([self class], @selector(becomeFirstResponder), @selector(keyboardManager_becomeFirstResponder));
        ExchangeImplementations([self class], @selector(resignFirstResponder), @selector(keyboardManager_resignFirstResponder));
    });
}

- (BOOL)keyboardManager_becomeFirstResponder {
    self.keyboardManager_isFirstResponder = YES;
    if (@available(iOS 9.0, *)) {
        return [self keyboardManager_becomeFirstResponder];
    }
    
    // iOS 8 下如果键盘已经在显示的时候，另一个输入框被聚焦，升起键盘，此时系统不会再发键盘事件给你，但 iOS 9 及以后会发送，所以这里主动给输入框发送键盘事件
    // 对应这个 issue：https://github.com/QMUI/QMUI_iOS/issues/348
    BOOL isTextInputComponents = [self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]];
    BOOL isAlreadyFirstResponder = self.isFirstResponder;
    BOOL isKeyboardVisible = [QMUIKeyboardManager isKeyboardVisible];
    if (isTextInputComponents && !isAlreadyFirstResponder && isKeyboardVisible) {
        BOOL result = [self keyboardManager_becomeFirstResponder];
        if (result) {
            NSDictionary<NSString *, id> *userInfo = kKeyboardManagerInstance.lastUserInfo.notification.userInfo;
            [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillChangeFrameNotification object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillShowNotification object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidChangeFrameNotification object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidShowNotification object:self userInfo:userInfo];
        }
        return result;
    }
    return [self keyboardManager_becomeFirstResponder];
}

- (BOOL)keyboardManager_resignFirstResponder {
    self.keyboardManager_isFirstResponder = NO;
    if (self.isFirstResponder &&
        self.qmui_keyboardManager &&
        [self.qmui_keyboardManager.allTargetResponders containsObject:self]) {
        self.qmui_keyboardManager.currentResponderWhenResign = self;
    }
    return [self keyboardManager_resignFirstResponder];
}

- (void)setKeyboardManager_isFirstResponder:(BOOL)keyboardManager_isFirstResponder {
    objc_setAssociatedObject(self, @selector(keyboardManager_isFirstResponder), @(keyboardManager_isFirstResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)keyboardManager_isFirstResponder {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setQmui_keyboardManager:(QMUIKeyboardManager *)keyboardManager {
    objc_setAssociatedObject(self, @selector(qmui_keyboardManager), keyboardManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QMUIKeyboardManager *)qmui_keyboardManager {
    return objc_getAssociatedObject(self, _cmd);
}

@end


@interface QMUIKeyboardUserInfo ()

@property(nonatomic, weak, readwrite) QMUIKeyboardManager *keyboardManager;
@property(nonatomic, strong, readwrite) NSNotification *notification;
@property(nonatomic, weak, readwrite) UIResponder *targetResponder;
@property(nonatomic, assign) BOOL isTargetResponderFocused;

@property(nonatomic, assign, readwrite) CGFloat width;
@property(nonatomic, assign, readwrite) CGFloat height;

@property(nonatomic, assign, readwrite) CGRect beginFrame;
@property(nonatomic, assign, readwrite) CGRect endFrame;

@property(nonatomic, assign, readwrite) NSTimeInterval animationDuration;
@property(nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property(nonatomic, assign, readwrite) UIViewAnimationOptions animationOptions;

@end

@implementation QMUIKeyboardUserInfo

- (void)setNotification:(NSNotification *)notification {
    _notification = notification;
    if (self.originUserInfo) {
        _animationDuration = [[self.originUserInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        _animationCurve = (UIViewAnimationCurve)[[self.originUserInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        _animationOptions = self.animationCurve<<16;
        _beginFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        _endFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    }
}

- (void)setTargetResponder:(UIResponder *)targetResponder {
    _targetResponder = targetResponder;
    self.isTargetResponderFocused = targetResponder && targetResponder.keyboardManager_isFirstResponder;
}

- (NSDictionary *)originUserInfo {
    return self.notification ? self.notification.userInfo : nil;
}

- (CGFloat)width {
    CGRect keyboardRect = [QMUIKeyboardManager convertKeyboardRect:_endFrame toView:nil];
    return keyboardRect.size.width;
}

- (CGFloat)height {
    CGRect keyboardRect = [QMUIKeyboardManager convertKeyboardRect:_endFrame toView:nil];
    return keyboardRect.size.height;
}

- (CGFloat)heightInView:(UIView *)view {
    if (!view) {
        return [self height];
    }
    CGRect keyboardRect = [QMUIKeyboardManager convertKeyboardRect:_endFrame toView:view];
    CGRect visibleRect = CGRectIntersection(CGRectFlatted(view.bounds), CGRectFlatted(keyboardRect));
    if (!CGRectIsValidated(visibleRect)) {
        return 0;
    }
    return visibleRect.size.height;
}

- (CGRect)beginFrame {
    return _beginFrame;
}

- (CGRect)endFrame {
    return _endFrame;
}

- (NSTimeInterval)animationDuration {
    return _animationDuration;
}

- (UIViewAnimationCurve)animationCurve {
    return _animationCurve;
}

- (UIViewAnimationOptions)animationOptions {
    return _animationOptions;
}

@end


/**
 1. 系统键盘app启动第一次使用键盘的时候，会调用两轮键盘通知事件，之后就只会调用一次。而搜狗等第三方输入法的键盘，目前发现每次都会调用三次键盘通知事件。总之，键盘的通知事件是不确定的。

 2. 搜狗键盘可以修改键盘的高度，在修改键盘高度之后，会调用键盘的keyboardWillChangeFrameNotification和keyboardWillShowNotification通知。

 3. 如果从一个聚焦的输入框直接聚焦到另一个输入框，会调用前一个输入框的keyboardWillChangeFrameNotification，在调用后一个输入框的keyboardWillChangeFrameNotification，最后调用后一个输入框的keyboardWillShowNotification（如果此时是浮动键盘，那么后一个输入框的keyboardWillShowNotification不会被调用；）。

 4. iPad可以变成浮动键盘，固定->浮动：会调用keyboardWillChangeFrameNotification和keyboardWillHideNotification；浮动->固定：会调用keyboardWillChangeFrameNotification和keyboardWillShowNotification；浮动键盘在移动的时候只会调用keyboardWillChangeFrameNotification通知，并且endFrame为zero，fromFrame不为zero，而是移动前键盘的frame。浮动键盘在聚焦和失焦的时候只会调用keyboardWillChangeFrameNotification，不会调用show和hide的notification。

 5. iPad可以拆分为左右的小键盘，小键盘的通知具体基本跟浮动键盘一样。

 6. iPad可以外接键盘，外接键盘之后屏幕上就没有虚拟键盘了，但是当我们输入文字的时候，发现底部还是有一条灰色的候选词，条东西也是键盘，它也会触发跟虚拟键盘一样的通知事件。如果点击这条候选词右边的向下箭头，则可以完全隐藏虚拟键盘，这个时候如果失焦再聚焦发现还是没有这条候选词，也就是键盘完全不出来了，如果输入文字，候选词才会重新出来。总结来说就是这条候选词是可以关闭的，关闭之后只有当下次输入才会重新出现。（聚焦和失焦都只调用keyboardWillChangeFrameNotification和keyboardWillHideNotification通知，而且frame始终不变，都是在屏幕下面）

 7. iOS8 hide 之后高度变成0了，keyboardWillHideNotification还是正常的，所以建议不要使用键盘高度来做动画，而是用键盘的y值；在show和hide的时候endFrame会出现一些奇怪的中间值，但最终值是对的；两个输入框切换聚焦，iOS8不会触发任何键盘通知；iOS8的浮动切换正常；

 8. iOS8在 固定->浮动 的过程中，后面的keyboardWillChangeFrameNotification和keyboardWillHideNotification里面的endFrame是正确的，而iOS10和iOS9是错的，iOS9的y值是键盘的MaxY，而iOS10的y值是隐藏状态下的y，也就是屏幕高度。所以iOS9和iOS10需要在keyboardDidChangeFrameNotification里面重新刷新一下。
 */
@implementation QMUIKeyboardManager

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!kKeyboardManagerInstance) {
            kKeyboardManagerInstance = [[QMUIKeyboardManager alloc] initWithDelegate:nil];
        }
    });
}

- (instancetype)init {
    NSAssert(NO, @"请使用initWithDelegate:初始化");
    return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSAssert(NO, @"请使用initWithDelegate:初始化");
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id <QMUIKeyboardManagerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _delegateEnabled = YES;
        _targetResponderValues = [[NSMutableArray alloc] init];
        [self addKeyboardNotification];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)addTargetResponder:(UIResponder *)targetResponder {
    if (!targetResponder || ![targetResponder isKindOfClass:[UIResponder class]]) {
        return NO;
    }
    targetResponder.qmui_keyboardManager = self;
    [self.targetResponderValues addObject:[self packageTargetResponder:targetResponder]];
    return YES;
}

- (NSArray<UIResponder *> *)allTargetResponders {
    NSMutableArray *targetResponders = nil;
    for (int i = 0; i < self.targetResponderValues.count; i++) {
        if (!targetResponders) {
            targetResponders = [[NSMutableArray alloc] init];
        }
        id unPackageValue = [self unPackageTargetResponder:self.targetResponderValues[i]];
        if (unPackageValue && [unPackageValue isKindOfClass:[UIResponder class]]) {
            [targetResponders addObject:(UIResponder *)unPackageValue];
        }
    }
    return [targetResponders copy];
}

- (BOOL)removeTargetResponder:(UIResponder *)targetResponder {
    if (targetResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:targetResponder]]) {
        [self.targetResponderValues removeObject:[self packageTargetResponder:targetResponder]];
        return YES;
    }
    return NO;
}

- (NSValue *)packageTargetResponder:(UIResponder *)targetResponder {
    if (![targetResponder isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    return [NSValue valueWithNonretainedObject:targetResponder];
}

- (UIResponder *)unPackageTargetResponder:(NSValue *)value {
    if (!value) {
        return nil;
    }
    id unPackageValue = [value nonretainedObjectValue];
    if (![unPackageValue isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    return (UIResponder *)unPackageValue;
}

#pragma mark - Notification

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (BOOL)isAppActive:(NSNotification *)notification {
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return NO;
    }
    if (@available(iOS 9, *)) {
        if (![[notification.userInfo valueForKey:UIKeyboardIsLocalUserInfoKey] boolValue]) {
            return NO;
        }
    }
    return YES;
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    
    if (self.debug) {
        QMUILog(NSStringFromClass(self.class), @"keyboardWillShowNotification - %@", self);
    }
    
    if (![self isAppActive:notification]) {
        QMUILog(NSStringFromClass(self.class), @"app is not active");
        return;
    }
    
    if (![self shouldReceiveShowNotification]) {
        return;
    }
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillShowWithUserInfo:)]) {
        [self.delegate keyboardWillShowWithUserInfo:userInfo];
    }
}

- (void)keyboardDidShowNotification:(NSNotification *)notification {
    
    if (self.debug) {
        QMUILog(NSStringFromClass(self.class), @"keyboardDidShowNotification - %@", self);
    }
    
    if (![self isAppActive:notification]) {
        QMUILog(NSStringFromClass(self.class), @"app is not active");
        return;
    }
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    id firstResponder = [[UIApplication sharedApplication].keyWindow qmui_findFirstResponder];
    BOOL shouldReceiveDidShowNotification = self.targetResponderValues.count <= 0 || (firstResponder && firstResponder == self.currentResponder);
    
    if (shouldReceiveDidShowNotification) {
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidShowWithUserInfo:)]) {
            [self.delegate keyboardDidShowWithUserInfo:userInfo];
        }
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    
    if (self.debug) {
        QMUILog(NSStringFromClass(self.class), @"keyboardWillHideNotification - %@", self);
    }
    
    if (![self isAppActive:notification]) {
        QMUILog(NSStringFromClass(self.class), @"app is not active");
        return;
    }
    
    if (![self shouldReceiveHideNotification]) {
        return;
    }
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillHideWithUserInfo:)]) {
        [self.delegate keyboardWillHideWithUserInfo:userInfo];
    }
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
    
    if (self.debug) {
        QMUILog(NSStringFromClass(self.class), @"keyboardDidHideNotification - %@", self);
    }
    
    if (![self isAppActive:notification]) {
        QMUILog(NSStringFromClass(self.class), @"app is not active");
        return;
    }
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if ([self shouldReceiveHideNotification]) {
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidHideWithUserInfo:)]) {
            [self.delegate keyboardDidHideWithUserInfo:userInfo];
        }
    }
    
    if (self.currentResponder && !self.currentResponder.keyboardManager_isFirstResponder && !IS_IPAD) {
        self.currentResponder = nil;
    }
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    
    if (self.debug) {
        QMUILog(NSStringFromClass(self.class), @"keyboardWillChangeFrameNotification - %@", self);
    }
    
    if (![self isAppActive:notification]) {
        QMUILog(NSStringFromClass(self.class), @"app is not active");
        return;
    }
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    
    if ([self shouldReceiveShowNotification]) {
        userInfo.targetResponder = self.currentResponder ?: nil;
    } else if ([self shouldReceiveHideNotification]) {
        userInfo.targetResponder = self.currentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardWillChangeFrameWithUserInfo:userInfo];
    }
}

- (void)keyboardDidChangeFrameNotification:(NSNotification *)notification {
    
    if (self.debug) {
        QMUILog(NSStringFromClass(self.class), @"keyboardDidChangeFrameNotification - %@", self);
    }
    
    if (![self isAppActive:notification]) {
        QMUILog(NSStringFromClass(self.class), @"app is not active");
        return;
    }
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    
    if ([self shouldReceiveShowNotification]) {
        userInfo.targetResponder = self.currentResponder ?: nil;
    } else if ([self shouldReceiveHideNotification]) {
        userInfo.targetResponder = self.currentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardDidChangeFrameWithUserInfo:userInfo];
    }
}

- (QMUIKeyboardUserInfo *)newUserInfoWithNotification:(NSNotification *)notification {
    QMUIKeyboardUserInfo *userInfo = [[QMUIKeyboardUserInfo alloc] init];
    userInfo.keyboardManager = self;
    userInfo.notification = notification;
    return userInfo;
}

- (BOOL)shouldReceiveShowNotification {
    // 这里有BUG，如果点击了webview导致键盘下降，这个时候运行shouldReceiveHideNotification就会判断错误
    self.currentResponder = self.currentResponderWhenResign ?: [[UIApplication sharedApplication].keyWindow qmui_findFirstResponder];
    self.currentResponderWhenResign = nil;
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        return self.currentResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:self.currentResponder]];
    }
}

- (BOOL)shouldReceiveHideNotification {
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        if (self.currentResponder) {
            return [self.targetResponderValues containsObject:[self packageTargetResponder:self.currentResponder]];
        } else {
            return NO;
        }
    }
}

#pragma mark - 工具方法

+ (void)animateWithAnimated:(BOOL)animated keyboardUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:keyboardUserInfo.animationDuration delay:0 options:keyboardUserInfo.animationOptions|UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (animations) {
                animations();
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)handleKeyboardNotificationWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo showBlock:(void (^)(QMUIKeyboardUserInfo *keyboardUserInfo))showBlock hideBlock:(void (^)(QMUIKeyboardUserInfo *keyboardUserInfo))hideBlock {
    // 专门处理 iPad Pro 在键盘完全不显示的情况（不会调用willShow，所以通过是否focus来判断）
    // iPhoneX Max 这里键盘高度不是0，而是一个很小的值
    if ([QMUIKeyboardManager visibleKeyboardHeight] <= 0 && !keyboardUserInfo.isTargetResponderFocused) {
        if (hideBlock) {
            hideBlock(keyboardUserInfo);
        }
    } else {
        if (showBlock) {
            showBlock(keyboardUserInfo);
        }
    }
}

+ (UIWindow *)keyboardWindow {
    
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([self getKeyboardViewFromWindow:window]) {
            return window;
        }
    }
    
    NSMutableArray *kbWindows = nil;
    
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        NSString *windowName = NSStringFromClass(window.class);
        if (IOS_VERSION < 9) {
            // UITextEffectsWindow
            if (windowName.length == 19 &&
                [windowName hasPrefix:@"UI"] &&
                [windowName hasSuffix:[NSString stringWithFormat:@"%@%@", @"TextEffects", @"Window"]]) {
                if (!kbWindows) kbWindows = [NSMutableArray new];
                [kbWindows addObject:window];
            }
        } else {
            // UIRemoteKeyboardWindow
            if (windowName.length == 22 &&
                [windowName hasPrefix:@"UI"] &&
                [windowName hasSuffix:[NSString stringWithFormat:@"%@%@", @"Remote", @"KeyboardWindow"]]) {
                if (!kbWindows) kbWindows = [NSMutableArray new];
                [kbWindows addObject:window];
            }
        }
    }
    
    if (kbWindows.count == 1) {
        return kbWindows.firstObject;
    }
    
    return nil;
}

+ (CGRect)convertKeyboardRect:(CGRect)rect toView:(UIView *)view {
    
    if (CGRectIsNull(rect) || CGRectIsInfinite(rect)) {
        return rect;
    }
    
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
    if (!mainWindow) {
        if (view) {
            [view convertRect:rect fromView:nil];
        } else {
            return rect;
        }
    }
    
    rect = [mainWindow convertRect:rect fromWindow:nil];
    if (!view) {
        return [mainWindow convertRect:rect toWindow:nil];
    }
    if (view == mainWindow) {
        return rect;
    }
    
    UIWindow *toWindow = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!mainWindow || !toWindow) {
        return [mainWindow convertRect:rect toView:view];
    }
    if (mainWindow == toWindow) {
        return [mainWindow convertRect:rect toView:view];
    }
    
    rect = [mainWindow convertRect:rect toView:mainWindow];
    rect = [toWindow convertRect:rect fromWindow:mainWindow];
    rect = [view convertRect:rect fromView:toWindow];
    
    return rect;
}

+ (CGFloat)distanceFromMinYToBottomInView:(UIView *)view keyboardRect:(CGRect)rect {
    rect = [self convertKeyboardRect:rect toView:view];
    CGFloat distance = CGRectGetHeight(CGRectFlatted(view.bounds)) - CGRectGetMinY(rect);
    return distance;
}

+ (UIView *)keyboardView {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        UIView *view = [self getKeyboardViewFromWindow:window];
        if (view) {
            return view;
        }
    }
    return nil;
}

+ (UIView *)getKeyboardViewFromWindow:(UIWindow *)window {
    
    if (!window) return nil;
    
    NSString *windowName = NSStringFromClass(window.class);
    if (IOS_VERSION < 9) {
        if (![windowName isEqualToString:@"UITextEffectsWindow"]) {
            return nil;
        }
    } else {
        if (![windowName isEqualToString:@"UIRemoteKeyboardWindow"]) {
            return nil;
        }
    }
    
    for (UIView *view in window.subviews) {
        NSString *viewName = NSStringFromClass(view.class);
        if (![viewName isEqualToString:@"UIInputSetContainerView"]) {
            continue;
        }
        
        for (UIView *subView in view.subviews) {
            NSString *subViewName = NSStringFromClass(subView.class);
            if (![subViewName isEqualToString:@"UIInputSetHostView"]) {
                continue;
            }
            return subView;
        }
    }
    
    return nil;
}

+ (BOOL)isKeyboardVisible {
    UIView *keyboardView = self.keyboardView;
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return NO;
    }
    CGRect rect = CGRectIntersection(CGRectFlatted(keyboardWindow.bounds), CGRectFlatted(keyboardView.frame));
    if (CGRectIsValidated(rect) && !CGRectIsEmpty(rect)) {
        return YES;
    }
    return NO;
}

+ (CGRect)currentKeyboardFrame {
    UIView *keyboardView = [self keyboardView];
    if (!keyboardView) {
        return CGRectNull;
    }
    UIWindow *keyboardWindow = keyboardView.window;
    if (keyboardWindow) {
        return [keyboardWindow convertRect:CGRectFlatted(keyboardView.frame) toWindow:nil];
    } else {
        return CGRectFlatted(keyboardView.frame);
    }
}

+ (CGFloat)visibleKeyboardHeight {
    UIView *keyboardView = [self keyboardView];
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return 0;
    } else {
        CGRect visibleRect = CGRectIntersection(CGRectFlatted(keyboardWindow.bounds), CGRectFlatted(keyboardView.frame));
        if (CGRectIsValidated(visibleRect)) {
            return CGRectGetHeight(visibleRect);
        }
        return 0;
    }
}

@end

#pragma mark - UITextField

@interface UITextField () <QMUIKeyboardManagerDelegate>

@end

@implementation UITextField (QMUI_KeyboardManager)

- (void)setQmui_keyboardWillShowNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillShowNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillShowNotificationBlock), keyboardWillShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillShowNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidShowNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidShowNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidShowNotificationBlock), keyboardDidShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidShowNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardWillHideNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillHideNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillHideNotificationBlock), keyboardWillHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillHideNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidHideNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidHideNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidHideNotificationBlock), keyboardDidHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidHideNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardWillChangeFrameNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillChangeFrameNotificationBlock), keyboardWillChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillChangeFrameNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidChangeFrameNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidChangeFrameNotificationBlock), keyboardDidChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidChangeFrameNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)initKeyboardManagerIfNeeded {
    if (!self.qmui_keyboardManager) {
        self.qmui_keyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:self];
        [self.qmui_keyboardManager addTargetResponder:self];
    }
}

#pragma mark - <QMUIKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillShowNotificationBlock) {
        self.qmui_keyboardWillShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillHideNotificationBlock) {
        self.qmui_keyboardWillHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillChangeFrameNotificationBlock) {
        self.qmui_keyboardWillChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidShowNotificationBlock) {
        self.qmui_keyboardDidShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidHideNotificationBlock) {
        self.qmui_keyboardDidHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidChangeFrameNotificationBlock) {
        self.qmui_keyboardDidChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

@end

#pragma mark - UITextView

@interface UITextView () <QMUIKeyboardManagerDelegate>

@end

@implementation UITextView (QMUI_KeyboardManager)

- (void)setQmui_keyboardWillShowNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillShowNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillShowNotificationBlock), keyboardWillShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillShowNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidShowNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidShowNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidShowNotificationBlock), keyboardDidShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidShowNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardWillHideNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillHideNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillHideNotificationBlock), keyboardWillHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillHideNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidHideNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidHideNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidHideNotificationBlock), keyboardDidHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidHideNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardWillChangeFrameNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillChangeFrameNotificationBlock), keyboardWillChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillChangeFrameNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidChangeFrameNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidChangeFrameNotificationBlock), keyboardDidChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidChangeFrameNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)initKeyboardManagerIfNeeded {
    if (!self.qmui_keyboardManager) {
        self.qmui_keyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:self];
        [self.qmui_keyboardManager addTargetResponder:self];
    }
}

#pragma mark - <QMUIKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillShowNotificationBlock) {
        self.qmui_keyboardWillShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillHideNotificationBlock) {
        self.qmui_keyboardWillHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillChangeFrameNotificationBlock) {
        self.qmui_keyboardWillChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidShowNotificationBlock) {
        self.qmui_keyboardDidShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidHideNotificationBlock) {
        self.qmui_keyboardDidHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidChangeFrameNotificationBlock) {
        self.qmui_keyboardDidChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

@end
