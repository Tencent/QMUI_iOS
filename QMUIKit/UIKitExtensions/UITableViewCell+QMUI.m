/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITableViewCell+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/5.
//

#import "UITableViewCell+QMUI.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"
#import "UITableView+QMUI.h"
#import "CALayer+QMUI.h"

const UIEdgeInsets QMUITableViewCellSeparatorInsetsNone = {INFINITY, INFINITY, INFINITY, INFINITY};

@interface UITableViewCell ()

@property(nonatomic, copy) NSString *qmuiTbc_cachedAddToTableViewBlockKey;
@property(nonatomic, strong) CALayer *qmuiTbc_separatorLayer;
@property(nonatomic, strong) CALayer *qmuiTbc_topSeparatorLayer;
@end

@implementation UITableViewCell (QMUI)

QMUISynthesizeNSIntegerProperty(qmui_style, setQmui_style)
QMUISynthesizeIdCopyProperty(qmuiTbc_cachedAddToTableViewBlockKey, setQmuiTbc_cachedAddToTableViewBlockKey)
QMUISynthesizeIdCopyProperty(qmui_configureStyleBlock, setQmui_configureStyleBlock)
QMUISynthesizeIdStrongProperty(qmuiTbc_separatorLayer, setQmuiTbc_separatorLayer)
QMUISynthesizeIdStrongProperty(qmuiTbc_topSeparatorLayer, setQmuiTbc_topSeparatorLayer)
QMUISynthesizeIdCopyProperty(qmui_separatorInsetsBlock, setQmui_separatorInsetsBlock)
QMUISynthesizeIdCopyProperty(qmui_topSeparatorInsetsBlock, setQmui_topSeparatorInsetsBlock)
QMUISynthesizeIdCopyProperty(qmui_setHighlightedBlock, setQmui_setHighlightedBlock)
QMUISynthesizeIdCopyProperty(qmui_setSelectedBlock, setQmui_setSelectedBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UITableViewCell class], @selector(initWithStyle:reuseIdentifier:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UITableViewCell *(UITableViewCell *selfObject, UITableViewCellStyle firstArgv, NSString *secondArgv) {
                // call super
                UITableViewCell *(*originSelectorIMP)(id, SEL, UITableViewCellStyle, NSString *);
                originSelectorIMP = (UITableViewCell *(*)(id, SEL, UITableViewCellStyle, NSString *))originalIMPProvider();
                UITableViewCell *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                
                // 系统虽然有私有 API - (UITableViewCellStyle)style; 可以用，但该方法在 init 内得到的永远是 0，只有 init 执行完成后才可以得到正确的值，所以这里只能自己记录
                result.qmui_style = firstArgv;
                
                if (@available(iOS 13.0, *)) {
                    [selfObject qmuiTbc_callAddToTableViewBlockIfCan];
                }
                
                return result;
            };
        });
        ExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setHighlighted:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL highlighted, BOOL animated) {
            if (selfObject.qmui_setHighlightedBlock) {
                selfObject.qmui_setHighlightedBlock(highlighted, animated);
            }
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setSelected:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL selected, BOOL animated) {
            if (selfObject.qmui_setSelectedBlock) {
                selfObject.qmui_setSelectedBlock(selected, animated);
            }
        });
        
        // 修复 iOS 13.0 UIButton 作为 cell.accessoryView 时布局错误的问题
        // https://github.com/Tencent/QMUI_iOS/issues/693
        if (@available(iOS 13.0, *)) {
            if (@available(iOS 13.1, *)) {
            } else {
                ExtendImplementationOfVoidMethodWithoutArguments([UITableViewCell class], @selector(layoutSubviews), ^(UITableViewCell *selfObject) {
                    if ([selfObject.accessoryView isKindOfClass:[UIButton class]]) {
                        CGFloat defaultRightMargin = 15 + SafeAreaInsetsConstantForDeviceWithNotch.right;
                        selfObject.accessoryView.qmui_left = selfObject.qmui_width - defaultRightMargin - selfObject.accessoryView.qmui_width;
                        selfObject.accessoryView.qmui_top = CGRectGetMinYVerticallyCenterInParentRect(selfObject.frame, selfObject.accessoryView.frame);;
                        selfObject.contentView.qmui_right = selfObject.accessoryView.qmui_left;
                    }
                });
            }
        }
        
        OverrideImplementation([UITableViewCell class], NSSelectorFromString(@"_setTableView:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableViewCell *selfObject, UITableView *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UITableView *);
                originSelectorIMP = (void (*)(id, SEL, UITableView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                [selfObject qmuiTbc_callAddToTableViewBlockIfCan];
            };
        });
    });
}

