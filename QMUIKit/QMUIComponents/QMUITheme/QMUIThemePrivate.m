/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIThemePrivate.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/26.
//

#import "QMUIThemePrivate.h"
#import "QMUICore.h"
#import "UIColor+QMUI.h"
#import "UIVisualEffect+QMUITheme.h"
#import "UIView+QMUITheme.h"
#import "UISlider+QMUI.h"
#import "UIView+QMUI.h"
#import "UISearchBar+QMUI.h"
#import "UITableViewCell+QMUI.h"
#import "CALayer+QMUI.h"
#import "UIVisualEffectView+QMUI.h"
#import "UIBarItem+QMUI.h"
#import "UITabBar+QMUI.h"
#import "UITabBarItem+QMUI.h"

// QMUI classes
#import "QMUIImagePickerCollectionViewCell.h"
#import "QMUIAlertController.h"
#import "QMUIButton.h"
#import "QMUIConsole.h"
#import "QMUIEmotionView.h"
#import "QMUIEmptyView.h"
#import "QMUIGridView.h"
#import "QMUIImagePreviewView.h"
#import "QMUILabel.h"
#import "QMUIPopupContainerView.h"
#import "QMUIPopupMenuButtonItem.h"
#import "QMUIPopupMenuView.h"
#import "QMUITextField.h"
#import "QMUITextView.h"
#import "QMUIToastBackgroundView.h"
#import "QMUIBadgeProtocol.h"

@interface QMUIThemePropertiesRegister : NSObject

@end

