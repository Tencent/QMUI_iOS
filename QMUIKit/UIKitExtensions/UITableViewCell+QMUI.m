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
                
                [selfObject qmuiTbc_callAddToTableViewBlockIfCan];
                
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
    } else {
        self.qmuiTbc_separatorLayer.hidden = YES;
        self.qmuiTbc_topSeparatorLayer.hidden = YES;
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
        if (!self.selectedBackgroundView || [NSStringFromClass(self.selectedBackgroundView.class) hasPrefix:@"UITableViewCell"]) {
            self.selectedBackgroundView = [[UIView alloc] init];
        }
        self.selectedBackgroundView.backgroundColor = qmui_selectedBackgroundColor;
    }
}

- (UIColor *)qmui_selectedBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor);
}

- (UIView *)qmui_accessoryView {
    // 优先获取当前肉眼可见的 view，包括系统的排序、删除、checkbox 等，仅在 willDisplayCell 内有效，cellForRow 太早了拿不到
    BeginIgnorePerformSelectorLeaksWarning
    SEL managerSEL = NSSelectorFromString(@"_accessoryManager");
    if ([self respondsToSelector:managerSEL]) {
        id manager = [self performSelector:managerSEL];
        NSDictionary *accessoryViews = [manager performSelector:NSSelectorFromString(@"accessoryViews")];
        UIView *view = accessoryViews.allValues.firstObject;
        if (view) {
            return view;
        }
    }
    EndIgnorePerformSelectorLeaksWarning
    
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

static char kAssociatedObjectKey_configureReorderingStyleBlock;
- (void)setQmui_configureReorderingStyleBlock:(void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull, BOOL))configureReorderingStyleBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_configureReorderingStyleBlock, configureReorderingStyleBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (configureReorderingStyleBlock) {
        
        static NSString *kCellKey = @"QMUI_configureCell";
        
        [QMUIHelper executeBlock:^{
            // - [UITableViewCell _setReordering:]
            // - (void) _setReordering:(BOOL)arg1; (0x1177b462a)
            OverrideImplementation([UITableViewCell class], NSSelectorFromString([NSString qmui_stringByConcat:@"_", @"set", @"Reordering", @":", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITableViewCell *selfObject, BOOL firstArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    if (selfObject.qmui_configureReorderingStyleBlock) {
                        selfObject.qmui_configureReorderingStyleBlock(selfObject.qmui_tableView, selfObject, firstArgv);
                    }
                };
            });
            
            // - [UITableViewCell _shouldMaskToBoundsWhileAnimating]
            OverrideImplementation([UITableViewCell class], NSSelectorFromString([NSString qmui_stringByConcat:@"_", @"should", @"MaskToBounds", @"WhileAnimating", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UITableViewCell *selfObject) {
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD);
                    
                    // 系统默认在做 move 动作时 cell 是 clip 的，会导致 cell.layer.shadow 不可用，所以强制取消 clip
                    if (selfObject.qmui_configureReorderingStyleBlock) {
                        return NO;
                    }
                    
                    return result;
                };
            });
            
            Class constants = NSClassFromString([NSString qmui_stringByConcat:@"UITable", @"Constants", @"_", @"IOS"]);
            if (@available(iOS 14.0, *)) {
                
                // - [UITableViewCell _setConstants:]
                // - (void) _setConstants:(id)arg1; (0x10c36d360)
                OverrideImplementation([UITableViewCell class], NSSelectorFromString([NSString qmui_stringByConcat:@"_", @"set", @"Constants", @":", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UITableViewCell *selfObject, NSObject *firstArgv) {
                        
                        [firstArgv qmui_bindObjectWeakly:selfObject forKey:kCellKey];
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, NSObject *);
                        originSelectorIMP = (void (*)(id, SEL, NSObject *))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, firstArgv);
                    };
                });
                
                // - [UITableConstants_IOS defaultAlphaForReorderingCell]
                OverrideImplementation(constants, NSSelectorFromString([NSString qmui_stringByConcat:@"default", @"Alpha", @"ForReorderingCell", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^CGFloat(NSObject *selfObject) {
                        // call super
                        CGFloat (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (CGFloat (*)(id, SEL))originalIMPProvider();
                        CGFloat result = originSelectorIMP(selfObject, originCMD);
                        
                        UITableViewCell *cell = [selfObject qmui_getBoundObjectForKey:kCellKey];
                        if (cell.qmui_configureReorderingStyleBlock) {
                            return 1;
                        }
                        return result;
                    };
                });
                
                // - (BOOL) reorderingCellWantsShadows; (0x109f44dbc)
                OverrideImplementation(constants, NSSelectorFromString([NSString qmui_stringByConcat:@"reordering", @"Cell", @"WantsShadows", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^BOOL(NSObject *selfObject) {
                        // call super
                        BOOL (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                        BOOL result = originSelectorIMP(selfObject, originCMD);
                        
                        UITableViewCell *cell = [selfObject qmui_getBoundObjectForKey:kCellKey];
                        if (cell.qmui_configureReorderingStyleBlock) {
                            return NO;
                        }
                        return result;
                    };
                });
                
            } else {
                
                // - (double) defaultAlphaForReorderingCell:(id)arg1 inTableView:(id)arg2; (0x1174286d7)
                OverrideImplementation(constants, NSSelectorFromString([NSString qmui_stringByConcat:@"default", @"Alpha", @"ForReorderingCell:", @"inTableView:", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^CGFloat(NSObject *selfObject, UITableViewCell *cell, UITableView *tableView) {
                        
                        // call super
                        CGFloat (*originSelectorIMP)(id, SEL, UITableViewCell *, UITableView *);
                        originSelectorIMP = (CGFloat (*)(id, SEL, UITableViewCell *, UITableView *))originalIMPProvider();
                        CGFloat result = originSelectorIMP(selfObject, originCMD, cell, tableView);
                        
                        if (cell.qmui_configureReorderingStyleBlock) {
                            return 1;
                        }
                        
                        return result;
                    };
                });
                
                // - (BOOL) reorderingCellWantsShadows:(id)arg1 inTableView:(id)arg2; (0x1155d86e5)
                OverrideImplementation(constants, NSSelectorFromString([NSString qmui_stringByConcat:@"reordering", @"Cell", @"WantsShadows:", @"inTableView:", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^BOOL(NSObject *selfObject, UITableViewCell *cell, UITableView *tableView) {
                        
                        // call super
                        BOOL (*originSelectorIMP)(id, SEL, UITableViewCell *, UITableView *);
                        originSelectorIMP = (BOOL (*)(id, SEL, UITableViewCell *, UITableView *))originalIMPProvider();
                        BOOL result = originSelectorIMP(selfObject, originCMD, cell, tableView);
                        
                        if (cell.qmui_configureReorderingStyleBlock) {
                            return NO;
                        }
                        
                        return result;
                    };
                });
            }
            
            
        } oncePerIdentifier:@"QMUI_configureReordering"];
    }
}

- (void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull, BOOL))qmui_configureReorderingStyleBlock {
    return (void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull, BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_configureReorderingStyleBlock);
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
    return PreferredValueForTableViewStyle(self.qmui_tableView.style, TableViewCellTitleLabelColor, TableViewGroupedCellTitleLabelColor, TableViewInsetGroupedCellTitleLabelColor);
}

- (UIColor *)qmui_styledDetailTextLabelColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.style, TableViewCellDetailLabelColor, TableViewGroupedCellDetailLabelColor, TableViewInsetGroupedCellDetailLabelColor);
}

- (UIColor *)qmui_styledBackgroundColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.style, TableViewCellBackgroundColor, TableViewGroupedCellBackgroundColor, TableViewInsetGroupedCellBackgroundColor);
}

- (UIColor *)qmui_styledSelectedBackgroundColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.style, TableViewCellSelectedBackgroundColor, TableViewGroupedCellSelectedBackgroundColor, TableViewInsetGroupedCellSelectedBackgroundColor);
}

- (UIColor *)qmui_styledWarningBackgroundColor {
    return PreferredValueForTableViewStyle(self.qmui_tableView.style, TableViewCellWarningBackgroundColor, TableViewGroupedCellWarningBackgroundColor, TableViewInsetGroupedCellWarningBackgroundColor);
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
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (CGRect (*)(id, SEL))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
    });
}

@end