static char kAssociatedObjectKey_cellPosition;
- (void)setQmui_cellPosition:(QMUITableViewCellPosition)qmui_cellPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cellPosition, @(qmui_cellPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    BOOL shouldShowSeparatorInTableView = self.qmui_tableView && self.qmui_tableView.separatorStyle != UITableViewCellSeparatorStyleNone;
    if (shouldShowSeparatorInTableView) {
        [self qmuiTbc_createSeparatorLayerIfNeeded];
        [self qmuiTbc_createTopSeparatorLayerIfNeeded];
    }
}

- (QMUITableViewCellPosition)qmui_cellPosition {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cellPosition)) integerValue];
}

static char kAssociatedObjectKey_didAddToTableViewBlock;
- (void)setQmui_didAddToTableViewBlock:(void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull))qmui_didAddToTableViewBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_didAddToTableViewBlock, qmui_didAddToTableViewBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self qmuiTbc_callAddToTableViewBlockIfCan];
}

- (void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull))qmui_didAddToTableViewBlock {
    return (void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_didAddToTableViewBlock);
}

- (void)qmuiTbc_callAddToTableViewBlockIfCan {
    if (!self.qmui_tableView || !self.qmui_didAddToTableViewBlock) return;
    NSString *key = [NSString stringWithFormat:@"%p%p", self.qmui_tableView, self.qmui_didAddToTableViewBlock];
    if ([key isEqualToString:self.qmuiTbc_cachedAddToTableViewBlockKey]) return;
    self.qmui_didAddToTableViewBlock(self.qmui_tableView, self);
    self.qmuiTbc_cachedAddToTableViewBlockKey = key;
}

