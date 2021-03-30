/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UISearchBar+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/5/26.
//

#import "UISearchBar+QMUI.h"
#import "QMUICore.h"
#import "UIImage+QMUI.h"
#import "UIView+QMUI.h"

@interface UISearchBar ()

@property(nonatomic, assign) CGFloat qmuisb_centerPlaceholderCachedWidth1;
@property(nonatomic, assign) CGFloat qmuisb_centerPlaceholderCachedWidth2;
@property(nonatomic, assign) UIEdgeInsets qmuisb_customTextFieldMargins;
@end

@implementation UISearchBar (QMUI)

QMUISynthesizeBOOLProperty(qmui_usedAsTableHeaderView, setQmui_usedAsTableHeaderView)
QMUISynthesizeBOOLProperty(qmui_alwaysEnableCancelButton, setQmui_alwaysEnableCancelButton)
QMUISynthesizeBOOLProperty(qmui_fixMaskViewLayoutBugAutomatically, setQmui_fixMaskViewLayoutBugAutomatically)
QMUISynthesizeUIEdgeInsetsProperty(qmuisb_customTextFieldMargins, setQmuisb_customTextFieldMargins)
QMUISynthesizeCGFloatProperty(qmuisb_centerPlaceholderCachedWidth1, setQmuisb_centerPlaceholderCachedWidth1)
QMUISynthesizeCGFloatProperty(qmuisb_centerPlaceholderCachedWidth2, setQmuisb_centerPlaceholderCachedWidth2)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        void (^setupCancelButtonBlock)(UISearchBar *, UIButton *) = ^void(UISearchBar *searchBar, UIButton *cancelButton) {
            if (searchBar.qmui_alwaysEnableCancelButton && !searchBar.qmui_searchController) {
                cancelButton.enabled = YES;
            }
            
            if (cancelButton && searchBar.qmui_cancelButtonFont) {
                cancelButton.titleLabel.font = searchBar.qmui_cancelButtonFont;
            }
            
            if (searchBar.qmui_cancelButtonMarginsBlock && cancelButton && !cancelButton.qmui_frameWillChangeBlock) {
                __weak __typeof(searchBar)weakSearchBar = searchBar;
                cancelButton.qmui_frameWillChangeBlock = ^CGRect(UIButton *aCancelButton, CGRect followingFrame) {
                    return [weakSearchBar qmuisb_adjustCancelButtonFrame:followingFrame];
                };
            } else if (!searchBar.qmui_cancelButtonMarginsBlock) {
                cancelButton.qmui_frameWillChangeBlock = nil;
            }
        };
        
        if (@available(iOS 13.0, *)) {
            // iOS 13 开始 UISearchBar 内部的输入框、取消按钮等 subviews 都由这个 class 创建、管理
            ExtendImplementationOfVoidMethodWithoutArguments(NSClassFromString(@"_UISearchBarVisualProviderIOS"), NSSelectorFromString(@"setUpCancelButton"), ^(NSObject *selfObject) {
                UIButton *cancelButton = [selfObject qmui_valueForKey:@"cancelButton"];
                UISearchBar *searchBar = (UISearchBar *)cancelButton.superview.superview.superview;
                NSAssert([searchBar isKindOfClass:UISearchBar.class], @"Can not find UISearchBar from cancelButton");
                setupCancelButtonBlock(searchBar, cancelButton);
            });
        } else {
            ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], NSSelectorFromString(@"_setupCancelButton"), ^(UISearchBar *selfObject) {
                setupCancelButtonBlock(selfObject, selfObject.qmui_cancelButton);
            });
        }
        
        OverrideImplementation(NSClassFromString(@"UINavigationButton"), @selector(setEnabled:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIButton *selfObject, BOOL firstArgv) {
                
                UISearchBar *searchBar = nil;
                if (@available(iOS 13.0, *)) {
                    searchBar = (UISearchBar *)selfObject.superview.superview.superview;
                } else {
                    searchBar = (UISearchBar *)selfObject.superview.superview;
                }
                NSAssert(!searchBar || [searchBar isKindOfClass:UISearchBar.class], @"Can not find UISearchBar from cancelButton");
                if (searchBar.qmui_alwaysEnableCancelButton && !searchBar.qmui_searchController) {
                    firstArgv = YES;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UISearchBar class], @selector(setPlaceholder:), NSString *, (^(UISearchBar *selfObject, NSString *placeholder) {
            if (selfObject.qmui_placeholderColor || selfObject.qmui_font) {
                NSMutableAttributedString *string = selfObject.qmui_textField.attributedPlaceholder.mutableCopy;
                if (selfObject.qmui_placeholderColor) {
                    [string addAttribute:NSForegroundColorAttributeName value:selfObject.qmui_placeholderColor range:NSMakeRange(0, string.length)];
                }
                if (selfObject.qmui_font) {
                    [string addAttribute:NSFontAttributeName value:selfObject.qmui_font range:NSMakeRange(0, string.length)];
                }
                // 默认移除文字阴影
                [string removeAttribute:NSShadowAttributeName range:NSMakeRange(0, string.length)];
                selfObject.qmui_textField.attributedPlaceholder = string.copy;
            }
        }));
        
        // iOS 13 下，UISearchBar 内的 UITextField 的 _placeholderLabel 会在 didMoveToWindow 时被重新设置 textColor，导致我们在 searchBar 添加到界面之前设置的 placeholderColor 失效，所以在这里重新设置一遍
        // https://github.com/Tencent/QMUI_iOS/issues/830
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(didMoveToWindow), ^(UISearchBar *selfObject) {
                if (selfObject.qmui_placeholderColor) {
                    selfObject.placeholder = selfObject.placeholder;
                }
            });
        }

        if (@available(iOS 13.0, *)) {
            // -[_UISearchBarLayout applyLayout] 是 iOS 13 系统新增的方法，该方法可能会在 -[UISearchBar layoutSubviews] 后调用，作进一步的布局调整。
            Class _UISearchBarLayoutClass = NSClassFromString([NSString stringWithFormat:@"_%@%@",@"UISearchBar", @"Layout"]);
            OverrideImplementation(_UISearchBarLayoutClass, NSSelectorFromString(@"applyLayout"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject) {
                    
                    // call super
                    void (^callSuperBlock)(void) = ^{
                        void (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD);
                    };

                    UISearchBar *searchBar = (UISearchBar *)((UIView *)[selfObject qmui_valueForKey:[NSString stringWithFormat:@"_%@",@"searchBarBackground"]]).superview.superview;
                    
                    NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");

                    if (searchBar && searchBar.qmui_searchController.isBeingDismissed && searchBar.qmui_usedAsTableHeaderView) {
                        CGRect previousRect = searchBar.qmui_backgroundView.frame;
                        callSuperBlock();
                        // applyLayout 方法中会修改 _searchBarBackground  的 frame ，从而覆盖掉 qmui_usedAsTableHeaderView 做出的调整，所以这里还原本次修改。
                        searchBar.qmui_backgroundView.frame = previousRect;
                    } else {
                        callSuperBlock();
                    }
                };
                
            });
            
            if (@available(iOS 14.0, *)) {
                // iOS 14 beta 1 修改了 searchTextField 的 font 属性会导致 TextField 高度异常，从而导致 searchBarContainerView 的高度异常，临时修复一下
                Class _UISearchBarContainerViewClass = NSClassFromString([NSString stringWithFormat:@"_%@%@",@"UISearchBar", @"ContainerView"]);
                OverrideImplementation(_UISearchBarContainerViewClass, @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIView *selfObject, CGRect frame) {
                        UISearchBar *searchBar = selfObject.subviews.firstObject;
                        if ([searchBar isKindOfClass:[UISearchBar class]]) {
                            if (searchBar.qmuisb_shouldFixLayoutWhenUsedAsTableHeaderView && searchBar.qmui_isActive) {
                                // 刘海屏即使隐藏了 statusBar 也不会影响 containerView 的高度，要把 statusBar 计算在内
                                CGFloat currentStatusBarHeight = IS_NOTCHED_SCREEN ? StatusBarHeightConstant : StatusBarHeight;
                                if (frame.origin.y < currentStatusBarHeight + NavigationBarHeight) {
                                    // 非刘海屏在隐藏了 statusBar 后，如果只计算激活时的高度则为 50，这种情况下应该取 56
                                    frame.size.height = MAX(UISearchBar.qmuisb_seachBarDefaultActiveHeight + currentStatusBarHeight, 56);
                                    frame.origin.y = 0;
                                }
                            }
                        }
                        void (*originSelectorIMP)(id, SEL, CGRect);
                        originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, frame);
                    };
                });
            }
        }
        
        OverrideImplementation(NSClassFromString([NSString stringWithFormat:@"%@%@",@"UISearchBarText", @"Field"]), @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITextField *textField, CGRect frame) {
                UISearchBar *searchBar = nil;
                if (@available(iOS 13.0, *)) {
                    searchBar = (UISearchBar *)textField.superview.superview.superview;
                } else {
                    searchBar = (UISearchBar *)textField.superview.superview;
                }
                
                NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");
                
                if (searchBar) {
                    frame = [searchBar qmuisb_adjustedSearchTextFieldFrameByOriginalFrame:frame];
                }
                
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(textField, originCMD, frame);
                
                [searchBar qmuisb_searchTextFieldFrameDidChange];
            };
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(layoutSubviews), ^(UISearchBar *selfObject) {
            
            // 修复 iOS 13 backgroundView 没有撑开到顶部的问题
            if (IOS_VERSION >= 13.0 && selfObject.qmui_usedAsTableHeaderView && selfObject.qmui_isActive) {
                selfObject.qmui_backgroundView.qmui_height = StatusBarHeightConstant + selfObject.qmui_height;
                selfObject.qmui_backgroundView.qmui_top = -StatusBarHeightConstant;
            }
            [selfObject qmuisb_fixDismissingAnimationIfNeeded];
            [selfObject qmuisb_fixSearchResultsScrollViewContentInsetIfNeeded];
            
        });
        
        OverrideImplementation([UISearchBar class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchBar *selfObject, CGRect frame) {
                
                frame = [selfObject qmuisb_adjustedSearchBarFrameByOriginalFrame:frame];
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
                
            };
        });
        
        // [UIKit Bug] 当 UISearchController.searchBar 作为 tableHeaderView 使用时，顶部可能出现 1px 的间隙导致露出背景色
        // https://github.com/Tencent/QMUI_iOS/issues/950
        OverrideImplementation([UISearchBar class], NSSelectorFromString(@"_setMaskBounds:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchBar *selfObject, CGRect firstArgv) {
                
                BOOL shouldFixBug = selfObject.qmui_fixMaskViewLayoutBugAutomatically
                && selfObject.qmui_searchController
                && [selfObject.superview isKindOfClass:UITableView.class]
                && ((UITableView *)selfObject.superview).tableHeaderView == selfObject;
                if (shouldFixBug) {
                    firstArgv = CGRectMake(CGRectGetMinX(firstArgv), CGRectGetMinY(firstArgv) - PixelOne, CGRectGetWidth(firstArgv), CGRectGetHeight(firstArgv) + PixelOne);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        // [UIKit Bug] 将 UISearchBar 作为 UITableView.tableHeaderView 使用时，如果列表内容不满一屏，可能出现搜索框不可视的问题
        // https://github.com/Tencent/QMUI_iOS/issues/1207
        if (@available(iOS 11.0, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(didMoveToSuperview), ^(UISearchBar *selfObject) {
                if (selfObject.superview && CGRectGetHeight(selfObject.subviews.firstObject.frame) != CGRectGetHeight(selfObject.bounds)) {
                    BeginIgnorePerformSelectorLeaksWarning
                    [selfObject.qmui_searchController performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@%@MaskIfNecessary", @"_update", @"SearchBar"])];
                    EndIgnorePerformSelectorLeaksWarning
                }
            });
        }
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UISearchBar class], @selector(initWithFrame:), CGRect, UISearchBar *, ^UISearchBar *(UISearchBar *selfObject, CGRect firstArgv, UISearchBar *originReturnValue) {
            [originReturnValue qmuisb_didInitialize];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UISearchBar class], @selector(initWithCoder:), NSCoder *, UISearchBar *, ^UISearchBar *(UISearchBar *selfObject, NSCoder *firstArgv, UISearchBar *originReturnValue) {
            [originReturnValue qmuisb_didInitialize];
            return originReturnValue;
        });
    });
}

