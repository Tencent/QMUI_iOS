//
//  UIView+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/6/21.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "UIView+QMUITheme.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"
#import "UIColor+QMUI.h"
#import "UIImage+QMUITheme.h"
#import "CALayer+QMUI.h"
#import "QMUIThemeManager.h"
#import "QMUIThemePrivate.h"

@implementation UIView (QMUITheme)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 12 及以下的版本，[UIView setBackgroundColor:] 并不会保存传进来的 color，所以要自己用个变量保存起来，不然 QMUIThemeColor 对象就会被丢弃
        if (@available(iOS 13.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setBackgroundColor:), UIColor *, ^(UIView *selfObject, UIColor *color) {
                selfObject.qmuiTheme_backgroundColor = color;
            });
            ExtendImplementationOfNonVoidMethodWithoutArguments([UIView class], @selector(backgroundColor), UIColor *, ^UIColor *(UIView *selfObject, UIColor *originReturnValue) {
                return selfObject.qmuiTheme_backgroundColor ?: originReturnValue;
            });
        }
        
        OverrideImplementation([UIView class], @selector(setHidden:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, BOOL firstArgv) {
                
                BOOL valueChanged = selfObject.hidden != firstArgv;
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (valueChanged) {
                    selfObject.qmui_currentThemeIdentifier = QMUIThemeManager.sharedInstance.currentThemeIdentifier;
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setAlpha:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGFloat firstArgv) {
                
                BOOL valueChanged = selfObject.alpha != firstArgv;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGFloat);
                originSelectorIMP = (void (*)(id, SEL, CGFloat))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (valueChanged) {
                    // 只设置 identifier 就可以了，内部自然会去同步更新 theme
                    selfObject.qmui_currentThemeIdentifier = QMUIThemeManager.sharedInstance.currentThemeIdentifier;
                }
            };
        });
        
        // 这几个 class 在 iOS 12 下都实现了自己的 didMoveToWindow 且没有调用 super，所以需要每个都替换一遍方法
        NSArray<Class> *classes = @[UIView.class,
                                    UICollectionView.class,
                                    UITextField.class,
                                    UISearchBar.class,
                                    NSClassFromString(@"UITableViewLabel")];
        [classes enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
            ExtendImplementationOfVoidMethodWithoutArguments(class, @selector(didMoveToWindow), ^(UIView *selfObject) {
                // 只设置 identifier 就可以了，内部自然会去同步更新 theme
                // enumerateSubviews 为 NO 是因为当某个 view 的 didMoveToWindow 被触发时，它的每个 subview 的 didMoveToWindow 也都会被触发，所以不需要遍历 subview 了
                if (selfObject.window) {
                    [selfObject setQmui_currentThemeIdentifier:QMUIThemeManager.sharedInstance.currentThemeIdentifier enumerateSubviews:NO notify:YES syncTheme:YES];
                }
            });
        }];
    });
}

- (void)qmui_registerThemeColorProperties:(NSArray<NSString *> *)getters {
    [getters enumerateObjectsUsingBlock:^(NSString * _Nonnull getterString, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL getter = NSSelectorFromString(getterString);
        SEL setter = setterWithGetter(getter);
        NSString *setterString = NSStringFromSelector(setter);
        NSAssert([self respondsToSelector:getter], @"register theme color fails, %@ does not have method called %@", NSStringFromClass(self.class), getterString);
        NSAssert([self respondsToSelector:setter], @"register theme color fails, %@ does not have method called %@", NSStringFromClass(self.class), setterString);
        
        if (!self.qmuiTheme_themeColorProperties) {
            self.qmuiTheme_themeColorProperties = NSMutableDictionary.new;
        }
        self.qmuiTheme_themeColorProperties[getterString] = setterString;
    }];
}

- (void)qmui_unregisterThemeColorProperties:(NSArray<NSString *> *)getters {
    if (!self.qmuiTheme_themeColorProperties) return;
    
    [getters enumerateObjectsUsingBlock:^(NSString * _Nonnull getterString, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.qmuiTheme_themeColorProperties removeObjectForKey:getterString];
    }];
}

- (void)qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme {
    if ([self _qmui_visible]) {
        [self _processThemeStyle];
    }
}

- (void)_processThemeStyle {
    // 常见的 view 在 QMUIThemePrivate 里注册了 getter，在这里被调用
    [self.qmuiTheme_themeColorProperties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull getterString, NSString * _Nonnull setterString, BOOL * _Nonnull stop) {
        BeginIgnorePerformSelectorLeaksWarning
        
        // 由于 tintColor 属性自带向下传递的性质，并且当值为 nil 时会自动从 superview 读取值，所以不需要在这里遍历修改，否则取出 tintColor 后再设置回去，会打破这个传递链
        if ([getterString isEqualToString:NSStringFromSelector(@selector(tintColor))]) {
            if (!self.qmui_tintColorCustomized) return;
        }
        
        // 注意，需要遍历的属性不一定都是 UIColor 类型，也有可能是 NSAttributedString，例如 UITextField.attributedText
        id value = [self performSelector:NSSelectorFromString(getterString)];
        if (!value) return;
        if ([value isKindOfClass:[UIColor class]] && !((UIColor *)value).qmui_isDynamicColor) return;
        [self performSelector:NSSelectorFromString(setterString) withObject:value];
        
        EndIgnorePerformSelectorLeaksWarning
    }];
    
    // 特殊的 view 特殊处理
    static NSArray<Class> *needsDisplayClasses = nil;
    if (!needsDisplayClasses) needsDisplayClasses = @[UILabel.class, UITextView.class];
    [needsDisplayClasses enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isKindOfClass:class]) [self setNeedsDisplay];
    }];
    
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        if (imageView.image.qmui_isDynamicImage) {
            imageView.image = imageView.image;
        }
    }
    
    /** 这里去掉动画有 2 个原因：
     1. iOS 13 进入后台时会对 currentTraitCollection.userInterfaceStyle 做一次取反进行截图，以便在后台切换 Drak/Light 后能够更新 app 多任务缩略图，QMUI 响应了这个操作去调整取反后的 layer 的颜色，而在对 layer 设置属性的时候，如果包含了动画会导致截图不到最终的状态，这样会导致在后台切换 Drak/Light 后多任务缩略图无法及时更新。
     2. 对于 UIView 层，修改 backgroundColor 默认是没有动画的，而 CALayer 修改 backgroundColor 会有隐式动画，这里为了在响应主题变化时颜色同步更新，统一把 CALayer 的动画去掉
     */
    [CALayer qmui_performWithoutAnimation:^{
        [self.layer qmui_setNeedsUpdateDynamicStyle];
    }];
    

}