@implementation QMUIThemePropertiesRegister

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            ({
                static NSDictionary<NSString *, NSArray<NSString *> *> *classRegisters = nil;
                if (!classRegisters) {
                    classRegisters = @{
                                       NSStringFromClass(UISlider.class):                   @[NSStringFromSelector(@selector(minimumTrackTintColor)),
                                                                                              NSStringFromSelector(@selector(maximumTrackTintColor)),
                                                                                              NSStringFromSelector(@selector(thumbTintColor)),
                                                                                              NSStringFromSelector(@selector(qmui_thumbColor)),
                                                                                              NSStringFromSelector(@selector(qmui_thumbShadowColor))],
                                       NSStringFromClass(UISwitch.class):                   @[NSStringFromSelector(@selector(onTintColor)),
                                                                                              NSStringFromSelector(@selector(thumbTintColor)),],
                                       NSStringFromClass(UIActivityIndicatorView.class):    @[NSStringFromSelector(@selector(color)),],
                                       NSStringFromClass(UIProgressView.class):             @[NSStringFromSelector(@selector(progressTintColor)),
                                                                                              NSStringFromSelector(@selector(trackTintColor)),],
                                       NSStringFromClass(UIPageControl.class):              @[NSStringFromSelector(@selector(pageIndicatorTintColor)),
                                                                                              NSStringFromSelector(@selector(currentPageIndicatorTintColor)),],
                                       NSStringFromClass(UITableView.class):                @[NSStringFromSelector(@selector(backgroundColor)),
                                                                                              NSStringFromSelector(@selector(sectionIndexColor)),
                                                                                              NSStringFromSelector(@selector(sectionIndexBackgroundColor)),
                                                                                              NSStringFromSelector(@selector(sectionIndexTrackingBackgroundColor)),
                                                                                              NSStringFromSelector(@selector(separatorColor)),],
                                       NSStringFromClass(UITableViewCell.class):            @[NSStringFromSelector(@selector(qmui_selectedBackgroundColor)),],
                                       NSStringFromClass(UICollectionViewCell.class):            @[NSStringFromSelector(@selector(qmui_selectedBackgroundColor)),],
                                       NSStringFromClass(UINavigationBar.class):                   ({
                                           NSMutableArray<NSString *> *result = @[
                                               NSStringFromSelector(@selector(qmui_effect)),
                                               NSStringFromSelector(@selector(qmui_effectForegroundColor)),
                                           ].mutableCopy;
                                           if (@available(iOS 15.0, *)) {
                                               // iOS 15 在 UINavigationBar (QMUI) 里对所有旧版接口都映射到 standardAppearance，所以重新设置一次 standardAppearance 就可以更新所有样式
                                               [result addObject:NSStringFromSelector(@selector(standardAppearance))];
                                           } else {
                                               [result addObjectsFromArray:@[NSStringFromSelector(@selector(barTintColor)),]];
                                           }
                                           result.copy;
                                       }),
                                       NSStringFromClass(UIToolbar.class):                  @[NSStringFromSelector(@selector(barTintColor)),],
                                       NSStringFromClass(UITabBar.class):                   ({
                                           NSMutableArray<NSString *> *result = @[
                                               NSStringFromSelector(@selector(qmui_effect)),
                                               NSStringFromSelector(@selector(qmui_effectForegroundColor)),
                                           ].mutableCopy;
                                           if (@available(iOS 13.0, *)) {
                                               // iOS 13 在 UITabBar (QMUI) 里对所有旧版接口都映射到 standardAppearance，所以重新设置一次 standardAppearance 就可以更新所有样式
                                               [result addObject:NSStringFromSelector(@selector(standardAppearance))];
                                           } else {
                                               [result addObjectsFromArray:@[NSStringFromSelector(@selector(barTintColor)),
                                                                             NSStringFromSelector(@selector(unselectedItemTintColor)),
                                                                             NSStringFromSelector(@selector(selectedImageTintColor)),]];
                                           }
                                           result.copy;
                                       }),
                                       NSStringFromClass(UISearchBar.class):                        @[NSStringFromSelector(@selector(barTintColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_placeholderColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_textColor)),],
                                       NSStringFromClass(UITextField.class):                        @[NSStringFromSelector(@selector(attributedText)),],
                                       NSStringFromClass(UIView.class):                             @[NSStringFromSelector(@selector(tintColor)),
                                                                                                      NSStringFromSelector(@selector(backgroundColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_borderColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_badgeBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_badgeTextColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_updatesIndicatorColor)),],
                                       NSStringFromClass(UIVisualEffectView.class):                 @[NSStringFromSelector(@selector(effect)),
                                                                                                      NSStringFromSelector(@selector(qmui_foregroundColor))],
                                       NSStringFromClass(UIImageView.class):                        @[NSStringFromSelector(@selector(image))],
                                       
                                       // QMUI classes
                                       NSStringFromClass(QMUIImagePickerCollectionViewCell.class):  @[NSStringFromSelector(@selector(videoDurationLabelTextColor)),],
                                       NSStringFromClass(QMUIButton.class):                         @[NSStringFromSelector(@selector(tintColorAdjustsTitleAndImage)),
                                                                                                      NSStringFromSelector(@selector(highlightedBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(highlightedBorderColor)),],
                                       NSStringFromClass(QMUIConsole.class):                        @[NSStringFromSelector(@selector(searchResultHighlightedBackgroundColor)),],
                                       NSStringFromClass(QMUIEmotionView.class):                    @[NSStringFromSelector(@selector(sendButtonBackgroundColor)),],
                                       NSStringFromClass(QMUIEmptyView.class):                      @[NSStringFromSelector(@selector(textLabelTextColor)),
                                                                                                      NSStringFromSelector(@selector(detailTextLabelTextColor)),
                                                                                                      NSStringFromSelector(@selector(actionButtonTitleColor))],
                                       NSStringFromClass(QMUIGridView.class):                       @[NSStringFromSelector(@selector(separatorColor)),],
                                       NSStringFromClass(QMUIImagePreviewView.class):               @[NSStringFromSelector(@selector(loadingColor)),],
                                       NSStringFromClass(QMUILabel.class):                          @[NSStringFromSelector(@selector(highlightedBackgroundColor)),],
                                       NSStringFromClass(QMUIPopupContainerView.class):             @[NSStringFromSelector(@selector(highlightedBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(maskViewBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(shadowColor)),
                                                                                                      NSStringFromSelector(@selector(borderColor)),
                                                                                                      NSStringFromSelector(@selector(arrowImage)),],
                                       NSStringFromClass(QMUIPopupMenuButtonItem.class):            @[NSStringFromSelector(@selector(highlightedBackgroundColor)),],
                                       NSStringFromClass(QMUIPopupMenuView.class):                  @[NSStringFromSelector(@selector(itemSeparatorColor)),
                                                                                                      NSStringFromSelector(@selector(sectionSeparatorColor)),
                                                                                                      NSStringFromSelector(@selector(itemTitleColor))],
                                       NSStringFromClass(QMUITextField.class):                      @[NSStringFromSelector(@selector(placeholderColor)),],
                                       NSStringFromClass(QMUITextView.class):                       @[NSStringFromSelector(@selector(placeholderColor)),],
                                       NSStringFromClass(QMUIToastBackgroundView.class):            @[NSStringFromSelector(@selector(styleColor)),],
                                       
                                       // 以下的 class 的更新依赖于 UIView (QMUITheme) 内的 setNeedsDisplay，这里不专门调用 setter
//                                       NSStringFromClass(UILabel.class):                            @[NSStringFromSelector(@selector(textColor)),
//                                                                                                      NSStringFromSelector(@selector(shadowColor)),
//                                                                                                      NSStringFromSelector(@selector(highlightedTextColor)),],
//                                       NSStringFromClass(UITextView.class):                         @[NSStringFromSelector(@selector(attributedText)),],

                                       };
                }
                [classRegisters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull classString, NSArray<NSString *> * _Nonnull getters, BOOL * _Nonnull stop) {
                    if ([selfObject isKindOfClass:NSClassFromString(classString)]) {
                        [selfObject qmui_registerThemeColorProperties:getters];
                    }
                }];
            });
            return originReturnValue;
        });
    });
}