- (void)qmuisb_didInitialize {
    self.qmui_alwaysEnableCancelButton = YES;
    self.qmui_showsLeftAccessoryView = YES;
    self.qmui_showsRightAccessoryView = YES;
    
    if (QMUICMIActivated && ShouldFixSearchBarMaskViewLayoutBug) {
        self.qmui_fixMaskViewLayoutBugAutomatically = YES;
    }
}

static char kAssociatedObjectKey_centerPlaceholder;
- (void)setQmui_centerPlaceholder:(BOOL)qmui_centerPlaceholder {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_centerPlaceholder, @(qmui_centerPlaceholder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    __weak __typeof(self)weakSelf = self;
    if (qmui_centerPlaceholder) {
        self.qmui_textField.qmui_layoutSubviewsBlock = ^(UITextField * _Nonnull textField) {
            
            // 某些中间状态 textField 的宽度会出现负值，但由于 CGRectGetWidth() 一定是返回正值的，所以这里必须用 bounds.size.width 的方式取值，而不是用 CGRectGetWidth()
            if (textField.bounds.size.width <= 0) return;
            
            if (textField.isEditing || textField.text.length > 0) {
                weakSelf.qmuisb_centerPlaceholderCachedWidth1 = 0;
                weakSelf.qmuisb_centerPlaceholderCachedWidth2 = 0;
                if (!UIOffsetEqualToOffset(UIOffsetZero, [weakSelf positionAdjustmentForSearchBarIcon:UISearchBarIconSearch])) {
                    [weakSelf setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
                    [textField layoutIfNeeded];// 在切换搜索状态时要让 positionAdjustment 立即生效，才能看到动画效果
                }
            } else {
                UIView *leftView = [textField qmui_valueForKey:@"leftView"];
                UILabel *label = [textField qmui_valueForKey:@"placeholderLabel"];
                CGFloat width = CGRectGetMaxX(label.frame) - CGRectGetMinX(leftView.frame);
                if (fabs(CGRectGetWidth(textField.bounds) - weakSelf.qmuisb_centerPlaceholderCachedWidth1) > 1 || fabs(width - weakSelf.qmuisb_centerPlaceholderCachedWidth2) > 1) {
                    weakSelf.qmuisb_centerPlaceholderCachedWidth1 = CGRectGetWidth(textField.bounds);
                    weakSelf.qmuisb_centerPlaceholderCachedWidth2 = width;
                    CGFloat searchIconDefaultMarginLeft = 6; // 系统的放大镜 icon 默认距离 textField 左边就是这个值，计算居中时要考虑进去，因为 positionAdjustment 是基于系统默认布局的基础上做偏移的
                    CGFloat horizontal = (weakSelf.qmuisb_centerPlaceholderCachedWidth1 - weakSelf.qmuisb_centerPlaceholderCachedWidth2) / 2.0 - searchIconDefaultMarginLeft;// 这里没有用 CGFloatGetCenter 是为了避免 iOS 12 及以下 iPhone 8 Plus tableView 显示右边的索引条时，每次算出来都差1，第一次49第二次50第三次49...陷入死循环，干脆不要操作精度取整
                    [weakSelf setPositionAdjustment:UIOffsetMake(horizontal, 0) forSearchBarIcon:UISearchBarIconSearch];
                    [textField layoutIfNeeded];// 在切换搜索状态时要让 positionAdjustment 立即生效，才能看到动画效果
                }
            }
        };
        [self.qmui_textField setNeedsLayout];
    } else {
        self.qmui_textField.qmui_layoutSubviewsBlock = nil;
        self.qmuisb_centerPlaceholderCachedWidth1 = 0;
        self.qmuisb_centerPlaceholderCachedWidth2 = 0;
        [self setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    }
}

- (BOOL)qmui_centerPlaceholder {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_centerPlaceholder)) boolValue];
}