@end

@implementation UIView (QMUITheme_Private)

QMUISynthesizeIdStrongProperty(qmuiTheme_backgroundColor, setQmuiTheme_backgroundColor)
QMUISynthesizeIdStrongProperty(qmuiTheme_themeColorProperties, setQmuiTheme_themeColorProperties)

static char kAssociatedObjectKey_currentThemeIdentifier;
- (void)setQmui_currentThemeIdentifier:(__kindof NSObject<NSCopying> *)qmui_currentThemeIdentifier enumerateSubviews:(BOOL)enumerateSubviews notify:(BOOL)notify syncTheme:(BOOL)syncTheme {
    
    if (![self _qmui_visible]) return;
    
    BOOL valueChanged = ![self.qmui_currentThemeIdentifier isEqual:qmui_currentThemeIdentifier];
    
    QMUIWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_currentThemeIdentifier);
    if (!weakContainer) {
        weakContainer = [QMUIWeakObjectContainer new];
    }
    weakContainer.object = qmui_currentThemeIdentifier;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_currentThemeIdentifier, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (syncTheme) {
        NSObject *theme = [QMUIThemeManager.sharedInstance themeForIdentifier:qmui_currentThemeIdentifier];
        [self setQmui_currentTheme:theme enumerateSubviews:NO notify:NO syncIdentifier:NO];
    }
    
    if (valueChanged && notify) {
        [self _qmui_notifyThemeDidChange];
    }
    
    if (enumerateSubviews) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            [subview setQmui_currentThemeIdentifier:qmui_currentThemeIdentifier enumerateSubviews:YES notify:notify syncTheme:syncTheme];
        }];
    }
}

- (void)setQmui_currentThemeIdentifier:(__kindof NSObject<NSCopying> *)qmui_currentThemeIdentifier {
    [self setQmui_currentThemeIdentifier:qmui_currentThemeIdentifier enumerateSubviews:YES notify:YES syncTheme:YES];
}

- (NSObject<NSCopying> *)qmui_currentThemeIdentifier {
    return (NSObject<NSCopying> *)((QMUIWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_currentThemeIdentifier)).object;
}

static char kAssociatedObjectKey_currentTheme;
- (void)setQmui_currentTheme:(__kindof NSObject *)qmui_currentTheme enumerateSubviews:(BOOL)enumerateSubviews notify:(BOOL)notify syncIdentifier:(BOOL)syncIdentifier {
    if (![self _qmui_visible]) return;
    
    BOOL valueChanged = self.qmui_currentTheme && ![self.qmui_currentTheme isEqual:qmui_currentTheme];
    
    QMUIWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_currentTheme);
    if (!weakContainer) {
        weakContainer = [QMUIWeakObjectContainer new];
    }
    weakContainer.object = qmui_currentTheme;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_currentTheme, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (syncIdentifier) {
        NSObject<NSCopying> *identifier = [QMUIThemeManager.sharedInstance identifierForTheme:qmui_currentTheme];
        [self setQmui_currentThemeIdentifier:identifier enumerateSubviews:NO notify:NO syncTheme:NO];
    }
    
    if (valueChanged && notify) {
        [self _qmui_notifyThemeDidChange];
    }
    
    if (enumerateSubviews) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            [subview setQmui_currentTheme:qmui_currentTheme enumerateSubviews:YES notify:notify syncIdentifier:syncIdentifier];
        }];
    }
}

- (void)setQmui_currentTheme:(__kindof NSObject *)qmui_currentTheme {
    [self setQmui_currentTheme:qmui_currentTheme enumerateSubviews:YES notify:YES syncIdentifier:YES];
}

- (NSObject *)qmui_currentTheme {
    return (NSObject *)((QMUIWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_currentTheme)).object;
}

- (void)_qmui_notifyThemeDidChange {
    [self qmui_themeDidChangeByManager:QMUIThemeManager.sharedInstance identifier:self.qmui_currentThemeIdentifier theme:self.qmui_currentTheme];
}

- (BOOL)_qmui_visible {
    BOOL hidden = self.hidden;
    if ([self respondsToSelector:@selector(prepareForReuse)]) {
        hidden = NO;// UITableViewCell 在 prepareForReuse 前会被 setHidden:YES，然后再被 setHidden:NO，然而后者是无效的，执行完之后依然是 hidden 为 YES，导致认为非 visible 而无法触发 themeDidChange，所以这里对 UITableViewCell 做特殊处理
    }
    return !hidden && self.alpha > 0.01 && self.window;
}

@end