- (void)qmuiTbc_swizzleLayoutSubviews {
    [QMUIHelper executeBlock:^{
        ExtendImplementationOfVoidMethodWithoutArguments(self.class, @selector(layoutSubviews), ^(UITableViewCell *cell) {
            if (cell.qmuiTbc_separatorLayer && !cell.qmuiTbc_separatorLayer.hidden) {
                UIEdgeInsets insets = cell.qmui_separatorInsetsBlock(cell.qmui_tableView, cell);
                CGRect frame = CGRectZero;
                if (!UIEdgeInsetsEqualToEdgeInsets(insets, QMUITableViewCellSeparatorInsetsNone)) {
                    CGFloat height = PixelOne;
                    frame = CGRectMake(insets.left, CGRectGetHeight(cell.bounds) - height + insets.top - insets.bottom, MAX(0, CGRectGetWidth(cell.bounds) - UIEdgeInsetsGetHorizontalValue(insets)), height);
                }
                cell.qmuiTbc_separatorLayer.frame = frame;
            }
            
            if (cell.qmuiTbc_topSeparatorLayer && !cell.qmuiTbc_topSeparatorLayer.hidden) {
                UIEdgeInsets insets = cell.qmui_topSeparatorInsetsBlock(cell.qmui_tableView, cell);
                CGRect frame = CGRectZero;
                if (!UIEdgeInsetsEqualToEdgeInsets(insets, QMUITableViewCellSeparatorInsetsNone)) {
                    CGFloat height = PixelOne;
                    frame = CGRectMake(insets.left, insets.top - insets.bottom, MAX(0, CGRectGetWidth(cell.bounds) - UIEdgeInsetsGetHorizontalValue(insets)), height);
                }
                cell.qmuiTbc_topSeparatorLayer.frame = frame;
            }
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UITableViewCell %@-%@", NSStringFromClass(self.class), NSStringFromSelector(@selector(layoutSubviews))]];
}

- (BOOL)qmuiTbc_customizedSeparator {
    return !!self.qmui_separatorInsetsBlock;
}

- (BOOL)qmuiTbc_customizedTopSeparator {
    return !!self.qmui_topSeparatorInsetsBlock;
}

- (void)qmuiTbc_createSeparatorLayerIfNeeded {
    if (![self qmuiTbc_customizedSeparator]) {
        self.qmuiTbc_separatorLayer.hidden = YES;
        return;
    }
    
    BOOL shouldShowSeparator = !UIEdgeInsetsEqualToEdgeInsets(self.qmui_separatorInsetsBlock(self.qmui_tableView, self), QMUITableViewCellSeparatorInsetsNone);
    if (shouldShowSeparator) {
        if (!self.qmuiTbc_separatorLayer) {
            [self qmuiTbc_swizzleLayoutSubviews];
            self.qmuiTbc_separatorLayer = [CALayer layer];
            [self.qmuiTbc_separatorLayer qmui_removeDefaultAnimations];
            [self.layer addSublayer:self.qmuiTbc_separatorLayer];
        }
        self.qmuiTbc_separatorLayer.backgroundColor = self.qmui_tableView.separatorColor.CGColor;
        self.qmuiTbc_separatorLayer.hidden = NO;
    } else {
        if (self.qmuiTbc_separatorLayer) {
            self.qmuiTbc_separatorLayer.hidden = YES;
        }
    }
}

- (void)qmuiTbc_createTopSeparatorLayerIfNeeded {
    if (![self qmuiTbc_customizedTopSeparator]) {
        self.qmuiTbc_topSeparatorLayer.hidden = YES;
        return;
    }
    
    BOOL shouldShowSeparator = !UIEdgeInsetsEqualToEdgeInsets(self.qmui_topSeparatorInsetsBlock(self.qmui_tableView, self), QMUITableViewCellSeparatorInsetsNone);
    if (shouldShowSeparator) {
        if (!self.qmuiTbc_topSeparatorLayer) {
            [self qmuiTbc_swizzleLayoutSubviews];
            self.qmuiTbc_topSeparatorLayer = [CALayer layer];
            [self.qmuiTbc_topSeparatorLayer qmui_removeDefaultAnimations];
            [self.layer addSublayer:self.qmuiTbc_topSeparatorLayer];
        }
        self.qmuiTbc_topSeparatorLayer.backgroundColor = self.qmui_tableView.separatorColor.CGColor;
        self.qmuiTbc_topSeparatorLayer.hidden = NO;
    } else {
        if (self.qmuiTbc_topSeparatorLayer) {
            self.qmuiTbc_topSeparatorLayer.hidden = YES;
        }
    }
}

- (UITableView *)qmui_tableView {
    return [self valueForKey:@"_tableView"];
}

static char kAssociatedObjectKey_selectedBackgroundColor;
- (void)setQmui_selectedBackgroundColor:(UIColor *)qmui_selectedBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor, qmui_selectedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_selectedBackgroundColor) {
        // 系统默认的 selectedBackgroundView 是 UITableViewCellSelectedBackground，无法修改自定义背景色，所以改为用普通的 UIView
        if ([NSStringFromClass(self.selectedBackgroundView.class) hasPrefix:@"UITableViewCell"]) {
            self.selectedBackgroundView = [[UIView alloc] init];
        }
        self.selectedBackgroundView.backgroundColor = qmui_selectedBackgroundColor;
    }
}

- (UIColor *)qmui_selectedBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor);
}