static char kAssociatedObjectKey_PlaceholderColor;
- (void)setQmui_placeholderColor:(UIColor *)qmui_placeholderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor, qmui_placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
        self.placeholder = self.placeholder;
    }
}

- (UIColor *)qmui_placeholderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor);
}

static char kAssociatedObjectKey_TextColor;
- (void)setQmui_textColor:(UIColor *)qmui_textColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_TextColor, qmui_textColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_textField.textColor = qmui_textColor;
}

- (UIColor *)qmui_textColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_TextColor);
}

static char kAssociatedObjectKey_font;
- (void)setQmui_font:(UIFont *)qmui_font {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_font, qmui_font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
        self.placeholder = self.placeholder;
    }
    
    // 更新输入框的文字样式
    self.qmui_textField.font = qmui_font;
}

- (UIFont *)qmui_font {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_font);
}

- (UITextField *)qmui_textField {
    if (@available(iOS 13.0, *)) {
        return self.searchTextField;
    }
    UITextField *textField = [self qmui_valueForKey:@"searchField"];
    return textField;
}

- (UIButton *)qmui_cancelButton {
    UIButton *cancelButton = [self qmui_valueForKey:@"cancelButton"];
    return cancelButton;
}

static char kAssociatedObjectKey_cancelButtonFont;
- (void)setQmui_cancelButtonFont:(UIFont *)qmui_cancelButtonFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cancelButtonFont, qmui_cancelButtonFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_cancelButton.titleLabel.font = qmui_cancelButtonFont;
}

