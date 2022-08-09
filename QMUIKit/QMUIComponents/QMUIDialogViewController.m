/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIDialogViewController.m
//  WeRead
//
//  Created by QMUI Team on 16/7/8.
//

#import "QMUIDialogViewController.h"
#import "QMUICore.h"
#import "QMUIButton.h"
#import "QMUILabel.h"
#import "QMUITextField.h"
#import "QMUITableViewCell.h"
#import "QMUINavigationTitleView.h"
#import "CALayer+QMUI.h"
#import "UITableView+QMUI.h"
#import "NSString+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "QMUIAppearance.h"

@implementation QMUIDialogViewController (UIAppearance)

+ (instancetype)appearance {
    return [QMUIAppearance appearanceForClass:self];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        QMUIDialogViewController *dialogViewControllerAppearance = QMUIDialogViewController.appearance;
        dialogViewControllerAppearance.cornerRadius = 6;
        dialogViewControllerAppearance.dialogViewMargins = UIEdgeInsetsMake(20, 20, 20, 20); // 在 -didInitialize 里会适配 iPhone X 的 safeAreaInsets
        dialogViewControllerAppearance.maximumContentViewWidth = [QMUIHelper screenSizeFor55Inch].width - UIEdgeInsetsGetHorizontalValue(dialogViewControllerAppearance.dialogViewMargins);
        dialogViewControllerAppearance.backgroundColor = UIColorWhite;
        dialogViewControllerAppearance.titleTintColor = nil;
        dialogViewControllerAppearance.titleLabelFont = UIFontMake(16);
        dialogViewControllerAppearance.titleLabelTextColor = UIColorMake(53, 60, 70);
        dialogViewControllerAppearance.subTitleLabelFont = UIFontMake(12);
        dialogViewControllerAppearance.subTitleLabelTextColor = UIColorMake(133, 140, 150);
        
        dialogViewControllerAppearance.headerSeparatorColor = UIColorMake(222, 224, 226);
        dialogViewControllerAppearance.headerViewHeight = 48;
        dialogViewControllerAppearance.headerViewBackgroundColor = UIColorMake(244, 245, 247);
        dialogViewControllerAppearance.contentViewMargins = UIEdgeInsetsZero;
        dialogViewControllerAppearance.contentViewBackgroundColor = nil;
        dialogViewControllerAppearance.footerSeparatorColor = UIColorMake(222, 224, 226);
        dialogViewControllerAppearance.footerViewHeight = 48;
        dialogViewControllerAppearance.footerViewBackgroundColor = nil;
        
        dialogViewControllerAppearance.buttonBackgroundColor = nil;
        dialogViewControllerAppearance.buttonTitleAttributes = @{NSForegroundColorAttributeName: UIColorBlue};
        dialogViewControllerAppearance.buttonHighlightedBackgroundColor = [UIColorBlue colorWithAlphaComponent:.25];
    });
}

@end

@interface QMUIDialogViewController ()

@property(nonatomic, assign) BOOL hasCustomContentView;
@property(nonatomic,copy) void (^cancelButtonBlock)(QMUIDialogViewController *dialogViewController);
@property(nonatomic,copy) void (^submitButtonBlock)(QMUIDialogViewController *dialogViewController);
@end

@implementation QMUIDialogViewController

- (void)didInitialize {
    [super didInitialize];
    
    [self qmui_applyAppearance];
    
    _contentView = [[UIView alloc] init]; // 特地不使用setter，从而不要影响self.hasCustomContentView的默认值
    self.contentView.backgroundColor = self.contentViewBackgroundColor;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.headerViewHeight)];
    self.headerView.backgroundColor = self.headerViewBackgroundColor;
    
    // 使用自带的QMUINavigationTitleView，支持loading、subTitle
    [self.headerView addSubview:self.titleView];
    
    // 加上分隔线
    _headerViewSeparatorLayer = [CALayer layer];
    [self.headerViewSeparatorLayer qmui_removeDefaultAnimations];
    self.headerViewSeparatorLayer.backgroundColor = self.headerSeparatorColor.CGColor;
    [self.headerView.layer addSublayer:self.headerViewSeparatorLayer];
    
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.footerViewHeight)];
    self.footerView.backgroundColor = self.footerViewBackgroundColor;
    self.footerView.hidden = YES;
    
    _footerViewSeparatorLayer = [CALayer layer];
    [self.footerViewSeparatorLayer qmui_removeDefaultAnimations];
    self.footerViewSeparatorLayer.backgroundColor = self.footerSeparatorColor.CGColor;
    [self.footerView.layer addSublayer:self.footerViewSeparatorLayer];
    
    _buttonSeparatorLayer = [CALayer layer];
    [self.buttonSeparatorLayer qmui_removeDefaultAnimations];
    self.buttonSeparatorLayer.backgroundColor = self.footerViewSeparatorLayer.backgroundColor;
    self.buttonSeparatorLayer.hidden = YES;
    [self.footerView.layer addSublayer:self.buttonSeparatorLayer];
    
    self.modalPresentationViewController = [[QMUIModalPresentationViewController alloc] init];
    self.modalPresentationViewController.modal = YES;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    if ([self isViewLoaded]) {
        self.view.layer.cornerRadius = cornerRadius;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ([self isViewLoaded]) {
        self.view.backgroundColor = backgroundColor;
    }
}