+ (void)registerToClass:(Class)class byBlock:(void (^)(UIView *view))block withView:(UIView *)view {
    if ([view isKindOfClass:class]) {
        block(view);
    }
}

@end

@implementation UIView (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // iOS 12 及以下，-[UIView setTintColor:] 被调用时，如果参数的 tintColor 与当前的 tintColor 指针相同，则不会触发 tintColorDidChange，但这对于 dynamic color 而言是不满足需求的（同一个 dynamic color 实例在任何时候返回的 rawColor 都有可能发生变化），所以这里主动为其做一次 copy 操作，规避指针地址判断的问题
        // 2022-7-20 后来发现 iOS 13-15，UIImageView、UIButton，手动切换 theme 时，tintColor 不 copy 就无法刷新，但如果是系统 Dark Mode 切换引发的 setTintColor:，即便不用 copy 也可以刷新，所以这里统一对所有 iOS 版本都做一次 copy
        // https://github.com/Tencent/QMUI_iOS/issues/1418
        OverrideImplementation([UIView class], @selector(setTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isQMUIDynamicColor && tintColor == selfObject.tintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        // iOS 12 及以下的版本，[UIView setBackgroundColor:] 并不会保存传进来的 color，所以要自己用个变量保存起来，不然 QMUIThemeColor 对象就会被丢弃
        if (@available(iOS 13.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setBackgroundColor:), UIColor *, ^(UIView *selfObject, UIColor *color) {
                [selfObject qmui_bindObject:color forKey:@"UIView(QMUIThemeCompatibility).backgroundColor"];
            });
            ExtendImplementationOfNonVoidMethodWithoutArguments([UIView class], @selector(backgroundColor), UIColor *, ^UIColor *(UIView *selfObject, UIColor *originReturnValue) {
                UIColor *color = [selfObject qmui_getBoundObjectForKey:@"UIView(QMUIThemeCompatibility).backgroundColor"];
                return color ?: originReturnValue;
            });
        }
    });
}

@end