- (UIFont *)qmui_cancelButtonFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cancelButtonFont);
}

static char kAssociatedObjectKey_cancelButtonMarginsBlock;
- (void)setQmui_cancelButtonMarginsBlock:(UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))qmui_cancelButtonMarginsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cancelButtonMarginsBlock, qmui_cancelButtonMarginsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self.qmui_cancelButton.superview setNeedsLayout];
}

- (UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))qmui_cancelButtonMarginsBlock {
    return (UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_cancelButtonMarginsBlock);
}

static char kAssociatedObjectKey_textFieldMargins;
- (void)setQmui_textFieldMargins:(UIEdgeInsets)qmui_textFieldMargins {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_textFieldMargins, @(qmui_textFieldMargins), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qmuisb_setNeedsLayoutTextField];
}

- (UIEdgeInsets)qmui_textFieldMargins {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_textFieldMargins)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_textFieldMarginsBlock;
- (void)setQmui_textFieldMarginsBlock:(UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))qmui_textFieldMarginsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_textFieldMarginsBlock, qmui_textFieldMarginsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self qmuisb_setNeedsLayoutTextField];
}

- (UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))qmui_textFieldMarginsBlock {
    return (UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_textFieldMarginsBlock);
}

- (UISegmentedControl *)qmui_segmentedControl {
    UISegmentedControl *segmentedControl = [self qmui_valueForKey:@"scopeBar"];
    return segmentedControl;
}

- (BOOL)qmui_isActive {
    return (self.qmui_searchController.isBeingPresented || self.qmui_searchController.isActive);
}

- (UISearchController *)qmui_searchController {
    return [self qmui_valueForKey:@"_searchController"];
}

- (UIView *)qmui_backgroundView {
    BeginIgnorePerformSelectorLeaksWarning
    UIView *backgroundView = [self performSelector:NSSelectorFromString(@"_backgroundView")];
    EndIgnorePerformSelectorLeaksWarning
    return backgroundView;
}

- (void)qmui_styledAsQMUISearchBar {
    if (!QMUICMIActivated) {
        return;
    }
    
    // 搜索框的字号及 placeholder 的字号
    self.qmui_font = SearchBarFont;

    // 搜索框的文字颜色
    self.qmui_textColor = SearchBarTextColor;

    // placeholder 的文字颜色
    self.qmui_placeholderColor = SearchBarPlaceholderColor;

    self.placeholder = @"搜索";
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;

    // 设置搜索icon
    UIImage *searchIconImage = SearchBarSearchIconImage;
    if (searchIconImage) {
        if (!CGSizeEqualToSize(searchIconImage.size, CGSizeMake(14, 14))) {
            NSLog(@"搜索框放大镜图片（SearchBarSearchIconImage）的大小最好为 (14, 14)，否则会失真，目前的大小为 %@", NSStringFromCGSize(searchIconImage.size));
        }
        [self setImage:searchIconImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }

    // 设置搜索右边的清除按钮的icon
    UIImage *clearIconImage = SearchBarClearIconImage;
    if (clearIconImage) {
        [self setImage:clearIconImage forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    }

    // 设置SearchBar上的按钮颜色
    self.tintColor = SearchBarTintColor;

    // 输入框背景图
    UIImage *searchFieldBackgroundImage = SearchBarTextFieldBackgroundImage;
    if (searchFieldBackgroundImage) {
        [self setSearchFieldBackgroundImage:searchFieldBackgroundImage forState:UIControlStateNormal];
    }
    
    // 输入框边框
    UIColor *textFieldBorderColor = SearchBarTextFieldBorderColor;
    if (textFieldBorderColor) {
        self.qmui_textField.layer.borderWidth = PixelOne;
        self.qmui_textField.layer.borderColor = textFieldBorderColor.CGColor;
    }
    
    // 整条bar的背景
    // 为了让 searchBar 底部的边框颜色支持修改，背景色不使用 barTintColor 的方式去改，而是用 backgroundImage
    UIImage *backgroundImage = SearchBarBackgroundImage;
    if (backgroundImage) {
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefaultPrompt];
    }
}

+ (UIImage *)qmui_generateTextFieldBackgroundImageWithColor:(UIColor *)color {
    // 背景图片的高度会决定输入框的高度，在 iOS 11 及以上，系统默认高度是 36，iOS 10 及以下的高度是 28 的搜索输入框的高度计算:QMUIKit/UIKitExtensions/UISearchBar+QMUI.m
    // 至于圆角，输入框会在 UIView 层面控制，背景图里无需处理
    return [[UIImage qmui_imageWithColor:color size:self.qmuisb_textFieldDefaultSize cornerRadius:0] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
}

+ (UIImage *)qmui_generateBackgroundImageWithColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor {
    UIImage *backgroundImage = nil;
    if (backgroundColor || borderColor) {
        backgroundImage = [UIImage qmui_imageWithColor:backgroundColor ?: UIColorWhite size:CGSizeMake(10, 10) cornerRadius:0];
        if (borderColor) {
            backgroundImage = [backgroundImage qmui_imageWithBorderColor:borderColor borderWidth:PixelOne borderPosition:QMUIImageBorderPositionBottom];
        }
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    }
    return backgroundImage;
}

#pragma mark - Left Accessory View

static char kAssociatedObjectKey_showsLeftAccessoryView;
- (void)qmui_setShowsLeftAccessoryView:(BOOL)showsLeftAccessoryView animated:(BOOL)animated {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_showsLeftAccessoryView, @(showsLeftAccessoryView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (animated) {
        if (showsLeftAccessoryView) {
            self.qmui_leftAccessoryView.hidden = NO;
            self.qmui_leftAccessoryView.qmui_frameApplyTransform = CGRectSetXY(self.qmui_leftAccessoryView.frame, -CGRectGetWidth(self.qmui_leftAccessoryView.frame), CGRectGetMinYVerticallyCenter(self.qmui_textField.frame, self.qmui_leftAccessoryView.frame));
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self qmuisb_updateCustomTextFieldMargins];
            } completion:nil];
        } else {
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.qmui_leftAccessoryView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(self.qmui_leftAccessoryView.frame), 0);
                [self qmuisb_updateCustomTextFieldMargins];
            } completion:^(BOOL finished) {
                self.qmui_leftAccessoryView.hidden = YES;
                self.qmui_leftAccessoryView.transform = CGAffineTransformIdentity;
            }];
        }
    } else {
        self.qmui_leftAccessoryView.hidden = !showsLeftAccessoryView;
        [self qmuisb_updateCustomTextFieldMargins];
    }
}