- (UIView *)qmui_accessoryView {
    if (self.editing) {
        if (self.editingAccessoryView) {
            return self.editingAccessoryView;
        }
        return [self qmui_valueForKey:@"_editingAccessoryView"];
    }
    if (self.accessoryView) {
        return self.accessoryView;
    }
    
    // UITableViewCellAccessoryDetailDisclosureButton 在 iOS 13 及以上是分开的两个 accessoryView，以 NSSet 的形式存在这个私有接口里。而 iOS 12 及以下是以一个 UITableViewCellDetailDisclosureView 的 UIControl 存在。
    if (@available(iOS 13.0, *)) {
        NSSet<UIView *> *accessoryViews = [self qmui_valueForKey:@"_existingSystemAccessoryViews"];
        if ([accessoryViews isKindOfClass:NSSet.class] && accessoryViews.count) {
            UIView *leftView = nil;
            for (UIView *accessoryView in accessoryViews) {
                if (!leftView) {
                    leftView = accessoryView;
                    continue;
                }
                if (CGRectGetMinX(accessoryView.frame) < CGRectGetMinX(leftView.frame)) {
                    leftView = accessoryView;
                }
            }
            return leftView;
        }
        return nil;
    }
    return [self qmui_valueForKey:@"_accessoryView"];
}

@end

@implementation UITableViewCell (QMUI_Styled)

- (void)qmui_styledAsQMUITableViewCell {
    if (!QMUICMIActivated) return;
    
    self.textLabel.font = UIFontMake(16);
    self.textLabel.backgroundColor = UIColorClear;
    UIColor *textLabelColor = self.qmui_styledTextLabelColor;
    if (textLabelColor) {
        self.textLabel.textColor = textLabelColor;
    }
    
    self.detailTextLabel.font = UIFontMake(15);
    self.detailTextLabel.backgroundColor = UIColorClear;
    UIColor *detailLabelColor = self.qmui_styledDetailTextLabelColor;
    if (detailLabelColor) {
        self.detailTextLabel.textColor = detailLabelColor;
    }
    
    UIColor *backgroundColor = self.qmui_styledBackgroundColor;
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    
    UIColor *selectedBackgroundColor = self.qmui_styledSelectedBackgroundColor;
    if (selectedBackgroundColor) {
        self.qmui_selectedBackgroundColor = selectedBackgroundColor;
    }
}

- (UIColor *)qmui_styledTextLabelColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.qmui_style, TableViewCellTitleLabelColor, TableViewGroupedCellTitleLabelColor, TableViewInsetGroupedCellTitleLabelColor);
}

- (UIColor *)qmui_styledDetailTextLabelColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.qmui_style, TableViewCellDetailLabelColor, TableViewGroupedCellDetailLabelColor, TableViewInsetGroupedCellDetailLabelColor);
}

- (UIColor *)qmui_styledBackgroundColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.qmui_style, TableViewCellBackgroundColor, TableViewGroupedCellBackgroundColor, TableViewInsetGroupedCellBackgroundColor);
}

- (UIColor *)qmui_styledSelectedBackgroundColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.qmui_style, TableViewCellSelectedBackgroundColor, TableViewGroupedCellSelectedBackgroundColor, TableViewInsetGroupedCellSelectedBackgroundColor);
}

- (UIColor *)qmui_styledWarningBackgroundColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.qmui_style, TableViewCellWarningBackgroundColor, TableViewGroupedCellWarningBackgroundColor, TableViewInsetGroupedCellWarningBackgroundColor);
}

@end