@implementation UISwitch (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 这里反而是 iOS 13 才需要用 copy 的方式强制触发更新，否则如果某个 UISwitch 处于 off 的状态，此时去更新它的 onTintColor 不会立即生效，而是要等切换到 on 时，才会看到旧的 onTintColor 一闪而过变成新的 onTintColor，所以这里加个强制刷新
        if (@available(iOS 13.0, *)) {
            OverrideImplementation([UISwitch class], @selector(setOnTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISwitch *selfObject, UIColor *tintColor) {
                    
                    if (tintColor.qmui_isQMUIDynamicColor && tintColor == selfObject.onTintColor) tintColor = tintColor.copy;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, tintColor);
                };
            });
            
            OverrideImplementation([UISwitch class], @selector(setThumbTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISwitch *selfObject, UIColor *tintColor) {
                    
                    if (tintColor.qmui_isQMUIDynamicColor && tintColor == selfObject.thumbTintColor) tintColor = tintColor.copy;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, tintColor);
                };
            });
        }

    });
}


@end

@implementation UISlider (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UISlider class], @selector(setMinimumTrackTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isQMUIDynamicColor && tintColor == selfObject.minimumTrackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UISlider class], @selector(setMaximumTrackTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isQMUIDynamicColor && tintColor == selfObject.maximumTrackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UISlider class], @selector(setThumbTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isQMUIDynamicColor && tintColor == selfObject.thumbTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
    });
}

@end

@implementation UIProgressView (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIProgressView class], @selector(setProgressTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIProgressView *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isQMUIDynamicColor && tintColor == selfObject.progressTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UIProgressView class], @selector(setTrackTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIProgressView *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isQMUIDynamicColor && tintColor == selfObject.trackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
    });
}

@end

@implementation UITabBarItem (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // UITabBarItem.image 会一直保存原始的 image（例如 QMUIThemeImage），但 selectedImage 只会返回 rawImage，这导致了将一个 QMUIThemeImage 设置给 selectedImage 后，主题切换后 selectedImage 无法刷新（因为 UITabBarItem 并没有保存它，保存的是它的 rawImage），所以这里自己保存 image 的引用。
        // https://github.com/Tencent/QMUI_iOS/issues/1122
        OverrideImplementation([UITabBarItem class], @selector(setSelectedImage:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITabBarItem *selfObject, UIImage *selectedImage) {
                
                // 必须先保存起来再执行 super，因为 setter 的 super 里会触发 getter，如果不先保存，就会导致走到 getter 时拿到的 boundObject 还是旧值
                // https://github.com/Tencent/QMUI_iOS/issues/1218
                [selfObject qmui_bindObject:selectedImage.qmui_isDynamicImage ? selectedImage : nil forKey:@"UITabBarItem(QMUIThemeCompatibility).selectedImage"];
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIImage *);
                originSelectorIMP = (void (*)(id, SEL, UIImage *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, selectedImage);
            };
        });
        
        OverrideImplementation([UITabBarItem class], @selector(selectedImage), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIImage *(UITabBarItem *selfObject) {
                
                // call super
                UIImage * (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIImage * (*)(id, SEL))originalIMPProvider();
                UIImage *result = originSelectorIMP(selfObject, originCMD);
                
                UIImage *selectedImage = [selfObject qmui_getBoundObjectForKey:@"UITabBarItem(QMUIThemeCompatibility).selectedImage"];
                if (selectedImage) {
                    return selectedImage;
                }
                
                return result;
            };
        });
    });
}

@end

@implementation UIVisualEffectView (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIVisualEffectView class], @selector(setEffect:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIVisualEffectView *selfObject, UIVisualEffect *effect) {
                
                if (effect.qmui_isDynamicEffect && effect == selfObject.effect) effect = effect.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIVisualEffect *);
                originSelectorIMP = (void (*)(id, SEL, UIVisualEffect *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, effect);
            };
        });
    });
}

@end