- (void)setQmui_showsLeftAccessoryView:(BOOL)qmui_showsLeftAccessoryView {
    [self qmui_setShowsLeftAccessoryView:qmui_showsLeftAccessoryView animated:NO];
}

- (BOOL)qmui_showsLeftAccessoryView {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_showsLeftAccessoryView)) boolValue];
}

static char kAssociatedObjectKey_leftAccessoryView;
- (void)setQmui_leftAccessoryView:(UIView *)qmui_leftAccessoryView {
    if (self.qmui_leftAccessoryView != qmui_leftAccessoryView) {
        [self.qmui_leftAccessoryView removeFromSuperview];
        [self.qmui_textField.superview addSubview:qmui_leftAccessoryView];
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_leftAccessoryView, qmui_leftAccessoryView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    qmui_leftAccessoryView.hidden = !self.qmui_showsLeftAccessoryView;
    [qmui_leftAccessoryView sizeToFit];
    
    [self qmuisb_updateCustomTextFieldMargins];
}

- (UIView *)qmui_leftAccessoryView {
    return (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_leftAccessoryView);
}

static char kAssociatedObjectKey_leftAccessoryViewMargins;
- (void)setQmui_leftAccessoryViewMargins:(UIEdgeInsets)qmui_leftAccessoryViewMargins {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_leftAccessoryViewMargins, @(qmui_leftAccessoryViewMargins), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qmuisb_updateCustomTextFieldMargins];
}

- (UIEdgeInsets)qmui_leftAccessoryViewMargins {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_leftAccessoryViewMargins)) UIEdgeInsetsValue];
}

// 这个方法会在 textField 调整完布局后才调用，所以可以直接基于 textField 当前的布局去计算布局
- (void)qmuisb_adjustLeftAccessoryViewFrameAfterTextFieldLayout {
    if (self.qmui_leftAccessoryView && !self.qmui_leftAccessoryView.hidden) {
        self.qmui_leftAccessoryView.qmui_frameApplyTransform = CGRectSetXY(self.qmui_leftAccessoryView.frame, CGRectGetMinX(self.qmui_textField.frame) - [UISearchBar qmuisb_textFieldDefaultMargins].left - self.qmui_leftAccessoryViewMargins.right - CGRectGetWidth(self.qmui_leftAccessoryView.frame), CGRectGetMinYVerticallyCenter(self.qmui_textField.frame, self.qmui_leftAccessoryView.frame));
    }
}

#pragma mark - Right Accessory View