@implementation UITableViewCell (QMUI_InsetGrouped)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UITableViewCell class], NSSelectorFromString(@"_separatorFrame"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UITableViewCell *selfObject) {
                
                if ([selfObject qmuiTbc_customizedSeparator]) {
                    return CGRectZero;
                }
                
                // iOS 13 自己会控制好 InsetGrouped 时不同 cellPosition 的分隔线显隐，iOS 12 及以下要全部手动处理
                if (@available(iOS 13.0, *)) {
                } else {
                    if (selfObject.qmui_tableView && selfObject.qmui_tableView.qmui_style == QMUITableViewStyleInsetGrouped && (selfObject.qmui_cellPosition & QMUITableViewCellPositionLastInSection) == QMUITableViewCellPositionLastInSection) {
                        return CGRectZero;
                    }
                }
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (CGRect (*)(id, SEL))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
        
        OverrideImplementation([UITableViewCell class], NSSelectorFromString(@"_topSeparatorFrame"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UITableViewCell *selfObject) {
                
                if ([selfObject qmuiTbc_customizedTopSeparator]) {
                    return CGRectZero;
                }
                
                if (@available(iOS 13.0, *)) {
                } else {
                    // iOS 13 系统在 InsetGrouped 时默认就会隐藏顶部分隔线，所以这里只对 iOS 12 及以下处理
                    if (selfObject.qmui_tableView && selfObject.qmui_tableView.qmui_style == QMUITableViewStyleInsetGrouped) {
                        return CGRectZero;
                    }
                }
                
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (CGRect (*)(id, SEL))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
        
        // 下方的功能，iOS 13 都交给系统的 InsetGrouped 处理
        if (@available(iOS 13.0, *)) return;
        
        OverrideImplementation([UITableViewCell class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableViewCell *selfObject, CGRect firstArgv) {
                
                UITableView *tableView = selfObject.qmui_tableView;
                if (tableView && tableView.qmui_style == QMUITableViewStyleInsetGrouped) {
                    // 以下的宽度不基于 firstArgv 来改，而是直接获取 tableView 的内容宽度，是因为 iOS 12 及以下的系统，在 cell 拖拽排序时，frame 会基于上一个 frame 计算，导致宽度不断减小，所以这里每次都用 tableView 的内容宽度来算
                    // https://github.com/Tencent/QMUI_iOS/issues/1216
                    firstArgv = CGRectMake(tableView.safeAreaInsets.left + tableView.qmui_insetGroupedHorizontalInset, CGRectGetMinY(firstArgv), tableView.qmui_validContentWidth, CGRectGetHeight(firstArgv));
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        // 将缩进后的宽度传给 cell 的 sizeThatFits:，注意 sizeThatFits: 只有在 tableView 开启 self-sizing 的情况下才会被调用（也即高度被指定为 UITableViewAutomaticDimension）
        // TODO: molice 系统的 UITableViewCell 第一次布局总是得到错误的高度，不知道为什么
        OverrideImplementation([UITableViewCell class], @selector(systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGSize(UITableViewCell *selfObject, CGSize targetSize, UILayoutPriority horizontalFittingPriority, UILayoutPriority verticalFittingPriority) {
                
                UITableView *tableView = selfObject.qmui_tableView;
                if (tableView && tableView.qmui_style == QMUITableViewStyleInsetGrouped) {
                    [QMUIHelper executeBlock:^{
                        OverrideImplementation(selfObject.class, @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL cellOriginCMD, IMP (^cellOriginalIMPProvider)(void)) {
                            return ^CGSize(UITableViewCell *cell, CGSize firstArgv) {
                                
                                UITableView *tableView = cell.qmui_tableView;
                                if (tableView && tableView.qmui_style == QMUITableViewStyleInsetGrouped) {
                                    firstArgv.width = firstArgv.width - UIEdgeInsetsGetHorizontalValue(tableView.safeAreaInsets) - tableView.qmui_insetGroupedHorizontalInset * 2;
                                }
                                
                                // call super
                                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))cellOriginalIMPProvider();
                                CGSize result = originSelectorIMP(cell, cellOriginCMD, firstArgv);
                                return result;
                            };
                        });
                    } oncePerIdentifier:[NSString stringWithFormat:@"InsetGroupedCell %@-%@", NSStringFromClass(selfObject.class), NSStringFromSelector(@selector(sizeThatFits:))]];
                }
                
                // call super
                CGSize (*originSelectorIMP)(id, SEL, CGSize, UILayoutPriority, UILayoutPriority);
                originSelectorIMP = (CGSize (*)(id, SEL, CGSize, UILayoutPriority, UILayoutPriority))originalIMPProvider();
                CGSize result = originSelectorIMP(selfObject, originCMD, targetSize, horizontalFittingPriority, verticalFittingPriority);
                return result;
            };
        });
    });
}

@end