@implementation UILabel (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // iOS 10-11 里，UILabel.attributedText 如果整个字符串都是同个颜色，则调用 -[UILabel setNeedsDisplay] 无法刷新文字样式，但如果字符串中存在不同 range 有不同颜色，就可以刷新。iOS 9、12-13 都没这个问题，所以这里做了兼容，给 UIView (QMUITheme) 那边刷新 UILabel 用。
        if (@available(iOS 12.0, *)) {
        } else {
            OverrideImplementation([UILabel class], NSSelectorFromString(@"_needsContentsFormatUpdate"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UILabel *selfObject) {
                    
                    __block BOOL attributedTextContainsDynamicColor = NO;
                    if (selfObject.attributedText) {
                        [selfObject.attributedText enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, selfObject.attributedText.length) options:0 usingBlock:^(UIColor *color, NSRange range, BOOL * _Nonnull stop) {
                            if (color.qmui_isQMUIDynamicColor) {
                                attributedTextContainsDynamicColor = YES;
                                *stop = YES;
                            }
                        }];
                    }
                    BOOL textColorIsDynamicColor = selfObject.textColor.qmui_isQMUIDynamicColor;
                    if (attributedTextContainsDynamicColor || textColorIsDynamicColor) return YES;
                    
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    return originSelectorIMP(selfObject, originCMD);
                };
            });
        }
    });
}

@end

@implementation UITextView (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // UITextView 在 iOS 12 及以上重写了 -[UIView setNeedsDisplay]，在里面会去刷新文字样式，但 iOS 11 及以下没有重写，所以这里对此作了兼容，从而保证 QMUITheme 那边遇到 UITextView 时能使用 setNeedsDisplay 刷新文字样式。至于实现思路是参考 iOS 13 系统原生实现。
        if (@available(iOS 12.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithoutArguments([UITextView class], @selector(setNeedsDisplay), ^(UITextView *selfObject) {
                UIView *textContainerView = [selfObject qmui_valueForKey:@"_containerView"];
                if (textContainerView) [textContainerView setNeedsDisplay];
            });
        }
    });
}

@end

@interface CALayer ()

@property(nonatomic, strong) UIColor *qcl_originalBackgroundColor;
@property(nonatomic, strong) UIColor *qcl_originalBorderColor;
@property(nonatomic, strong) UIColor *qcl_originalShadowColor;

@end

@implementation CALayer (QMUIThemeCompatibility)

QMUISynthesizeIdStrongProperty(qcl_originalBackgroundColor, setQcl_originalBackgroundColor)
QMUISynthesizeIdStrongProperty(qcl_originalBorderColor, setQcl_originalBorderColor)
QMUISynthesizeIdStrongProperty(qcl_originalShadowColor, setQcl_originalShadowColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CALayer class], @selector(setBackgroundColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGColorRef color) {
                
                // iOS 13 的 UIDynamicProviderColor，以及 QMUIThemeColor 在获取 CGColor 时会将自身绑定到 CGColorRef 上，这里把原始的 color 重新获取出来存到 property 里，以备样式更新时调用
                UIColor *originalColor = [(__bridge id)(color) qmui_getBoundObjectForKey:QMUICGColorOriginalColorBindKey];
                selfObject.qcl_originalBackgroundColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        OverrideImplementation([CALayer class], @selector(setBorderColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGColorRef color) {
                
                UIColor *originalColor = [(__bridge id)(color) qmui_getBoundObjectForKey:QMUICGColorOriginalColorBindKey];
                selfObject.qcl_originalBorderColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        OverrideImplementation([CALayer class], @selector(setShadowColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGColorRef color) {
                
                UIColor *originalColor = [(__bridge id)(color) qmui_getBoundObjectForKey:QMUICGColorOriginalColorBindKey];
                selfObject.qcl_originalShadowColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        // iOS 13 下，如果系统的主题发生变化，会自动调用每个 view 的 layoutSubviews，所以我们在这里面自动更新样式
        // 如果是 QMUIThemeManager 引发的主题变化，会在 theme 那边主动调用 qmui_setNeedsUpdateDynamicStyle，就不依赖这里
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(layoutSubviews), ^(UIView *selfObject) {
                [selfObject.layer qmui_setNeedsUpdateDynamicStyle];
            });
        }
    });
}