static char kAssociatedObjectKey_showsRightAccessoryView;
- (void)qmui_setShowsRightAccessoryView:(BOOL)showsRightAccessoryView animated:(BOOL)animated {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_showsRightAccessoryView, @(showsRightAccessoryView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (animated) {
        BOOL shouldAnimateAlpha = self.showsCancelButton;// 由于 rightAccessoryView 会从 cancelButton 那边飞过来，会有一点重叠，所以加一个 alpha 过渡
        if (showsRightAccessoryView) {
            self.qmui_rightAccessoryView.hidden = NO;
            self.qmui_rightAccessoryView.qmui_frameApplyTransform = CGRectSetXY(self.qmui_rightAccessoryView.frame, CGRectGetWidth(self.qmui_rightAccessoryView.superview.bounds), CGRectGetMinYVerticallyCenter(self.qmui_textField.frame, self.qmui_rightAccessoryView.frame));
            if (shouldAnimateAlpha) {
                self.qmui_rightAccessoryView.alpha = 0;
            }
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self qmuisb_updateCustomTextFieldMargins];
                if (shouldAnimateAlpha) {
                    self.qmui_rightAccessoryView.alpha = 1;
                }
            } completion:nil];
        } else {
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.qmui_rightAccessoryView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.qmui_rightAccessoryView.superview.bounds) - CGRectGetMinX(self.qmui_rightAccessoryView.frame), 0);
                [self qmuisb_updateCustomTextFieldMargins];
            } completion:^(BOOL finished) {
                self.qmui_rightAccessoryView.hidden = YES;
                self.qmui_rightAccessoryView.transform = CGAffineTransformIdentity;
                self.qmui_rightAccessoryView.alpha = 1;
            }];
            if (shouldAnimateAlpha) {
                [UIView animateWithDuration:.18 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.qmui_rightAccessoryView.alpha = 0;
                } completion:nil];
            }
        }
    } else {
        self.qmui_rightAccessoryView.hidden = !showsRightAccessoryView;
        [self qmuisb_updateCustomTextFieldMargins];
    }
}

- (void)setQmui_showsRightAccessoryView:(BOOL)qmui_showsRightAccessoryView {
    [self qmui_setShowsRightAccessoryView:qmui_showsRightAccessoryView animated:NO];
}

- (BOOL)qmui_showsRightAccessoryView {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_showsRightAccessoryView)) boolValue];
}

static char kAssociatedObjectKey_rightAccessoryView;
- (void)setQmui_rightAccessoryView:(UIView *)qmui_rightAccessoryView {
    if (self.qmui_rightAccessoryView != qmui_rightAccessoryView) {
        [self.qmui_rightAccessoryView removeFromSuperview];
        [self.qmui_textField.superview addSubview:qmui_rightAccessoryView];
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_rightAccessoryView, qmui_rightAccessoryView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    qmui_rightAccessoryView.hidden = !self.qmui_showsRightAccessoryView;
    [qmui_rightAccessoryView sizeToFit];
    
    [self qmuisb_updateCustomTextFieldMargins];
}

- (UIView *)qmui_rightAccessoryView {
    return (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_rightAccessoryView);
}

static char kAssociatedObjectKey_rightAccessoryViewMargins;
- (void)setQmui_rightAccessoryViewMargins:(UIEdgeInsets)qmui_rightAccessoryViewMargins {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_rightAccessoryViewMargins, @(qmui_rightAccessoryViewMargins), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qmuisb_updateCustomTextFieldMargins];
}

- (UIEdgeInsets)qmui_rightAccessoryViewMargins {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_rightAccessoryViewMargins)) UIEdgeInsetsValue];
}

- (void)qmuisb_updateCustomTextFieldMargins {
    // 用 qmui_showsLeftAccessoryView 而不是用 !qmui_leftAccessoryView.hidden 是因为做动画时可能 hidden 值还没更新，所以用标志位来区分
    BOOL shouldShowLeftAccessoryView = self.qmui_showsLeftAccessoryView && self.qmui_leftAccessoryView;
    BOOL shouldShowRightAccessoryView = self.qmui_showsRightAccessoryView && self.qmui_rightAccessoryView;
    CGFloat leftMargin = shouldShowLeftAccessoryView ? CGRectGetWidth(self.qmui_leftAccessoryView.frame) + UIEdgeInsetsGetHorizontalValue(self.qmui_leftAccessoryViewMargins) : 0;
    CGFloat rightMargin = shouldShowRightAccessoryView ? CGRectGetWidth(self.qmui_rightAccessoryView.frame) + UIEdgeInsetsGetHorizontalValue(self.qmui_rightAccessoryViewMargins) : 0;
    
    if (self.qmuisb_customTextFieldMargins.left != leftMargin || self.qmuisb_customTextFieldMargins.right != rightMargin) {
        self.qmuisb_customTextFieldMargins = UIEdgeInsetsMake(self.qmuisb_customTextFieldMargins.top, leftMargin, self.qmuisb_customTextFieldMargins.bottom, rightMargin);
        [self qmuisb_setNeedsLayoutTextField];
    }
}

// 这个方法会在 textField 调整完布局后才调用，所以可以直接基于 textField 当前的布局去计算布局
- (void)qmuisb_adjustRightAccessoryViewFrameAfterTextFieldLayout {
    if (self.qmui_rightAccessoryView && !self.qmui_rightAccessoryView.hidden) {
        self.qmui_rightAccessoryView.qmui_frameApplyTransform = CGRectSetXY(self.qmui_rightAccessoryView.frame, CGRectGetMaxX(self.qmui_textField.frame) + [UISearchBar qmuisb_textFieldDefaultMargins].right + self.qmui_textFieldMargins.right + self.qmui_rightAccessoryViewMargins.left, CGRectGetMinYVerticallyCenter(self.qmui_textField.frame, self.qmui_rightAccessoryView.frame));
    }
}

#pragma mark - Layout