- (void)setTitleTintColor:(UIColor *)titleTintColor {
    _titleTintColor = titleTintColor;
    [self updateTitleViewColor];
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    self.titleView.titleLabel.font = titleLabelFont;
    self.titleView.verticalTitleFont = titleLabelFont;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor {
    _titleLabelTextColor = titleLabelTextColor;
    [self updateTitleViewColor];
}

- (void)setSubTitleLabelFont:(UIFont *)subTitleLabelFont {
    _subTitleLabelFont = subTitleLabelFont;
    self.titleView.subtitleLabel.font = subTitleLabelFont;
    self.titleView.verticalSubtitleFont = subTitleLabelFont;
}

- (void)setSubTitleLabelTextColor:(UIColor *)subTitleLabelTextColor {
    _subTitleLabelTextColor = subTitleLabelTextColor;
    [self updateTitleViewColor];
}

- (void)updateTitleViewColor {
    self.titleView.adjustsSubviewsTintColorAutomatically = !self.titleLabelTextColor && !self.subTitleLabelTextColor;
    if (self.titleView.adjustsSubviewsTintColorAutomatically) {
        self.titleView.tintColor = self.titleTintColor;// call tintColorDidChange
    } else {
        self.titleView.titleLabel.textColor = self.titleLabelTextColor ?: (self.titleTintColor ?: self.titleView.tintColor);
        self.titleView.subtitleLabel.textColor = self.subTitleLabelTextColor ?: (self.titleTintColor ?: self.titleView.tintColor);
    }
}

- (void)setHeaderSeparatorColor:(UIColor *)headerSeparatorColor {
    _headerSeparatorColor = headerSeparatorColor;
    self.headerViewSeparatorLayer.backgroundColor = headerSeparatorColor.CGColor;
}

- (void)setFooterSeparatorColor:(UIColor *)footerSeparatorColor {
    _footerSeparatorColor = footerSeparatorColor;
    self.footerViewSeparatorLayer.backgroundColor = footerSeparatorColor.CGColor;
    self.buttonSeparatorLayer.backgroundColor = footerSeparatorColor.CGColor;
}

- (void)setHeaderViewHeight:(CGFloat)headerViewHeight {
    _headerViewHeight = headerViewHeight;
    [self.modalPresentationViewController updateLayout];
}

- (void)setHeaderViewBackgroundColor:(UIColor *)headerViewBackgroundColor {
    _headerViewBackgroundColor = headerViewBackgroundColor;
    self.headerView.backgroundColor = headerViewBackgroundColor;
}

- (void)setContentViewMargins:(UIEdgeInsets)contentViewMargins {
    _contentViewMargins = contentViewMargins;
    [self.modalPresentationViewController updateLayout];
}

- (void)setContentViewBackgroundColor:(UIColor *)contentViewBackgroundColor {
    _contentViewBackgroundColor = contentViewBackgroundColor;
    if (!self.hasCustomContentView) {
        self.contentView.backgroundColor = contentViewBackgroundColor;
    }
}

- (void)setFooterViewHeight:(CGFloat)footerViewHeight {
    _footerViewHeight = footerViewHeight;
}

- (void)setFooterViewBackgroundColor:(UIColor *)footerViewBackgroundColor {
    _footerViewBackgroundColor = footerViewBackgroundColor;
    self.footerView.backgroundColor = footerViewBackgroundColor;
}

- (void)setButtonTitleAttributes:(NSDictionary<NSString *,id> *)buttonTitleAttributes {
    _buttonTitleAttributes = buttonTitleAttributes;
    if (self.cancelButton) {
        [self.cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithString:[self.cancelButton attributedTitleForState:UIControlStateNormal].string attributes:buttonTitleAttributes] forState:UIControlStateNormal];
    }
    if (self.submitButton) {
        [self.submitButton setAttributedTitle:[[NSAttributedString alloc] initWithString:[self.submitButton attributedTitleForState:UIControlStateNormal].string attributes:buttonTitleAttributes] forState:UIControlStateNormal];
    }
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor {
    _buttonBackgroundColor = buttonBackgroundColor;
    if (self.cancelButton) {
        self.cancelButton.backgroundColor = buttonBackgroundColor;
    }
    if (self.submitButton) {
        self.submitButton.backgroundColor = buttonBackgroundColor;
    }
}

- (void)setButtonHighlightedBackgroundColor:(UIColor *)buttonHighlightedBackgroundColor {
    _buttonHighlightedBackgroundColor = buttonHighlightedBackgroundColor;
    if (self.cancelButton) {
        self.cancelButton.highlightedBackgroundColor = buttonHighlightedBackgroundColor;
    }
    if (self.submitButton) {
        self.submitButton.highlightedBackgroundColor = buttonHighlightedBackgroundColor;
    }
}

BeginIgnoreClangWarning(-Wobjc-missing-super-calls)
- (void)setupNavigationItems {
    // 不继承父类的实现，从而避免把 self.titleView 放到 navigationItem 上
    //    [super setupNavigationItems];
}
EndIgnoreClangWarning

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subviews 的初始化都放到 didInitialize 里，以保证初始化完 dialog 就能被外界访问到。但真正加到 self.view 上还是等到 viewDidLoad 时
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.footerView];
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = self.backgroundColor;
    self.view.layer.cornerRadius = self.cornerRadius;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView != contentView) {
        [_contentView removeFromSuperview];
        _contentView = contentView;
        if ([self isViewLoaded]) {
            [self.view insertSubview:_contentView atIndex:0];
        }
        self.hasCustomContentView = YES;
    } else {
        self.hasCustomContentView = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    BOOL isFooterViewShowing = self.footerView && !self.footerView.hidden;
    
    self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.headerViewHeight);
    self.headerViewSeparatorLayer.frame = CGRectFlatMake(0, self.headerViewHeight, CGRectGetWidth(self.view.bounds), PixelOne);
    
    CGFloat headerViewPaddingHorizontal = 16;
    CGFloat headerViewContentWidth = CGRectGetWidth(self.headerView.bounds) - headerViewPaddingHorizontal * 2;
    CGSize titleViewSize = [self.titleView sizeThatFits:CGSizeMake(headerViewContentWidth, CGFLOAT_MAX)];
    CGFloat titleViewWidth = MIN(titleViewSize.width, headerViewContentWidth);
    self.titleView.frame = CGRectMake(CGFloatGetCenter(CGRectGetWidth(self.headerView.bounds), titleViewWidth), CGFloatGetCenter(CGRectGetHeight(self.headerView.bounds), titleViewSize.height), titleViewWidth, titleViewSize.height);
    
    if (isFooterViewShowing) {
        self.footerView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - self.footerViewHeight, CGRectGetWidth(self.view.bounds), self.footerViewHeight);
        self.footerViewSeparatorLayer.frame = CGRectMake(0, -PixelOne, CGRectGetWidth(self.footerView.bounds), PixelOne);
        
        NSUInteger buttonCount = self.footerView.subviews.count;
        if (buttonCount == 1) {
            QMUIButton *button = self.cancelButton ? : self.submitButton;
            button.frame = self.footerView.bounds;
            self.buttonSeparatorLayer.hidden = YES;
        } else {
            CGFloat buttonWidth = flat(CGRectGetWidth(self.footerView.bounds) / buttonCount);
            self.cancelButton.frame = CGRectMake(0, 0, buttonWidth, CGRectGetHeight(self.footerView.bounds));
            self.submitButton.frame = CGRectMake(CGRectGetMaxX(self.cancelButton.frame), 0, CGRectGetWidth(self.footerView.bounds) - CGRectGetMaxX(self.cancelButton.frame), CGRectGetHeight(self.footerView.bounds));
            self.buttonSeparatorLayer.hidden = NO;
            self.buttonSeparatorLayer.frame = CGRectMake(CGRectGetMaxX(self.cancelButton.frame), 0, PixelOne, CGRectGetHeight(self.footerView.bounds));
        }
    }
    
    CGFloat contentViewMinY = CGRectGetMaxY(self.headerView.frame) + self.contentViewMargins.top;
    CGFloat contentViewHeight = (isFooterViewShowing ? CGRectGetMinY(self.footerView.frame) - self.contentViewMargins.bottom : CGRectGetHeight(self.view.bounds)) - contentViewMinY;
    self.contentView.frame = CGRectMake(self.contentViewMargins.left, contentViewMinY, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentViewMargins), contentViewHeight);
}

