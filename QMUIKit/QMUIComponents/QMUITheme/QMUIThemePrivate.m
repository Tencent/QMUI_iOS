//
//  QMUIThemePrivate.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/26.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "QMUIThemePrivate.h"
#import "QMUICore.h"
#import "UIColor+QMUI.h"
#import "UIVisualEffect+QMUITheme.h"
#import "UIView+QMUITheme.h"
#import "UIView+QMUI.h"
#import "UISearchBar+QMUI.h"
#import "UITableViewCell+QMUI.h"

// QMUI classes
#import "QMUIImagePickerCollectionViewCell.h"
#import "QMUIAlertController.h"
#import "QMUIButton.h"
#import "QMUIFillButton.h"
#import "QMUIGhostButton.h"
#import "QMUILinkButton.h"
#import "QMUIConsole.h"
#import "QMUIEmotionView.h"
#import "QMUIEmptyView.h"
#import "QMUIGridView.h"
#import "QMUIImagePreviewView.h"
#import "QMUILabel.h"
#import "QMUIPopupContainerView.h"
#import "QMUIPopupMenuButtonItem.h"
#import "QMUIPopupMenuView.h"
#import "QMUISlider.h"
#import "QMUITextField.h"
#import "QMUITextView.h"
#import "QMUIVisualEffectView.h"
#import "QMUIToastBackgroundView.h"

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
                                                                                              NSStringFromSelector(@selector(thumbTintColor))],
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
                                       NSStringFromClass(UITableViewCell.class):            @[NSStringFromSelector(@selector(textColor)),
                                                                                              NSStringFromSelector(@selector(selectedTextColor)),
                                                                                              NSStringFromSelector(@selector(qmui_selectedBackgroundColor)),],
                                       NSStringFromClass(UINavigationBar.class):            @[NSStringFromSelector(@selector(barTintColor)),],
                                       NSStringFromClass(UIToolbar.class):                  @[NSStringFromSelector(@selector(barTintColor)),],
                                       NSStringFromClass(UITabBar.class):                   ({
                                                                                           NSArray<NSString *> *result = nil;
                                                                                           if (@available(iOS 10.0, *)) {
                                                                                               result = @[NSStringFromSelector(@selector(barTintColor)),
                                                                                                          NSStringFromSelector(@selector(unselectedItemTintColor)),
                                                                                                          NSStringFromSelector(@selector(selectedImageTintColor)),];
                                                                                           } else {
                                                                                               result = @[NSStringFromSelector(@selector(barTintColor)),
                                                                                                          NSStringFromSelector(@selector(selectedImageTintColor)),];
                                                                                           }
                                                                                           result;
                                                                                       }),
                                       NSStringFromClass(UISearchBar.class):                        @[NSStringFromSelector(@selector(barTintColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_placeholderColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_textColor)),],
                                       NSStringFromClass(UIView.class):                             @[NSStringFromSelector(@selector(tintColor)),
                                                                                                      NSStringFromSelector(@selector(backgroundColor)),
                                                                                                      NSStringFromSelector(@selector(qmui_borderColor)),],
                                       NSStringFromClass(UIVisualEffectView.class):                 @[NSStringFromSelector(@selector(effect))],
                                       
                                       // QMUI classes
                                       NSStringFromClass(QMUIImagePickerCollectionViewCell.class):  @[NSStringFromSelector(@selector(videoDurationLabelTextColor)),],
                                       NSStringFromClass(QMUIAlertController.class):                @[NSStringFromSelector(@selector(alertSeparatorColor)),
                                                                                                      NSStringFromSelector(@selector(alertHeaderBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(alertButtonBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(alertButtonHighlightBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(alertTextFieldTextColor)),
                                                                                                      NSStringFromSelector(@selector(alertTextFieldBorderColor)),
                                                                                                      NSStringFromSelector(@selector(sheetSeparatorColor)),
                                                                                                      NSStringFromSelector(@selector(sheetHeaderBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(sheetButtonBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(sheetButtonHighlightBackgroundColor)),],
                                       NSStringFromClass(QMUIButton.class):                         @[NSStringFromSelector(@selector(tintColorAdjustsTitleAndImage)),
                                                                                                      NSStringFromSelector(@selector(highlightedBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(highlightedBorderColor)),],
                                       NSStringFromClass(QMUIFillButton.class):                     @[NSStringFromSelector(@selector(fillColor)),
                                                                                                      NSStringFromSelector(@selector(titleTextColor)),],
                                       NSStringFromClass(QMUIGhostButton.class):                    @[NSStringFromSelector(@selector(ghostColor)),],
                                       NSStringFromClass(QMUILinkButton.class):                     @[NSStringFromSelector(@selector(underlineColor)),],
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
                                                                                                      NSStringFromSelector(@selector(borderColor)),],
                                       NSStringFromClass(QMUIPopupMenuButtonItem.class):            @[NSStringFromSelector(@selector(highlightedBackgroundColor)),],
                                       NSStringFromClass(QMUIPopupMenuView.class):                  @[NSStringFromSelector(@selector(itemSeparatorColor)),
                                                                                                      NSStringFromSelector(@selector(sectionSeparatorColor)),
                                                                                                      NSStringFromSelector(@selector(itemTitleColor))],
                                       NSStringFromClass(QMUISlider.class):                         @[NSStringFromSelector(@selector(thumbColor)),
                                                                                                      NSStringFromSelector(@selector(thumbShadowColor)),],
                                       NSStringFromClass(QMUITextField.class):                      @[NSStringFromSelector(@selector(placeholderColor)),],
                                       NSStringFromClass(QMUITextView.class):                       @[NSStringFromSelector(@selector(placeholderColor)),],
                                       NSStringFromClass(QMUIVisualEffectView.class):               @[NSStringFromSelector(@selector(foregroundColor)),],
                                       NSStringFromClass(QMUIToastBackgroundView.class):            @[NSStringFromSelector(@selector(styleColor)),],
                                       
                                       // UITextField 支持富文本，因此不能重新设置 textColor 那些属性，会令原有的富文本信息丢失，所以这里直接把文字重新赋值进去即可
                                       // 注意，UITextField 在未聚焦时，切换主题时系统能自动刷新文字颜色，但在聚焦时系统不会自动刷新颜色，所以需要在这里手动刷新
                                       NSStringFromClass(UITextField.class):                        @[NSStringFromSelector(@selector(attributedText)),],
                                       
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
        if (@available(iOS 13.0, *)) {
        } else {
            OverrideImplementation([UIView class], @selector(setTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject, UIColor *tintColor) {
                    
                    // iOS 12 及以下，-[UIView setTintColor:] 被调用时，如果参数的 tintColor 与当前的 tintColor 指针相同，则不会触发 tintColorDidChange，但这对于 dynamic color 而言是不满足需求的（同一个 dynamic color 实例在任何时候返回的 rawColor 都有可能发生变化），所以这里主动为其做一次 copy 操作，规避指针地址判断的问题
                    if (tintColor.qmui_isDynamicColor && tintColor == selfObject.tintColor) tintColor = tintColor.copy;
                    
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

@implementation UISwitch (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 这里反而是 iOS 13 才需要用 copy 的方式强制触发更新，否则如果某个 UISwitch 处于 off 的状态，此时去更新它的 onTintColor 不会立即生效，而是要等切换到 on 时，才会看到旧的 onTintColor 一闪而过变成新的 onTintColor，所以这里加个强制刷新
        // TODO: molice 等正式版出来要检查一下是否还需要
        if (@available(iOS 13.0, *)) {
            OverrideImplementation([UISwitch class], @selector(setOnTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISwitch *selfObject, UIColor *tintColor) {
                    
                    if (tintColor.qmui_isDynamicColor && tintColor == selfObject.onTintColor) tintColor = tintColor.copy;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, tintColor);
                };
            });
            
            OverrideImplementation([UISwitch class], @selector(setThumbTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISwitch *selfObject, UIColor *tintColor) {
                    
                    if (tintColor.qmui_isDynamicColor && tintColor == selfObject.thumbTintColor) tintColor = tintColor.copy;
                    
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
                
                if (tintColor.qmui_isDynamicColor && tintColor == selfObject.minimumTrackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UISlider class], @selector(setMaximumTrackTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isDynamicColor && tintColor == selfObject.maximumTrackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UISlider class], @selector(setThumbTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isDynamicColor && tintColor == selfObject.thumbTintColor) tintColor = tintColor.copy;
                
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
                
                if (tintColor.qmui_isDynamicColor && tintColor == selfObject.progressTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UIProgressView class], @selector(setTrackTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIProgressView *selfObject, UIColor *tintColor) {
                
                if (tintColor.qmui_isDynamicColor && tintColor == selfObject.trackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
    });
}

@end

@implementation UITableViewCell (QMUIThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
        } else {
            //  iOS 12 及以下，-[UITableViewCell setBackgroundColor:] 被调用时，如果参数的 backgroundColor 与当前的 backgroundColor 指针相同，则不会真正去执行颜色设置的逻辑，但这对于 dynamic color 而言是不满足需求的（同一个 dynamic color 实例在任何时候返回的 rawColor 都有可能发生变化），所以这里主动为其做一次 copy 操作，规避指针地址判断的问题
            OverrideImplementation([UITableViewCell class], @selector(setBackgroundColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITableViewCell *selfObject, UIColor *backgroundColor) {
                     if (backgroundColor.qmui_isDynamicColor && backgroundColor == selfObject.backgroundColor) backgroundColor = backgroundColor.copy;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, backgroundColor);
                };
            });
        }
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