- (void)qmui_setNeedsUpdateDynamicStyle {
    if (self.qcl_originalBackgroundColor) {
        UIColor *originalColor = self.qcl_originalBackgroundColor;
        self.backgroundColor = originalColor.CGColor;
    }
    if (self.qcl_originalBorderColor) {
        self.borderColor = self.qcl_originalBorderColor.CGColor;
    }
    if (self.qcl_originalShadowColor) {
        self.shadowColor = self.qcl_originalShadowColor.CGColor;
    }
    
    [self.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull sublayer, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!sublayer.qmui_isRootLayerOfView) {// 如果是 UIView 的 rootLayer，它会依赖 UIView 树自己的 layoutSubviews 去逐个触发，不需要手动遍历到，这里只需要遍历那些额外添加到 layer 上的 sublayer 即可
            [sublayer qmui_setNeedsUpdateDynamicStyle];
        }
    }];
}

@end

@interface UISearchBar ()

@property(nonatomic, readonly) NSMutableDictionary <NSString * ,NSInvocation *>*qmuiTheme_invocations;

@end

@implementation UISearchBar (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        OverrideImplementation([UISearchBar class], @selector(setSearchFieldBackgroundImage:forState:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            
            NSMethodSignature *methodSignature = [originClass instanceMethodSignatureForSelector:originCMD];
            
            return ^(UISearchBar *selfObject, UIImage *image, UIControlState state) {
                
                void (*originSelectorIMP)(id, SEL, UIImage *, UIControlState);
                originSelectorIMP = (void (*)(id, SEL, UIImage *, UIControlState))originalIMPProvider();
                
                UIImage *previousImage = [selfObject searchFieldBackgroundImageForState:state];
                if (previousImage.qmui_isDynamicImage || image.qmui_isDynamicImage) {
                    // setSearchFieldBackgroundImage:forState: 的内部实现原理:
                    // 执行后将 image 先存起来，在 layout 时会调用 -[UITextFieldBorderView setImage:] 该方法内部有一个判断：
                    // if (UITextFieldBorderView._image == image) return
                    // 由于 QMUIDynamicImage 随时可能发生图片的改变，这里要绕过这个判断：必须先清空一下 image，并马上调用 layoutIfNeeded 触发 -[UITextFieldBorderView setImage:] 使得 UITextFieldBorderView 内部的 image 清空，这样再设置新的才会生效。
                    originSelectorIMP(selfObject, originCMD, UIImage.new, state);
                    [selfObject.qmui_textField setNeedsLayout];
                    [selfObject.qmui_textField layoutIfNeeded];
                }
                originSelectorIMP(selfObject, originCMD, image, state);
                
                NSInvocation *invocation = nil;
                NSString *invocationActionKey = [NSString stringWithFormat:@"%@-%zd", NSStringFromSelector(originCMD), state];
                if (image.qmui_isDynamicImage) {
                    invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                    [invocation setSelector:originCMD];
                    [invocation setArgument:&image atIndex:2];
                    [invocation setArgument:&state atIndex:3];
                    [invocation retainArguments];
                }
                selfObject.qmuiTheme_invocations[invocationActionKey] = invocation;
            };
        });
        
        OverrideImplementation([UISearchBar class], @selector(setBarTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchBar *selfObject, UIColor *barTintColor) {
                
                if (barTintColor.qmui_isQMUIDynamicColor && barTintColor == selfObject.barTintColor) barTintColor = barTintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, barTintColor);
            };
        });
    });
}

- (void)_qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme shouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews {
    [super _qmui_themeDidChangeByManager:manager identifier:identifier theme:theme shouldEnumeratorSubviews:shouldEnumeratorSubviews];
    [self qmuiTheme_performUpdateInvocations];
}

- (void)qmuiTheme_performUpdateInvocations {
    [[self.qmuiTheme_invocations allValues] enumerateObjectsUsingBlock:^(NSInvocation * _Nonnull invocation, NSUInteger idx, BOOL * _Nonnull stop) {
        [invocation setTarget:self];
        [invocation invoke];
    }];
}


- (NSMutableDictionary *)qmuiTheme_invocations {
    NSMutableDictionary *qmuiTheme_invocations = objc_getAssociatedObject(self, _cmd);
    if (!qmuiTheme_invocations) {
        qmuiTheme_invocations = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, qmuiTheme_invocations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return qmuiTheme_invocations;
}

@end