- (void)addCancelButtonWithText:(NSString *)buttonText block:(void (^)(__kindof QMUIDialogViewController *))block {
    [self removeCancelButton];
    
    _cancelButton = [self generateButtonWithText:buttonText];
    [self.cancelButton addTarget:self action:@selector(handleCancelButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    self.footerView.hidden = NO;
    [self.footerView addSubview:self.cancelButton];
    
    self.cancelButtonBlock = block;
}

- (void)removeCancelButton {
    [_cancelButton removeFromSuperview];
    self.cancelButtonBlock = nil;
    _cancelButton = nil;
    if (!self.cancelButton && !self.submitButton) {
        self.footerView.hidden = YES;
    }
}

- (void)addSubmitButtonWithText:(NSString *)buttonText block:(void (^)(__kindof QMUIDialogViewController *dialogViewController))block {
    [self removeSubmitButton];
    
    _submitButton = [self generateButtonWithText:buttonText];
    [self.submitButton addTarget:self action:@selector(handleSubmitButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    self.footerView.hidden = NO;
    [self.footerView addSubview:self.submitButton];
    
    self.submitButtonBlock = block;
}

- (void)removeSubmitButton {
    [_submitButton removeFromSuperview];
    self.submitButtonBlock = nil;
    _submitButton = nil;
    if (!self.cancelButton && !self.submitButton) {
        self.footerView.hidden = YES;
    }
}

- (QMUIButton *)generateButtonWithText:(NSString *)buttonText {
    QMUIButton *button = [[QMUIButton alloc] init];
    button.titleLabel.font = UIFontBoldMake((IS_320WIDTH_SCREEN) ? 14 : 15);
    button.backgroundColor = self.buttonBackgroundColor;
    button.highlightedBackgroundColor = self.buttonHighlightedBackgroundColor;
    [button setAttributedTitle:[[NSAttributedString alloc] initWithString:buttonText attributes:self.buttonTitleAttributes] forState:UIControlStateNormal];
    return button;
}

- (void)handleCancelButtonEvent:(QMUIButton *)cancelButton {
    [self hideWithAnimated:YES completion:nil];
    if (self.cancelButtonBlock) {
        self.cancelButtonBlock(self);
    }
}

- (void)handleSubmitButtonEvent:(QMUIButton *)submitButton {
    if (self.submitButtonBlock) {
        // 把自己传过去，通过参数来引用 self，避免在 block 里直接引用 dialog 导致内存泄漏
        self.submitButtonBlock(self);
    }
}

- (void)show {
    [self showWithAnimated:YES completion:nil];
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.modalPresentationViewController.contentViewMargins = self.dialogViewMargins;
    self.modalPresentationViewController.maximumContentViewWidth = self.maximumContentViewWidth;
    self.modalPresentationViewController.contentViewController = self;
    [self.modalPresentationViewController showWithAnimated:YES completion:completion];
}

- (void)hide {
    [self hideWithAnimated:YES completion:nil];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self.modalPresentationViewController hideWithAnimated:animated completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        self.modalPresentationViewController.contentViewController = nil;
    }];
}

#pragma mark - <QMUIModalPresentationContentViewControllerProtocol>

- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller keyboardHeight:(CGFloat)keyboardHeight limitSize:(CGSize)limitSize {
    if (!self.hasCustomContentView) {
        return limitSize;
    }
    
    BOOL isFooterViewShowing = self.footerView && !self.footerView.hidden;
    CGFloat footerHeight = isFooterViewShowing ? self.footerViewHeight : 0;
    
    CGFloat contentViewVerticalMargin = UIEdgeInsetsGetVerticalValue(self.contentViewMargins);
    
    CGSize contentViewLimitSize = CGSizeMake(limitSize.width, limitSize.height - self.headerViewHeight - contentViewVerticalMargin - footerHeight);
    CGSize contentViewSize = [self.contentView sizeThatFits:contentViewLimitSize];
    
    CGSize finalSize = CGSizeMake(MIN(limitSize.width, contentViewSize.width), MIN(limitSize.height, self.headerViewHeight + contentViewSize.height + contentViewVerticalMargin + footerHeight));
    return finalSize;
}

#pragma mark - <QMUIModalPresentationComponentProtocol>

- (void)hideModalPresentationComponent {
    [self hideWithAnimated:NO completion:nil];
}

@end

@implementation QMUIDialogSelectionViewController (UIAppearance)

+ (instancetype)appearance {
    return [QMUIAppearance appearanceForClass:self];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        QMUIDialogSelectionViewController.appearance.rowHeight = TableViewCellNormalHeight;
    });
}