- (void)qmuisb_setNeedsLayoutTextField {
    if (self.qmui_textField && !CGRectIsEmpty(self.qmui_textField.frame)) {
        if (@available(iOS 13.0, *)) {
            [self.qmui_textField.superview setNeedsLayout];
            [self.qmui_textField.superview layoutIfNeeded];
        } else {
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    }
}

- (BOOL)qmuisb_shouldFixLayoutWhenUsedAsTableHeaderView {
    if (@available(iOS 11, *)) {
        return self.qmui_usedAsTableHeaderView && self.qmui_searchController.hidesNavigationBarDuringPresentation;
    }
    return NO;
}

- (CGRect)qmuisb_adjustCancelButtonFrame:(CGRect)followingFrame {
    if (self.qmuisb_shouldFixLayoutWhenUsedAsTableHeaderView) {
        CGRect textFieldFrame = self.qmui_textField.frame;
        
        BOOL shouldFixCancelButton = NO;
        if (@available(iOS 13.0, *)) {
            shouldFixCancelButton = YES;// iOS 13 当 searchBar 作为 tableHeaderView 使用时，并且非搜索状态下 searchBar.showsCancelButton = YES，则进入搜搜状态后再退出，可看到 cancelButton 下降过程中会有抖动
        } else {
            shouldFixCancelButton = self.qmui_isActive;
        }
        if (shouldFixCancelButton) {
            followingFrame = CGRectSetY(followingFrame, CGRectGetMinYVerticallyCenter(textFieldFrame, followingFrame));
        }
    }
    
    if (self.qmui_cancelButtonMarginsBlock) {
        UIEdgeInsets insets = self.qmui_cancelButtonMarginsBlock(self, self.qmui_isActive);
        followingFrame = CGRectInsetEdges(followingFrame, insets);
    }
    return followingFrame;
}

- (void)qmuisb_adjustSegmentedControlFrameIfNeeded {
    if (!self.qmuisb_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    if (self.qmui_isActive) {
        CGRect textFieldFrame = self.qmui_textField.frame;
        if (self.qmui_segmentedControl.superview.qmui_top < self.qmui_textField.qmui_bottom) {
            // scopeBar 显示在搜索框右边
            self.qmui_segmentedControl.superview.qmui_top = CGRectGetMinYVerticallyCenter(textFieldFrame, self.qmui_segmentedControl.superview.frame);
        }
    }
}

- (CGRect)qmuisb_adjustedSearchBarFrameByOriginalFrame:(CGRect)frame {
    if (!self.qmuisb_shouldFixLayoutWhenUsedAsTableHeaderView) return frame;
    
    // 重写 setFrame: 是为了这个 issue：https://github.com/Tencent/QMUI_iOS/issues/233
    // iOS 11 下用 tableHeaderView 的方式使用 searchBar 的话，进入搜索状态时 y 偏上了，导致间距错乱
    // iOS 13 iPad 在退出动画时 y 值可能为负，需要修正
    
    if (self.qmui_searchController.isBeingDismissed && CGRectGetMinY(frame) < 0) {
        frame = CGRectSetY(frame, 0);
    }
    
    if (!self.qmui_isActive) {
        return frame;
    }
    
    if (IS_NOTCHED_SCREEN) {
        // 竖屏
        if (CGRectGetMinY(frame) == 38) {
            // searching
            frame = CGRectSetY(frame, 44);
        }
        
        // 全面屏 iPad
        if (CGRectGetMinY(frame) == 18) {
            // searching
            frame = CGRectSetY(frame, 24);
        }
        
        // 横屏
        if (CGRectGetMinY(frame) == -6) {
            frame = CGRectSetY(frame, 0);
        }
    } else {
        
        // 竖屏
        if (CGRectGetMinY(frame) == 14) {
            frame = CGRectSetY(frame, 20);
        }
        
        // 横屏
        if (CGRectGetMinY(frame) == -6) {
            frame = CGRectSetY(frame, 0);
        }
    }
    // 强制在激活状态下 高度也为 56，方便后续做平滑过渡动画 (iOS 11 默认下，非刘海屏的机器激活后为 50，刘海屏激活后为 55)
    if (frame.size.height != 56) {
        frame.size.height = 56;
    }
    return frame;
}

- (CGRect)qmuisb_adjustedSearchTextFieldFrameByOriginalFrame:(CGRect)frame {
    if (self.qmuisb_shouldFixLayoutWhenUsedAsTableHeaderView) {
        if (@available(iOS 14.0, *)) {
            // iOS 14 beta 1 修改了 searchTextField 的 font 属性会导致 TextField 高度异常，临时修复一下
            CGFloat fixedHeight = UISearchBar.qmuisb_textFieldDefaultSize.height;
            CGFloat offset = fixedHeight - frame.size.height;
            frame.origin.y -= offset / 2.0;
            frame.size.height = fixedHeight;
        }
        if (self.qmui_isActive) {
            BOOL statusBarHidden = NO;
            if (@available(iOS 13.0, *)) {
                statusBarHidden = self.window.windowScene.statusBarManager.statusBarHidden;
            } else {
                statusBarHidden = UIApplication.sharedApplication.statusBarHidden;
            }
            CGFloat visibleHeight = statusBarHidden ? 56 : 50;
            frame.origin.y = (visibleHeight - self.qmui_textField.qmui_height) / 2;
        } else if (self.qmui_searchController.isBeingDismissed) {
            frame.origin.y = (56 - self.qmui_textField.qmui_height) / 2;
        }
    }
    
    // apply qmui_textFieldMargins
    UIEdgeInsets textFieldMargins = UIEdgeInsetsZero;
    if (self.qmui_textFieldMarginsBlock) {
        textFieldMargins = self.qmui_textFieldMarginsBlock(self, self.qmui_isActive);
    } else {
        textFieldMargins = self.qmui_textFieldMargins;
    }
    if (!UIEdgeInsetsEqualToEdgeInsets(textFieldMargins, UIEdgeInsetsZero)) {
        frame = CGRectInsetEdges(frame, textFieldMargins);
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.qmuisb_customTextFieldMargins, UIEdgeInsetsZero)) {
        frame = CGRectInsetEdges(frame, self.qmuisb_customTextFieldMargins);
    }
    
    return frame;
}

- (void)qmuisb_searchTextFieldFrameDidChange {
    // apply SearchBarTextFieldCornerRadius
    CGFloat textFieldCornerRadius = SearchBarTextFieldCornerRadius;
    if (textFieldCornerRadius != 0) {
        textFieldCornerRadius = textFieldCornerRadius > 0 ? textFieldCornerRadius : CGRectGetHeight(self.qmui_textField.frame) / 2.0;
    }
    self.qmui_textField.layer.cornerRadius = textFieldCornerRadius;
    self.qmui_textField.clipsToBounds = textFieldCornerRadius != 0;
    
    [self qmuisb_adjustLeftAccessoryViewFrameAfterTextFieldLayout];
    [self qmuisb_adjustRightAccessoryViewFrameAfterTextFieldLayout];
    [self qmuisb_adjustSegmentedControlFrameIfNeeded];
}

- (void)qmuisb_fixDismissingAnimationIfNeeded {
    if (!self.qmuisb_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    
    if (self.qmui_searchController.isBeingDismissed) {
        
        if (IS_NOTCHED_SCREEN && self.frame.origin.y == 43) { // 修复刘海屏下，系统计算少了一个 pt
            self.frame = CGRectSetY(self.frame, StatusBarHeightConstant);
        }
        
        UIView *searchBarContainerView = self.superview;
        // 每次激活搜索框，searchBarContainerView 都会重新创建一个
        if (searchBarContainerView.layer.masksToBounds == YES) {
            searchBarContainerView.layer.masksToBounds = NO;
            // backgroundView 被 searchBarContainerView masksToBounds 裁减掉的底部。
            CGFloat backgroundViewBottomClipped = CGRectGetMaxY([searchBarContainerView convertRect:self.qmui_backgroundView.frame fromView:self.qmui_backgroundView.superview]) - CGRectGetHeight(searchBarContainerView.bounds);
            // UISeachbar 取消激活时，如果 BackgroundView 底部超出了 searchBarContainerView，需要以动画的形式来过渡：
            if (backgroundViewBottomClipped > 0) {
                CGFloat previousHeight = self.qmui_backgroundView.qmui_height;
                [UIView performWithoutAnimation:^{
                    // 先减去 backgroundViewBottomClipped 使得 backgroundView 和 searchBarContainerView 底部对齐，由于这个时机是包裹在 animationBlock 里的，所以要包裹在 performWithoutAnimation 中来设置
                    self.qmui_backgroundView.qmui_height -= backgroundViewBottomClipped;
                }];
                // 再还原高度，这里在 animationBlock 中，所以会以动画来过渡这个效果
                self.qmui_backgroundView.qmui_height = previousHeight;
                
                // 以下代码为了保持原有的顶部的 mask，否则在 NavigationBar 为透明或者磨砂时，会看到 backgroundView
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddRect(path, NULL, CGRectMake(0, 0, searchBarContainerView.qmui_width, previousHeight));
                maskLayer.path = path;
                searchBarContainerView.layer.mask = maskLayer;
            }
        }
    }
}

- (void)qmuisb_fixSearchResultsScrollViewContentInsetIfNeeded {
    if (!self.qmuisb_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    if (self.qmui_isActive) {
        UIViewController *searchResultsController = self.qmui_searchController.searchResultsController;
        if (searchResultsController && [searchResultsController isViewLoaded]) {
            UIView *view = searchResultsController.view;
            UIScrollView *scrollView =
            [view isKindOfClass:UIScrollView.class] ? view :
            [view.subviews.firstObject isKindOfClass:UIScrollView.class] ? view.subviews.firstObject : nil;
            UIView *searchBarContainerView = self.superview;
            if (scrollView && searchBarContainerView) {
                scrollView.contentInset = UIEdgeInsetsMake(searchBarContainerView.qmui_height, 0, 0, 0);
            }
        }
    }
}

static CGSize textFieldDefaultSize;
+ (CGSize)qmuisb_textFieldDefaultSize {
    if (CGSizeIsEmpty(textFieldDefaultSize)) {
        textFieldDefaultSize = CGSizeMake(60, 28);
        // 在 iOS 11 及以上，搜索输入框系统默认高度是 36，iOS 10 及以下的高度是 28
        if (@available(iOS 11.0, *)) {
            textFieldDefaultSize.height = 36;
        }
    }
    return textFieldDefaultSize;
}

// 系统 textField 默认就带有左右间距，也即当 qmui_textFieldMargins 为 0 时输入框与左右的间距，实际计算时要自己叠加上 safeAreaInsets 的值
static UIEdgeInsets textFieldDefaultMargins;
+ (UIEdgeInsets)qmuisb_textFieldDefaultMargins {
    if (UIEdgeInsetsEqualToEdgeInsets(textFieldDefaultMargins, UIEdgeInsetsZero)) {
        textFieldDefaultMargins = UIEdgeInsetsMake(10, 8, 10, 8);
    }
    return textFieldDefaultMargins;
}

static CGFloat seachBarDefaultActiveHeight;
+ (CGFloat)qmuisb_seachBarDefaultActiveHeight {
    if (!seachBarDefaultActiveHeight) {
        seachBarDefaultActiveHeight = IS_NOTCHED_SCREEN ? 55 : 50;
    }
    return seachBarDefaultActiveHeight;
}

@end
