/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIView+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/6/21.
//

#import "UIView+QMUITheme.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"
#import "UIColor+QMUI.h"
#import "UIImage+QMUI.h"
#import "UIImage+QMUITheme.h"
#import "UIVisualEffect+QMUITheme.h"
#import "QMUIThemeManagerCenter.h"
#import "CALayer+QMUI.h"
#import "QMUIThemeManager.h"
#import "QMUIThemePrivate.h"
#import "NSObject+QMUI.h"
#import "UITextInputTraits+QMUI.h"

@implementation UIView (QMUITheme)

QMUISynthesizeIdCopyProperty(qmui_themeDidChangeBlock, setQmui_themeDidChangeBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UIView class], @selector(setHidden:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, BOOL firstArgv) {
                
                BOOL valueChanged = selfObject.hidden != firstArgv;
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (valueChanged) {
                    // UIView.qmui_currentThemeIdentifier 只是为了实现判断当前的 theme 是否有发生变化，所以可以构造成一个 string，但怎么避免每次 hidden 切换时都要遍历所有的 subviews？
                    [selfObject _qmui_themeDidChangeByManager:nil identifier:nil theme:nil shouldEnumeratorSubviews:YES];
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setAlpha:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGFloat firstArgv) {
                
                BOOL willShow = selfObject.alpha <= 0 && firstArgv > 0.01;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGFloat);
                originSelectorIMP = (void (*)(id, SEL, CGFloat))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (willShow) {
                    // 只设置 identifier 就可以了，内部自然会去同步更新 theme
                    [selfObject _qmui_themeDidChangeByManager:nil identifier:nil theme:nil shouldEnumeratorSubviews:YES];
                }
            };
        });
        
        // 这几个 class 实现了自己的 didMoveToWindow 且没有调用 super，所以需要每个都替换一遍方法
        NSArray<Class> *classes = @[UIView.class,
                                    UICollectionView.class,
                                    UITextField.class,
                                    UISearchBar.class,
                                    NSClassFromString(@"UITableViewLabel")];
        if (NSClassFromString(@"WKWebView")) {
            classes = [classes arrayByAddingObject:NSClassFromString(@"WKWebView")];
        }
        [classes enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
            ExtendImplementationOfVoidMethodWithoutArguments(class, @selector(didMoveToWindow), ^(UIView *selfObject) {
                // enumerateSubviews 为 NO 是因为当某个 view 的 didMoveToWindow 被触发时，它的每个 subview 的 didMoveToWindow 也都会被触发，所以不需要遍历 subview 了
                if (selfObject.window) {
                    [selfObject _qmui_themeDidChangeByManager:nil identifier:nil theme:nil shouldEnumeratorSubviews:NO];
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
        QMUIAssert([self respondsToSelector:getter], @"UIView (QMUITheme)", @"register theme color fails, %@ does not have method called %@", NSStringFromClass(self.class), getterString);
        QMUIAssert([self respondsToSelector:setter], @"UIView (QMUITheme)", @"register theme color fails, %@ does not have method called %@", NSStringFromClass(self.class), setterString);
        
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
    if (![self _qmui_visible]) return;
    
    // 常见的 view 在 QMUIThemePrivate 里注册了 getter，在这里被调用
    [self.qmuiTheme_themeColorProperties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull getterString, NSString * _Nonnull setterString, BOOL * _Nonnull stop) {
        
        SEL getter = NSSelectorFromString(getterString);
        SEL setter = NSSelectorFromString(setterString);
        
        // 由于 tintColor 属性自带向下传递的性质，并且当值为 nil 时会自动从 superview 读取值，所以不需要在这里遍历修改，否则取出 tintColor 后再设置回去，会打破这个传递链
        if (getter == @selector(tintColor)) {
            if (!self.qmui_tintColorCustomized) return;
        }
        
        // 如果某个 UITabBarItem 处于选中状态，此时发生了主题变化，执行了 UITabBarSwappableImageView.image = image 的动作，就会把 selectedImage 设置为 normal image，无法恢复。所以对 UITabBarSwappableImageView 屏蔽掉 setImage 的刷新操作
        // https://github.com/Tencent/QMUI_iOS/issues/1122
        if ([self isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")] && getter == @selector(image)) {
            return;
        }
        
        // 注意，需要遍历的属性不一定都是 UIColor 类型，也有可能是 NSAttributedString，例如 UITextField.attributedText
        BeginIgnorePerformSelectorLeaksWarning
        id value = [self performSelector:getter];
        if (!value) return;
        BOOL isValidatedColor = [value isKindOfClass:QMUIThemeColor.class] && (!manager || [((QMUIThemeColor *)value).managerName isEqual:manager.name]);
        BOOL isValidatedImage = [value isKindOfClass:QMUIThemeImage.class] && (!manager || [((QMUIThemeImage *)value).managerName isEqual:manager.name]);
        BOOL isValidatedEffect = [value isKindOfClass:QMUIThemeVisualEffect.class] && (!manager || [((QMUIThemeVisualEffect *)value).managerName isEqual:manager.name]);
        BOOL isOtherObject = ![value isKindOfClass:UIColor.class] && ![value isKindOfClass:UIImage.class] && ![value isKindOfClass:UIVisualEffect.class];// 支持所有非 color、image、effect 的其他对象，例如 NSAttributedString
        if (isOtherObject || isValidatedColor || isValidatedImage || isValidatedEffect) {
            
            // 修复 iOS 12 及以下版本，QMUIThemeImage 在搭配 resizable 使用的情况下可能无法跟随主题刷新的 bug
            // https://github.com/Tencent/QMUI_iOS/issues/971
            if (@available(iOS 13.0, *)) {
            } else {
                if (isValidatedImage) {
                    QMUIThemeImage *image = (QMUIThemeImage *)value;
                    if (image.qmui_resizable) {
                        value = image.copy;
                    }
                }
            }
            
            [self performSelector:setter withObject:value];
        }
        EndIgnorePerformSelectorLeaksWarning
    }];
    
    // 特殊的 view 特殊处理
    // iOS 10-11 里当 UILabel.attributedText 的文字颜色都相同时，也无法使用 setNeedsDisplay 刷新样式，但只要某个 range 颜色不同就没问题，iOS 9、12-13 也没问题，这个通过 UILabel (QMUIThemeCompatibility) 兼容。
    static NSArray<Class> *needsDisplayClasses = nil;
    if (!needsDisplayClasses) needsDisplayClasses = @[UILabel.class, UITextView.class];
    [needsDisplayClasses enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isKindOfClass:class]) {
            [self setNeedsDisplay];
        }
    }];
    
    // 输入框、搜索框的键盘跟随主题变化
    if (QMUICMIActivated) {
        static NSArray<Class> *inputClasses = nil;
        if (!inputClasses) inputClasses = @[UITextField.class, UITextView.class, UISearchBar.class];// 这里的 Class 与 UITextInputTraits(QMUI) 对齐
        [inputClasses enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self isKindOfClass:obj]) {
                NSObject<UITextInputTraits> *input = (NSObject<UITextInputTraits> *)self;
                if ([input respondsToSelector:@selector(keyboardAppearance)]) {
                    if (input.keyboardAppearance != KeyboardAppearance && !input.qmui_hasCustomizedKeyboardAppearance) {
                        input.qmui_keyboardAppearance = KeyboardAppearance;
                    }
                }
                *stop = YES;
            }
        }];
    }
    
    /** 这里去掉动画有 2 个原因：
     1. iOS 13 进入后台时会对 currentTraitCollection.userInterfaceStyle 做一次取反进行截图，以便在后台切换 Drak/Light 后能够更新 app 多任务缩略图，QMUI 响应了这个操作去调整取反后的 layer 的颜色，而在对 layer 设置属性的时候，如果包含了动画会导致截图不到最终的状态，这样会导致在后台切换 Drak/Light 后多任务缩略图无法及时更新。
     2. 对于 UIView 层，修改 backgroundColor 默认是没有动画的，而 CALayer 修改 backgroundColor 会有隐式动画，这里为了在响应主题变化时颜色同步更新，统一把 CALayer 的动画去掉
     */
    [CALayer qmui_performWithoutAnimation:^{
        [self.layer qmui_setNeedsUpdateDynamicStyle];
    }];
    
    if (self.qmui_themeDidChangeBlock) {
        self.qmui_themeDidChangeBlock();
    }
}

@end

@implementation UIView (QMUITheme_Private)

QMUISynthesizeIdStrongProperty(qmuiTheme_themeColorProperties, setQmuiTheme_themeColorProperties)

- (BOOL)_qmui_visible {
    BOOL hidden = self.hidden;
    if ([self respondsToSelector:@selector(prepareForReuse)]) {
        hidden = NO;// UITableViewCell 在 prepareForReuse 前会被 setHidden:YES，然后再被 setHidden:NO，然而后者是无效的，执行完之后依然是 hidden 为 YES，导致认为非 visible 而无法触发 themeDidChange，所以这里对 UITableViewCell 做特殊处理
    }
    return !hidden && self.alpha > 0.01 && self.window;
}

- (void)_qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme shouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews {
    [self qmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    if (shouldEnumeratorSubviews) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            [subview _qmui_themeDidChangeByManager:manager identifier:identifier theme:theme shouldEnumeratorSubviews:YES];
        }];
    }
}

@end