@end

const NSInteger QMUIDialogSelectionViewControllerSelectedItemIndexNone = -1;

@interface QMUIDialogSelectionViewController ()

@property(nonatomic,strong,readwrite) QMUITableView *tableView;
@end

@implementation QMUIDialogSelectionViewController

- (void)didInitialize {
    [super didInitialize];
    
    self.selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone;
    self.selectedItemIndexes = [[NSMutableSet alloc] init];
    
    self.tableView = [[QMUITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.alwaysBounceVertical = NO;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    // 因为要根据 tableView sizeThatFits: 算出 dialog 的高度，所以禁用 estimated 特性，不然算出来结果不准确
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.contentView = self.tableView;
    self.tableView.backgroundColor = self.contentViewBackgroundColor;// QMUIDialogSelectionViewController 使用了 customContentView，所以默认不会自动应用到 self.contentViewBackgroundColor，这里手动应用一次
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 当前的分组不在可视区域内，则滚动到可视区域（只对单选有效）
    if (self.selectedItemIndex != QMUIDialogSelectionViewControllerSelectedItemIndexNone && self.selectedItemIndex < self.items.count && ![self.tableView qmui_cellVisibleAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItemIndex inSection:0]]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItemIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
    }
}

- (void)setContentViewBackgroundColor:(UIColor *)contentViewBackgroundColor {
    [super setContentViewBackgroundColor:contentViewBackgroundColor];
    self.tableView.backgroundColor = contentViewBackgroundColor;
}

- (void)setItems:(NSArray<NSString *> *)items {
    _items = [items copy];
    [self.tableView reloadData];
    if (self.modalPresentationViewController.visible) {
        [self.modalPresentationViewController updateLayout];
    }
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    [self.selectedItemIndexes removeAllObjects];
    _selectedItemIndex = selectedItemIndex;
}

- (void)setSelectedItemIndexes:(NSMutableSet<NSNumber *> *)selectedItemIndexes {
    self.selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone;
    _selectedItemIndexes = selectedItemIndexes;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    _allowsMultipleSelection = allowsMultipleSelection;
    self.selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone;
}

- (void)setRowHeight:(CGFloat)rowHeight {
    _rowHeight = rowHeight;
    [self.tableView setNeedsLayout];
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QMUITableViewCell alloc] initForTableView:tableView withStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.backgroundColor = nil;// 使用 tableView 的背景色即可
    }
    cell.textLabel.text = self.items[indexPath.row];
    
    if (self.allowsMultipleSelection) {
        // 多选
        if ([self.selectedItemIndexes containsObject:@(indexPath.row)]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        // 单选
        if (self.selectedItemIndex == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    [cell updateCellAppearanceWithIndexPath:indexPath];
    
    if (self.cellForItemBlock) {
        self.cellForItemBlock(self, cell, indexPath.row);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.heightForItemBlock) {
        return self.heightForItemBlock(self, indexPath.row);
    }
    return self.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 单选情况下如果重复选中已被选中的cell，则什么都不做
    if (!self.allowsMultipleSelection && self.selectedItemIndex == indexPath.row) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    // 不允许选中当前cell，直接return
    if (self.canSelectItemBlock && !self.canSelectItemBlock(self, indexPath.row)) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (self.allowsMultipleSelection) {
        if ([self.selectedItemIndexes containsObject:@(indexPath.row)]) {
            // 当前的cell已经被选中，则取消选中
            [self.selectedItemIndexes removeObject:@(indexPath.row)];
            if (self.didDeselectItemBlock) {
                self.didDeselectItemBlock(self, indexPath.row);
            }
        } else {
            [self.selectedItemIndexes addObject:@(indexPath.row)];
            if (self.didSelectItemBlock) {
                self.didSelectItemBlock(self, indexPath.row);
            }
        }
        if ([tableView qmui_cellVisibleAtIndexPath:indexPath]) {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        BOOL isSelectedIndexPathBeforeVisible = NO;
        
        // 选中新的cell时，先反选之前被选中的那个cell
        NSIndexPath *selectedIndexPathBefore = nil;
        if (self.selectedItemIndex != QMUIDialogSelectionViewControllerSelectedItemIndexNone) {
            selectedIndexPathBefore = [NSIndexPath indexPathForRow:self.selectedItemIndex inSection:0];
            if (self.didDeselectItemBlock) {
                self.didDeselectItemBlock(self, selectedIndexPathBefore.row);
            }
            isSelectedIndexPathBeforeVisible = [tableView qmui_cellVisibleAtIndexPath:selectedIndexPathBefore];
        }
        
        self.selectedItemIndex = indexPath.row;
        
        // 如果之前被选中的那个cell也在可视区域里，则也要用动画去刷新它，否则只需要用动画刷新当前已选中的cell即可，之前被选中的那个交给cellForRow去刷新
        if (isSelectedIndexPathBeforeVisible) {
            [tableView reloadRowsAtIndexPaths:@[selectedIndexPathBefore, indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        if (self.didSelectItemBlock) {
            self.didSelectItemBlock(self, indexPath.row);
        }
    }
}

@end

@implementation QMUIDialogTextFieldViewController (UIAppearance)

+ (instancetype)appearance {
    return [QMUIAppearance appearanceForClass:self];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        QMUIDialogTextFieldViewController *dialogTextFieldViewControllerAppearance = QMUIDialogTextFieldViewController.appearance;
        dialogTextFieldViewControllerAppearance.textFieldLabelFont = UIFontBoldMake(12);
        dialogTextFieldViewControllerAppearance.textFieldLabelTextColor = UIColorGrayDarken;
        dialogTextFieldViewControllerAppearance.textFieldFont = UIFontMake(17);
        dialogTextFieldViewControllerAppearance.textFieldTextColor = UIColorBlack;
        dialogTextFieldViewControllerAppearance.textFieldSeparatorColor = UIColorSeparator;
        dialogTextFieldViewControllerAppearance.textFieldLabelMargins = UIEdgeInsetsMake(16, 22, -2, 22);
        dialogTextFieldViewControllerAppearance.textFieldMargins = UIEdgeInsetsMake(16, 16, 10, 16);
        dialogTextFieldViewControllerAppearance.textFieldHeight = 25;
        dialogTextFieldViewControllerAppearance.textFieldSeparatorInsets = UIEdgeInsetsMake(0, 0, 16, 0);
    });
}

@end

@interface QMUIDialogTextFieldViewController ()<QMUITextFieldDelegate>

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray<QMUILabel *> *mutableTitleLabels;
@property(nonatomic, strong) NSMutableArray<QMUITextField *> *mutableTextFields;
@property(nonatomic, strong) NSMutableArray<CALayer *> *mutableSeparatorLayers;
@end

@implementation QMUIDialogTextFieldViewController

- (void)didInitialize {
    [super didInitialize];
    
    self.mutableTitleLabels = [[NSMutableArray alloc] init];
    self.mutableTextFields = [[NSMutableArray alloc] init];
    self.mutableSeparatorLayers = [[NSMutableArray alloc] init];
    
    self.shouldManageTextFieldsReturnEventAutomatically = YES;
    self.enablesSubmitButtonAutomatically = YES;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.contentView = self.scrollView;
    self.scrollView.backgroundColor = self.contentViewBackgroundColor;
}

- (void)addTextFieldWithTitle:(NSString *)textFieldTitle configurationHandler:(void (^)(QMUILabel *titleLabel, QMUITextField *textField, CALayer *separatorLayer))configurationHandler {
    QMUILabel *label = [self generateTextFieldTitleLabel];
    label.text = textFieldTitle;
    if (textFieldTitle.length <= 0) {
        label.hidden = YES;
    }
    [self.mutableTitleLabels addObject:label];
    
    QMUITextField *textField = [self generateTextField];
    [self.mutableTextFields addObject:textField];
    
    CALayer *separatorLayer = [self generateTextFieldSeparatorLayer];
    [self.mutableSeparatorLayers addObject:separatorLayer];
    
    if (configurationHandler) {
        configurationHandler(label, textField, separatorLayer);
    }
}

- (QMUILabel *)generateTextFieldTitleLabel {
    QMUILabel *textFieldLabel = [[QMUILabel alloc] init];
    textFieldLabel.font = self.textFieldLabelFont;
    textFieldLabel.textColor = self.textFieldLabelTextColor;
    [self.contentView addSubview:textFieldLabel];
    return textFieldLabel;
}

- (QMUITextField *)generateTextField {
    QMUITextField *textField = [[QMUITextField alloc] init];
    textField.delegate = self;
    textField.font = self.textFieldFont;
    textField.textColor = self.textFieldTextColor;
    textField.backgroundColor = nil;
    textField.returnKeyType = UIReturnKeyNext;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.enablesReturnKeyAutomatically = self.enablesSubmitButtonAutomatically;
    [textField addTarget:self action:@selector(handleTextFieldTextDidChangeEvent:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:textField];
    return textField;
}

- (CALayer *)generateTextFieldSeparatorLayer {
    CALayer *textFieldSeparatorLayer = [CALayer qmui_separatorLayer];
    textFieldSeparatorLayer.backgroundColor = self.textFieldSeparatorColor.CGColor;
    [self.contentView.layer addSublayer:textFieldSeparatorLayer];
    return textFieldSeparatorLayer;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 全部基于 contentView 布局即可
    
    QMUIAssert(self.mutableTitleLabels.count == self.mutableTextFields.count && self.mutableTextFields.count == self.mutableSeparatorLayers.count, NSStringFromClass(self.class), @"标题、输入框、分隔线的数量不匹配");
    
    CGFloat minY = 0;
    
    for (NSInteger i = 0; i < self.mutableTitleLabels.count; i++) {
        QMUILabel *label = self.mutableTitleLabels[i];
        QMUITextField *textField = self.mutableTextFields[i];
        CALayer *separatorLayer = self.mutableSeparatorLayers[i];
        
        if (!label.hidden) {
            [label sizeToFit];
            label.frame = CGRectFlatMake(self.textFieldLabelMargins.left, minY + self.textFieldLabelMargins.top, CGRectGetWidth(self.contentView.bounds) - UIEdgeInsetsGetHorizontalValue(self.textFieldLabelMargins), CGRectGetHeight(label.frame));
            minY = CGRectGetMaxY(label.frame) + self.textFieldLabelMargins.bottom;
        }
        
        textField.frame = CGRectFlatMake(self.textFieldMargins.left, minY + self.textFieldMargins.top, CGRectGetWidth(self.contentView.bounds) - UIEdgeInsetsGetHorizontalValue(self.textFieldMargins), self.textFieldHeight);
        minY = CGRectGetMaxY(textField.frame) + self.textFieldMargins.bottom;
        
        // 宽度基于 textField 的宽度减去 textField.textInsets，从而保证与文字对齐
        if (!separatorLayer.hidden) {
            CGFloat separatorMinX = CGRectGetMinX(textField.frame) + textField.textInsets.left + self.textFieldSeparatorInsets.left;
            CGFloat separatorWidth = CGRectGetWidth(textField.frame) - UIEdgeInsetsGetHorizontalValue(textField.textInsets) - UIEdgeInsetsGetHorizontalValue(self.textFieldSeparatorInsets);
            separatorLayer.frame = CGRectMake(separatorMinX, minY + self.textFieldSeparatorInsets.top, separatorWidth, PixelOne);
            minY = CGRectGetMinY(separatorLayer.frame) + self.textFieldSeparatorInsets.bottom;// 用 minY 是因为分隔线高度不占位
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), minY);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mutableTextFields.firstObject becomeFirstResponder];
    
    if (self.enablesSubmitButtonAutomatically) {
        // 触发所有输入框的 enablesReturnKeyAutomatically 属性的更新
        self.enablesSubmitButtonAutomatically = self.enablesSubmitButtonAutomatically;
    }
    
    // 最后一个输入框默认是 Done，其他输入框都是 Next
    self.mutableTextFields.lastObject.returnKeyType = UIReturnKeyDone;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Getters & Setters

- (void)setContentViewBackgroundColor:(UIColor *)contentViewBackgroundColor {
    [super setContentViewBackgroundColor:contentViewBackgroundColor];
    self.scrollView.backgroundColor = contentViewBackgroundColor;
}

- (void)setTextFieldLabelFont:(UIFont *)textFieldLabelFont {
    _textFieldLabelFont = textFieldLabelFont;
    [self.mutableTitleLabels enumerateObjectsUsingBlock:^(QMUILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        label.font = textFieldLabelFont;
    }];
    if (self.mutableTitleLabels.count) {
        [self.modalPresentationViewController updateLayout];
    }
}

- (void)setTextFieldLabelTextColor:(UIColor *)textFieldLabelTextColor {
    _textFieldLabelTextColor = textFieldLabelTextColor;
    [self.mutableTitleLabels enumerateObjectsUsingBlock:^(QMUILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        label.textColor = textFieldLabelTextColor;
    }];
}

- (void)setTextFieldFont:(UIFont *)textFieldFont {
    _textFieldFont = textFieldFont;
    [self.mutableTextFields enumerateObjectsUsingBlock:^(QMUITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.font = textFieldFont;
    }];
}

- (void)setTextFieldTextColor:(UIColor *)textFieldTextColor {
    _textFieldTextColor = textFieldTextColor;
    [self.mutableTextFields enumerateObjectsUsingBlock:^(QMUITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.textColor = textFieldTextColor;
    }];
}

- (void)setTextFieldSeparatorColor:(UIColor *)textFieldSeparatorColor {
    _textFieldSeparatorColor = textFieldSeparatorColor;
    [self.mutableSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.backgroundColor = textFieldSeparatorColor.CGColor;
    }];
}

- (void)setTextFieldLabelMargins:(UIEdgeInsets)textFieldLabelMargins {
    _textFieldLabelMargins = textFieldLabelMargins;
    if (self.mutableTitleLabels.count) {
        [self.modalPresentationViewController updateLayout];
    }
}

- (void)setTextFieldMargins:(UIEdgeInsets)textFieldMargins {
    _textFieldMargins = textFieldMargins;
    if (self.textFields.count) {
        [self.modalPresentationViewController updateLayout];
    }
}

- (void)setTextFieldHeight:(CGFloat)textFieldHeight {
    _textFieldHeight = textFieldHeight;
    if (self.textFields.count) {
        [self.modalPresentationViewController updateLayout];
    }
}

- (void)setTextFieldSeparatorInsets:(UIEdgeInsets)textFieldSeparatorInsets {
    _textFieldSeparatorInsets = textFieldSeparatorInsets;
    if (self.mutableSeparatorLayers.count) {
        [self.modalPresentationViewController updateLayout];
    }
}

- (NSArray<QMUILabel *> *)textFieldTitleLabels {
    return self.mutableTitleLabels.copy;
}

- (NSArray<QMUITextField *> *)textFields {
    return self.mutableTextFields.copy;
}

- (NSArray<CALayer *> *)textFieldSeparatorLayers {
    return self.mutableSeparatorLayers.copy;
}

#pragma mark - Submit Button Enables

- (void)setEnablesSubmitButtonAutomatically:(BOOL)enablesSubmitButtonAutomatically {
    _enablesSubmitButtonAutomatically = enablesSubmitButtonAutomatically;
    [self.mutableTextFields enumerateObjectsUsingBlock:^(QMUITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        // enablesSubmitButtonAutomatically 只对最后一个输入框生效
        if (enablesSubmitButtonAutomatically && idx != self.mutableTextFields.count - 1) {
            textField.enablesReturnKeyAutomatically = NO;
        } else {
            textField.enablesReturnKeyAutomatically = enablesSubmitButtonAutomatically;
        }
    }];
    if (enablesSubmitButtonAutomatically) {
        [self updateSubmitButtonEnables];
    }
}

- (void)updateSubmitButtonEnables {
    self.submitButton.enabled = [self shouldEnabledSubmitButton];
}

- (BOOL)shouldEnabledSubmitButton {
    if (self.shouldEnableSubmitButtonBlock) {
        return self.shouldEnableSubmitButtonBlock(self);
    }
    
    if (self.enablesSubmitButtonAutomatically) {
        __block BOOL enabled = NO;
        [self.mutableTextFields enumerateObjectsUsingBlock:^(QMUITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger textLength = textField.text.qmui_trim.length;
            enabled = 0 < textLength && textLength <= textField.maximumTextLength;
            if (!enabled) {
                *stop = YES;
            }
        }];
        return enabled;
    }
    
    return YES;
}

- (void)handleTextFieldTextDidChangeEvent:(QMUITextField *)textField {
    if ([self.mutableTextFields containsObject:textField]) {
        [self updateSubmitButtonEnables];
    }
}

- (void)addSubmitButtonWithText:(NSString *)buttonText block:(void (^)(__kindof QMUIDialogViewController *dialogViewController))block {
    [super addSubmitButtonWithText:buttonText block:block];
    [self updateSubmitButtonEnables];
}

#pragma mark - <QMUIModalPresentationContentViewControllerProtocol>

- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller keyboardHeight:(CGFloat)keyboardHeight limitSize:(CGSize)limitSize {
    
    CGFloat textFieldLabelHeight = 0;
    for (QMUILabel *label in self.mutableTitleLabels) {
        if (!label.hidden) {
            CGFloat labelHeight = flat([label sizeThatFits:CGSizeMax].height);
            textFieldLabelHeight += labelHeight + UIEdgeInsetsGetVerticalValue(self.textFieldLabelMargins);
        }
    }
    
    CGFloat textFieldHeight = self.mutableTextFields.count * (self.textFieldHeight + UIEdgeInsetsGetVerticalValue(self.textFieldMargins));
    
    CGFloat separatorHeight = 0;
    for (CALayer *separatorLayer in self.mutableSeparatorLayers) {
        if (!separatorLayer.hidden) {
            separatorHeight += UIEdgeInsetsGetVerticalValue(self.textFieldSeparatorInsets);
        }
    }
    
    CGFloat contentHeight = textFieldLabelHeight + textFieldHeight + separatorHeight + UIEdgeInsetsGetVerticalValue(self.scrollView.adjustedContentInset);
    CGFloat contentViewVerticalMargin = UIEdgeInsetsGetVerticalValue(self.contentViewMargins);
    
    BOOL isFooterViewShowing = self.footerView && !self.footerView.hidden;
    CGFloat footerHeight = isFooterViewShowing ? self.footerViewHeight : 0;
    
    CGSize finalSize = CGSizeMake(limitSize.width, MIN(limitSize.height, self.headerViewHeight + contentHeight + contentViewVerticalMargin + footerHeight));
    return finalSize;
}

#pragma mark - <QMUITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(QMUITextField *)textField {
    if (!self.shouldManageTextFieldsReturnEventAutomatically) {
        return NO;
    }
    
    if (![self.mutableTextFields containsObject:textField]) {
        return NO;
    }
    
    if (self.mutableTextFields.count > 1) {
        if (textField != self.mutableTextFields.lastObject && textField.returnKeyType == UIReturnKeyNext) {
            NSUInteger index = [self.mutableTextFields indexOfObject:textField];
            [self.mutableTextFields[index + 1] becomeFirstResponder];
            return YES;
        }
    }
    
    // 有 submitButton 则响应它，没有的话响应 cancel，再没有就降下键盘即可（体验与 UIAlertController 一致）
    
    if (self.submitButton.enabled) {
        [self.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        return NO;
    }
    
    return NO;
}

@end
