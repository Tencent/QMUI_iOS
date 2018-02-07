//
//  QMUIKeyboardManager.m
//  qmui
//
//  Created by zhoonchen on 2017/3/23.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import "QMUIKeyboardManager.h"
#import "QMUICommonDefines.h"
#import "QMUIHelper.h"


@interface UIView (KeyboardManager)

- (id)km_findFirstResponder;

@end

@implementation UIView (KeyboardManager)

- (id)km_findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView km_findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

@end


@interface UIResponder (KeyboardManager)

// 系统自己的isFirstResponder有延迟，这里手动记录UIResponder是否isFirstResponder
@property(nonatomic, assign) BOOL km_isFirstResponder;

@end

@implementation UIResponder (KeyboardManager)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(becomeFirstResponder), @selector(km_becomeFirstResponder));
        ReplaceMethod([self class], @selector(resignFirstResponder), @selector(km_resignFirstResponder));
    });
}

- (BOOL)km_becomeFirstResponder {
    self.km_isFirstResponder = YES;
    return [self km_becomeFirstResponder];
}

- (BOOL)km_resignFirstResponder {
    self.km_isFirstResponder = NO;
    return [self km_resignFirstResponder];
}

- (void)setKm_isFirstResponder:(BOOL)km_isFirstResponder {
    objc_setAssociatedObject(self, @selector(km_isFirstResponder), @(km_isFirstResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)km_isFirstResponder {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
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
    self.isTargetResponderFocused = targetResponder && targetResponder.km_isFirstResponder;
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
    CGRect visiableRect = CGRectIntersection(view.bounds, keyboardRect);
    if (CGRectIsNull(visiableRect)) {
        return 0;
    }
    return visiableRect.size.height;
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


@interface QMUIKeyboardViewFrameObserver : NSObject

@property (nonatomic, copy) void (^keyboardViewChangeFrameBlock)(UIView *keyboardView);
- (void)addToKeyboardView:(UIView *)keyboardView;
+ (instancetype)observerForView:(UIView *)keyboardView;

@end

static char kAssociatedObjectKey_KeyboardViewFrameObserver;

@implementation QMUIKeyboardViewFrameObserver {
    __unsafe_unretained UIView *_keyboardView;
}

- (void)addToKeyboardView:(UIView *)keyboardView {
    if (_keyboardView == keyboardView) {
        return;
    }
    if (_keyboardView) {
        [self removeFrameObserver];
        objc_setAssociatedObject(_keyboardView, &kAssociatedObjectKey_KeyboardViewFrameObserver, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _keyboardView = keyboardView;
    if (keyboardView) {
        [self addFrameObserver];
    }
    objc_setAssociatedObject(keyboardView, &kAssociatedObjectKey_KeyboardViewFrameObserver, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addFrameObserver {
    if (!_keyboardView) {
        return;
    }
    [_keyboardView addObserver:self forKeyPath:@"frame" options:kNilOptions context:NULL];
    [_keyboardView addObserver:self forKeyPath:@"center" options:kNilOptions context:NULL];
    [_keyboardView addObserver:self forKeyPath:@"bounds" options:kNilOptions context:NULL];
    [_keyboardView addObserver:self forKeyPath:@"transform" options:kNilOptions context:NULL];
}

- (void)removeFrameObserver {
    [_keyboardView removeObserver:self forKeyPath:@"frame"];
    [_keyboardView removeObserver:self forKeyPath:@"center"];
    [_keyboardView removeObserver:self forKeyPath:@"bounds"];
    [_keyboardView removeObserver:self forKeyPath:@"transform"];
    _keyboardView = nil;
}

- (void)dealloc {
    [self removeFrameObserver];
}

+ (instancetype)observerForView:(UIView *)keyboardView {
    if (!keyboardView) {
        return nil;
    }
    return objc_getAssociatedObject(keyboardView, &kAssociatedObjectKey_KeyboardViewFrameObserver);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![keyPath isEqualToString:@"frame"] &&
        ![keyPath isEqualToString:@"center"] &&
        ![keyPath isEqualToString:@"bounds"] &&
        ![keyPath isEqualToString:@"transform"]) {
        return;
    }
    if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
        return;
    }
    if ([[change objectForKey:NSKeyValueChangeKindKey] integerValue] != NSKeyValueChangeSetting) {
        return;
    }
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) { newValue = nil; }
    if (self.keyboardViewChangeFrameBlock) {
        self.keyboardViewChangeFrameBlock(_keyboardView);
    }
}

@end


@interface QMUIKeyboardManager ()

@property(nonatomic, strong) NSMutableArray <NSValue *> *targetResponderValues;

@property(nonatomic, strong) QMUIKeyboardUserInfo *keyboardMoveUserInfo;
@property(nonatomic, assign) CGRect keyboardMoveBeginRect;

@end

static UIResponder *kCurrentResponder = nil;

@implementation QMUIKeyboardManager

// 1、系统键盘app启动第一次使用键盘的时候，会调用两轮键盘通知事件，之后就只会调用一次。而搜狗等第三方输入法的键盘，目前发现每次都会调用三次键盘通知事件。总之，键盘的通知事件是不确定的。

// 2、搜狗键盘可以修改键盘的高度，在修改键盘高度之后，会调用键盘的keyboardWillChangeFrameNotification和keyboardWillShowNotification通知。

// 3、如果从一个聚焦的输入框直接聚焦到另一个输入框，会调用前一个输入框的keyboardWillChangeFrameNotification，在调用后一个输入框的keyboardWillChangeFrameNotification，最后调用后一个输入框的keyboardWillShowNotification（如果此时是浮动键盘，那么后一个输入框的keyboardWillShowNotification不会被调用；）。

// 4、iPad可以变成浮动键盘，固定->浮动：会调用keyboardWillChangeFrameNotification和keyboardWillHideNotification；浮动->固定：会调用keyboardWillChangeFrameNotification和keyboardWillShowNotification；浮动键盘在移动的时候只会调用keyboardWillChangeFrameNotification通知，并且endFrame为zero，fromFrame不为zero，而是移动前键盘的frame。浮动键盘在聚焦和失焦的时候只会调用keyboardWillChangeFrameNotification，不会调用show和hide的notification。

// 5、iPad可以拆分为左右的小键盘，小键盘的通知具体基本跟浮动键盘一样。

// 6、iPad可以外接键盘，外接键盘之后屏幕上就没有虚拟键盘了，但是当我们输入文字的时候，发现底部还是有一条灰色的候选词，条东西也是键盘，它也会触发跟虚拟键盘一样的通知事件。如果点击这条候选词右边的向下箭头，则可以完全隐藏虚拟键盘，这个时候如果失焦再聚焦发现还是没有这条候选词，也就是键盘完全不出来了，如果输入文字，候选词才会重新出来。总结来说就是这条候选词是可以关闭的，关闭之后只有当下次输入才会重新出现。（聚焦和失焦都只调用keyboardWillChangeFrameNotification和keyboardWillHideNotification通知，而且frame始终不变，都是在屏幕下面）

// 7、iOS8 hide 之后高度变成0了，keyboardWillHideNotification还是正常的，所以建议不要使用键盘高度来做动画，而是用键盘的y值；在show和hide的时候endFrame会出现一些奇怪的中间值，最终值是对的；两个输入框切换聚焦，iOS8不会触发任何键盘通知；iOS8的浮动切换正常；

// 8、iOS8在 固定->浮动 的过程中，后面的keyboardWillChangeFrameNotification和keyboardWillHideNotification里面的endFrame是正确的，而iOS10和iOS9是错的，iOS9的y值是键盘的MaxY，而iOS10的y值是隐藏状态下的y，也就是屏幕高度。所以iOS9和iOS10需要在keyboardDidChangeFrameNotification里面重新刷新一下。

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
    [self.targetResponderValues addObject:[self packageTargetResponder:targetResponder]];
    return YES;
}

- (NSMutableArray <UIResponder *> *)targetResponders {
    NSMutableArray *targetResponders = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.targetResponderValues.count; i++) {
        id unPackageValue = [self unPackageTargetResponder:self.targetResponderValues[i]];
        if (unPackageValue && [unPackageValue isKindOfClass:[UIResponder class]]) {
            [targetResponders addObject:(UIResponder *)unPackageValue];
        }
    }
    return targetResponders;
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

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    
    NSLog(@"keyboardWillShowNotification - %@", self);
    NSLog(@"\n");
    
    if (![self shouldReceiveShowNotification]) {
        return;
    }
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    userInfo.targetResponder = [self unPackageTargetResponder:self.targetResponderValues.firstObject] ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillShowWithUserInfo:)]) {
        [self.delegate keyboardWillShowWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if (IS_IPAD) {
        self.keyboardMoveUserInfo = userInfo;
        [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
}

- (void)keyboardDidShowNotification:(NSNotification *)notification {
    
    NSLog(@"keyboardDidShowNotification - %@", self);
    NSLog(@"\n");
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    userInfo.targetResponder = [self unPackageTargetResponder:self.targetResponderValues.firstObject] ?: nil;
    
    id firstResponder = [[UIApplication sharedApplication].keyWindow km_findFirstResponder];
    if (firstResponder && firstResponder == kCurrentResponder) {
        
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidShowWithUserInfo:)]) {
            [self.delegate keyboardDidShowWithUserInfo:nil];
        }
        
        // 额外处理iPad浮动键盘
        if (IS_IPAD) {
            self.keyboardMoveUserInfo = userInfo;
            [self keyboardDidChangedFrame:[self.class keyboardView]];
        }
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    
    NSLog(@"keyboardWillHideNotification - %@", self);
    NSLog(@"\n");
    
    if (![self shouldReceiveHideNotification]) {
        return;
    }
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    userInfo.targetResponder = kCurrentResponder ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillHideWithUserInfo:)]) {
        [self.delegate keyboardWillHideWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if (IS_IPAD) {
        self.keyboardMoveUserInfo = userInfo;
        [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
    
    NSLog(@"keyboardDidHideNotification - %@", self);
    NSLog(@"\n");
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    userInfo.targetResponder = kCurrentResponder ?: nil;
    
    if ([self shouldReceiveHideNotification]) {
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidHideWithUserInfo:)]) {
            [self.delegate keyboardDidHideWithUserInfo:userInfo];
        }
    }
    
    // 额外处理iPad浮动键盘
    if (kCurrentResponder) {
        if (IS_IPAD) {
            self.keyboardMoveUserInfo = userInfo;
            [self keyboardDidChangedFrame:[self.class keyboardView]];
        } else {
            if (!kCurrentResponder.km_isFirstResponder) {
                kCurrentResponder = nil;
            }
        }
    }
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    
    NSLog(@"keyboardWillChangeFrameNotification - %@", self);
    NSLog(@"\n");
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    
    if ([self shouldReceiveShowNotification]) {
        userInfo.targetResponder = [self unPackageTargetResponder:self.targetResponderValues.firstObject] ?: nil;
    } else if ([self shouldReceiveHideNotification]) {
        userInfo.targetResponder = kCurrentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardWillChangeFrameWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if (IS_IPAD) {
        self.keyboardMoveUserInfo = userInfo;
        [self addFrameObserverIfNeeded];
    }
}

- (void)keyboardDidChangeFrameNotification:(NSNotification *)notification {
    
    NSLog(@"keyboardDidChangeFrameNotification - %@", self);
    NSLog(@"\n");
    
    QMUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    
    if ([self shouldReceiveShowNotification]) {
        userInfo.targetResponder = [self unPackageTargetResponder:self.targetResponderValues.firstObject] ?: nil;
    } else if ([self shouldReceiveHideNotification]) {
        userInfo.targetResponder = kCurrentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardDidChangeFrameWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if (IS_IPAD) {
        self.keyboardMoveUserInfo = userInfo;
        [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
}

- (QMUIKeyboardUserInfo *)newUserInfoWithNotification:(NSNotification *)notification {
    QMUIKeyboardUserInfo *userInfo = [[QMUIKeyboardUserInfo alloc] init];
    userInfo.keyboardManager = self;
    userInfo.notification = notification;
    return userInfo;
}

- (BOOL)shouldReceiveShowNotification {
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        id firstResponder = [[UIApplication sharedApplication].keyWindow km_findFirstResponder];
        if (firstResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:firstResponder]]) {
            kCurrentResponder = firstResponder;
            NSInteger fromIndex = [self.targetResponderValues indexOfObject:[self packageTargetResponder:firstResponder]];
            NSInteger toIndex = self.targetResponderValues.count - 1;
            if (fromIndex != toIndex) {
                [self.targetResponderValues exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
            }
            return YES;
        } else {
            return NO;
        }
    }
}

- (BOOL)shouldReceiveHideNotification {
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        if (kCurrentResponder) {
            return [self.targetResponderValues containsObject:[self packageTargetResponder:kCurrentResponder]];
        } else {
            return NO;
        }
    }
}

#pragma mark - iPad浮动键盘

- (void)addFrameObserverIfNeeded {
    if (![self.class keyboardView]) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    QMUIKeyboardViewFrameObserver *observer = [QMUIKeyboardViewFrameObserver observerForView:[self.class keyboardView]];
    if (!observer) {
        observer = [[QMUIKeyboardViewFrameObserver alloc] init];
        observer.keyboardViewChangeFrameBlock = ^(UIView *keyboardView) {
            [weakSelf keyboardDidChangedFrame:keyboardView];
        };
        [observer addToKeyboardView:[self.class keyboardView]];
        // 手动调用第一次
        [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
}

- (void)keyboardDidChangedFrame:(UIView *)keyboardView {
    
    if (keyboardView != [self.class keyboardView]) {
        return;
    }
    
    // 也需要判断targetResponder
    if (![self shouldReceiveShowNotification] && ![self shouldReceiveHideNotification]) {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
        
        UIWindow *keyboardWindow = keyboardView.window;
        
        if (self.keyboardMoveBeginRect.size.width == 0 && self.keyboardMoveBeginRect.size.height == 0) {
            // 第一次需要初始化
            self.keyboardMoveBeginRect = CGRectMake(0, keyboardWindow.bounds.size.height, keyboardWindow.bounds.size.width, 0);
        }
    
        CGRect endFrame = CGRectZero;
        if (keyboardWindow) {
            endFrame = [keyboardWindow convertRect:keyboardView.frame toWindow:nil];
        } else {
            endFrame = keyboardView.frame;
        }
    
        // 自己构造一个QMUIKeyboardUserInfo，一些属性使用之前最后一个keyboardUserInfo的值
        QMUIKeyboardUserInfo *keyboardMoveUserInfo = [[QMUIKeyboardUserInfo alloc] init];
        keyboardMoveUserInfo.keyboardManager = self;
        keyboardMoveUserInfo.targetResponder = self.keyboardMoveUserInfo ? self.keyboardMoveUserInfo.targetResponder : nil;
        keyboardMoveUserInfo.animationDuration = self.keyboardMoveUserInfo ? self.keyboardMoveUserInfo.animationDuration : 0.25;
        keyboardMoveUserInfo.animationCurve = self.keyboardMoveUserInfo ? self.keyboardMoveUserInfo.animationCurve : 7;
        keyboardMoveUserInfo.animationOptions = self.keyboardMoveUserInfo ? self.keyboardMoveUserInfo.animationOptions : keyboardMoveUserInfo.animationCurve<<16;
        keyboardMoveUserInfo.beginFrame = self.keyboardMoveBeginRect;
        keyboardMoveUserInfo.endFrame = endFrame;
        
        NSLog(@"keyboardDidMoveNotification - %@", self);
        NSLog(@"\n");
        
        [self.delegate keyboardWillChangeFrameWithUserInfo:keyboardMoveUserInfo];
        
        self.keyboardMoveBeginRect = endFrame;
        
        if (kCurrentResponder) {
            UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow ?: [[UIApplication sharedApplication] windows].firstObject;
            if (mainWindow) {
                CGRect keyboardRect = keyboardMoveUserInfo.endFrame;
                CGFloat distanceFromBottom = [QMUIKeyboardManager distanceFromMinYToBottomInView:mainWindow keyboardRect:keyboardRect];
                if (distanceFromBottom < keyboardRect.size.height) {
                    if (!kCurrentResponder.km_isFirstResponder) {
                        // willHide
                        kCurrentResponder = nil;
                    }
                } else if (distanceFromBottom > keyboardRect.size.height && !kCurrentResponder.isFirstResponder) {
                    if (!kCurrentResponder.km_isFirstResponder) {
                        // 浮动
                        kCurrentResponder = nil;
                    }
                }
            }
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
    if ([QMUIKeyboardManager visiableKeyboardHeight] <= 0 && !keyboardUserInfo.isTargetResponderFocused) {
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
    
    // 这个方法参考YYKyeboardManager：https://github.com/ibireme/YYKeyboardManager/blob/master/YYKeyboardManager/YYKeyboardManager.m
    
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
    
    // 这个方法参考YYKyeboardManager：https://github.com/ibireme/YYKeyboardManager/blob/master/YYKeyboardManager/YYKeyboardManager.m
    
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
    CGFloat distance = CGRectGetHeight(view.bounds) - CGRectGetMinY(rect);
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
    
    // 这个方法参考YYKyeboardManager：https://github.com/ibireme/YYKeyboardManager/blob/master/YYKeyboardManager/YYKeyboardManager.m
    
    /*
     iOS 6/7:
     UITextEffectsWindow
     UIPeripheralHostView << keyboard
     iOS 8:
     UITextEffectsWindow
     UIInputSetContainerView
     UIInputSetHostView << keyboard
     iOS 9:
     UIRemoteKeyboardWindow
     UIInputSetContainerView
     UIInputSetHostView << keyboard
     */
    
    if (!window) return nil;
    
    NSString *windowName = NSStringFromClass(window.class);
    if (IOS_VERSION < 9) {
        // UITextEffectsWindow
        if (windowName.length != 19) return nil;
        if (![windowName hasPrefix:@"UI"]) return nil;
        if (![windowName hasSuffix:[NSString stringWithFormat:@"%@%@", @"TextEffects", @"Window"]]) return nil;
    } else {
        // UIRemoteKeyboardWindow
        if (windowName.length != 22) return nil;
        if (![windowName hasPrefix:@"UI"]) return nil;
        if (![windowName hasSuffix:[NSString stringWithFormat:@"%@%@", @"RemoteKeyboard", @"Window"]]) return nil;
    }
    
    if (IOS_VERSION < 8) {
        // UIPeripheralHostView
        for (UIView *view in window.subviews) {
            NSString *viewName = NSStringFromClass(view.class);
            if (viewName.length != 20) continue;
            if (![viewName hasPrefix:@"UI"]) continue;
            if (![viewName hasSuffix:[NSString stringWithFormat:@"%@%@", @"Peripheral", @"HostView"]]) continue;
            return view;
        }
    } else {
        // UIInputSetContainerView
        for (UIView *view in window.subviews) {
            NSString *viewName = NSStringFromClass(view.class);
            if (viewName.length != 23) continue;
            if (![viewName hasPrefix:@"UI"]) continue;
            if (![viewName hasSuffix:[NSString stringWithFormat:@"%@%@", @"InputSet", @"ContainerView"]]) continue;
            // UIInputSetHostView
            for (UIView *subView in view.subviews) {
                NSString *subViewName = NSStringFromClass(subView.class);
                if (subViewName.length != 18) continue;
                if (![subViewName hasPrefix:@"UI"]) continue;
                if (![subViewName hasSuffix:[NSString stringWithFormat:@"%@%@", @"InputSet", @"HostView"]]) continue;
                return subView;
            }
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
    CGRect rect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
    if (CGRectIsNull(rect) || CGRectIsInfinite(rect)) {
        return NO;
    }
    return rect.size.width > 0 && rect.size.height > 0;
}

+ (CGRect)currentKeyboardFrame {
    UIView *keyboardView = [self keyboardView];
    if (!keyboardView) {
        return CGRectNull;
    }
    UIWindow *keyboardWindow = keyboardView.window;
    if (keyboardWindow) {
        return [keyboardWindow convertRect:keyboardView.frame toWindow:nil];
    } else {
        return keyboardView.frame;
    }
}

+ (CGFloat)visiableKeyboardHeight {
    UIView *keyboardView = [self keyboardView];
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return 0;
    } else {
        CGRect visiableRect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
        if (CGRectIsNull(visiableRect)) {
            return 0;
        }
        return visiableRect.size.height;
    }
}

@end
