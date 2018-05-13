;//
//  QMUIDialogViewController.m
//  WeRead
//
//  Created by MoLice on 16/7/8.
//  Copyright © 2016年 QMUI Team. All rights reserved.
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

@implementation QMUIDialogViewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static QMUIDialogViewController *dialogViewControllerAppearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!dialogViewControllerAppearance) {
            dialogViewControllerAppearance = [[QMUIDialogViewController alloc] init];
            dialogViewControllerAppearance.cornerRadius = 6;
            dialogViewControllerAppearance.dialogViewMargins = UIEdgeInsetsMake(20, 20, 20, 20); // 在实例的 didInitialized 里会适配 iPhone X 的 safeAreaInsets
            dialogViewControllerAppearance.maximumContentViewWidth = [QMUIHelper screenSizeFor55Inch].width - UIEdgeInsetsGetHorizontalValue(dialogViewControllerAppearance.dialogViewMargins);
            dialogViewControllerAppearance.backgroundColor = UIColorClear;
            dialogViewControllerAppearance.titleTintColor = UIColorBlack;
            dialogViewControllerAppearance.titleLabelFont = UIFontMake(16);
            dialogViewControllerAppearance.titleLabelTextColor = UIColorMake(53, 60, 70);
            dialogViewControllerAppearance.subTitleLabelFont = UIFontMake(12);
            dialogViewControllerAppearance.subTitleLabelTextColor = UIColorMake(133, 140, 150);
            
            dialogViewControllerAppearance.headerSeparatorColor = UIColorMake(222, 224, 226);
            dialogViewControllerAppearance.headerViewHeight = 48;
            dialogViewControllerAppearance.headerViewBackgroundColor = UIColorMake(244, 245, 247);
            dialogViewControllerAppearance.contentViewMargins = UIEdgeInsetsZero;
            dialogViewControllerAppearance.footerSeparatorColor = UIColorMake(222, 224, 226);
            dialogViewControllerAppearance.footerViewHeight = 48;
            dialogViewControllerAppearance.footerViewBackgroundColor = UIColorWhite;
            
            dialogViewControllerAppearance.buttonBackgroundColor = nil;
            dialogViewControllerAppearance.buttonTitleAttributes = @{NSForegroundColorAttributeName: UIColorBlue, NSKernAttributeName: @2};
            dialogViewControllerAppearance.buttonHighlightedBackgroundColor = [UIColorBlue colorWithAlphaComponent:.25];
        }
    });
    return dialogViewControllerAppearance;
}

@end

@interface QMUIDialogViewController ()

@property(nonatomic, assign) BOOL hasCustomContentView;
@property(nonatomic,copy) void (^cancelButtonBlock)(QMUIDialogViewController *dialogViewController);
@property(nonatomic,copy) void (^submitButtonBlock)(QMUIDialogViewController *dialogViewController);
@end

@implementation QMUIDialogViewController

- (void)didInitialized {
    [super didInitialized];
    if (dialogViewControllerAppearance) {
        self.cornerRadius = [QMUIDialogViewController appearance].cornerRadius;
        self.dialogViewMargins = UIEdgeInsetsConcat([QMUIDialogViewController appearance].dialogViewMargins, IPhoneXSafeAreaInsets);
        self.maximumContentViewWidth = [QMUIDialogViewController appearance].maximumContentViewWidth;
        self.backgroundColor = [QMUIDialogViewController appearance].backgroundColor;
        self.titleTintColor = [QMUIDialogViewController appearance].titleTintColor;
        self.titleLabelFont = [QMUIDialogViewController appearance].titleLabelFont;
        self.titleLabelTextColor = [QMUIDialogViewController appearance].titleLabelTextColor;
        self.subTitleLabelFont = [QMUIDialogViewController appearance].subTitleLabelFont;
        self.subTitleLabelTextColor = [QMUIDialogViewController appearance].subTitleLabelTextColor;
        self.headerSeparatorColor = [QMUIDialogViewController appearance].headerSeparatorColor;
        self.headerViewHeight = [QMUIDialogViewController appearance].headerViewHeight;
        self.headerViewBackgroundColor = [QMUIDialogViewController appearance].headerViewBackgroundColor;
        self.contentViewMargins = [QMUIDialogViewController appearance].contentViewMargins;
        self.footerSeparatorColor = [QMUIDialogViewController appearance].footerSeparatorColor;
        self.footerViewHeight = [QMUIDialogViewController appearance].footerViewHeight;
        self.footerViewBackgroundColor = [QMUIDialogViewController appearance].footerViewBackgroundColor;
        self.buttonBackgroundColor = [QMUIDialogViewController appearance].buttonBackgroundColor;
        self.buttonTitleAttributes = [QMUIDialogViewController appearance].buttonTitleAttributes;
        self.buttonHighlightedBackgroundColor = [QMUIDialogViewController appearance].buttonHighlightedBackgroundColor;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    if ([self isViewLoaded ]) {
        self.view.layer.cornerRadius = cornerRadius;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;
}

- (void)setTitleTintColor:(UIColor *)titleTintColor {
    _titleTintColor = titleTintColor;
    self.titleView.tintColor = titleTintColor;
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    self.titleView.titleLabel.font = titleLabelFont;
    self.titleView.verticalTitleFont = titleLabelFont;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor {
    _titleLabelTextColor = titleLabelTextColor;
    self.titleView.titleLabel.textColor = titleLabelTextColor;
}

- (void)setSubTitleLabelFont:(UIFont *)subTitleLabelFont {
    _subTitleLabelFont = subTitleLabelFont;
    self.titleView.subtitleLabel.font = subTitleLabelFont;
    self.titleView.verticalSubtitleFont = subTitleLabelFont;
}

- (void)setSubTitleLabelTextColor:(UIColor *)subTitleLabelTextColor {
    _subTitleLabelTextColor = subTitleLabelTextColor;
    self.titleView.subtitleLabel.textColor = subTitleLabelTextColor;
}

- (void)setHeaderSeparatorColor:(UIColor *)headerSeparatorColor {
    _headerSeparatorColor = headerSeparatorColor;
    if (self.headerViewSeparatorLayer) {
        self.headerViewSeparatorLayer.backgroundColor = headerSeparatorColor.CGColor;
    }
}

- (void)setFooterSeparatorColor:(UIColor *)footerSeparatorColor {
    _footerSeparatorColor = footerSeparatorColor;
    if (self.footerViewSeparatorLayer) {
        self.footerViewSeparatorLayer.backgroundColor = footerSeparatorColor.CGColor;
    }
    if (self.buttonSeparatorLayer) {
        self.buttonSeparatorLayer.backgroundColor = footerSeparatorColor.CGColor;
    }
}

- (void)setHeaderViewHeight:(CGFloat)headerViewHeight {
    _headerViewHeight = headerViewHeight;
}

- (void)setHeaderViewBackgroundColor:(UIColor *)headerViewBackgroundColor {
    _headerViewBackgroundColor = headerViewBackgroundColor;
    if ([self isViewLoaded]) {
        self.headerView.backgroundColor = headerViewBackgroundColor;
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
    
    // subview都在[super viewDidLoad]里添加，所以在添加完subview后再强制把headerView和footerView拉到最前面，以保证分隔线不会被subview盖住
    [self.view bringSubviewToFront:self.headerView];
    [self.view bringSubviewToFront:self.footerView];
    
    self.view.backgroundColor = UIColorClear; // 减少 Color Blended Layers
    self.view.layer.cornerRadius = self.cornerRadius;
    self.view.layer.masksToBounds = YES;
}

- (void)initSubviews {
    [super initSubviews];
    
    if (self.hasCustomContentView) {
        if (!self.contentView.superview) {
            [self.view insertSubview:self.contentView atIndex:0];
        }
    } else {
        _contentView = [[UIView alloc] init]; // 特地不使用setter，从而不要影响self.hasCustomContentView的默认值
        self.contentView.backgroundColor = UIColorWhite;
        [self.view addSubview:self.contentView];
    }
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.headerViewHeight)];
    self.headerView.backgroundColor = self.headerViewBackgroundColor;
    
    // 使用自带的QMUINavigationTitleView，支持loading、subTitle
    [self.headerView addSubview:self.titleView];
    
    // 加上分隔线
    _headerViewSeparatorLayer = [CALayer layer];
    [self.headerViewSeparatorLayer qmui_removeDefaultAnimations];
    self.headerViewSeparatorLayer.backgroundColor = self.headerSeparatorColor.CGColor;
    [self.headerView.layer addSublayer:self.headerViewSeparatorLayer];
    
    [self.view addSubview:self.headerView];
    
    [self initFooterViewIfNeeded];
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
    CGFloat titleViewWidth = fmin(titleViewSize.width, headerViewContentWidth);
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

- (void)initFooterViewIfNeeded {
    if (!self.footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.footerViewHeight)];
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
        
        [self.view addSubview:self.footerView];
    }
}

- (void)addCancelButtonWithText:(NSString *)buttonText block:(void (^)(__kindof QMUIDialogViewController *))block {
    if (_cancelButton) {
        [_cancelButton removeFromSuperview];
    }
    
    _cancelButton = [self generateButtonWithText:buttonText];
    [self.cancelButton addTarget:self action:@selector(handleCancelButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self initFooterViewIfNeeded];
    self.footerView.hidden = NO;
    [self.footerView addSubview:self.cancelButton];
    
    self.cancelButtonBlock = block;
}

- (void)addSubmitButtonWithText:(NSString *)buttonText block:(void (^)(__kindof QMUIDialogViewController *dialogViewController))block {
    if (_submitButton) {
        [_submitButton removeFromSuperview];
    }
    
    _submitButton = [self generateButtonWithText:buttonText];
    [self.submitButton addTarget:self action:@selector(handleSubmitButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self initFooterViewIfNeeded];
    self.footerView.hidden = NO;
    [self.footerView addSubview:self.submitButton];
    
    self.submitButtonBlock = block;
}

- (QMUIButton *)generateButtonWithText:(NSString *)buttonText {
    QMUIButton *button = [[QMUIButton alloc] init];
    button.titleLabel.font = UIFontBoldMake((IS_320WIDTH_SCREEN) ? 14 : 15);
    button.adjustsTitleTintColorAutomatically = YES;
    button.backgroundColor = self.buttonBackgroundColor;
    button.highlightedBackgroundColor = self.buttonHighlightedBackgroundColor;
    [button setAttributedTitle:[[NSAttributedString alloc] initWithString:buttonText attributes:self.buttonTitleAttributes] forState:UIControlStateNormal];
    return button;
}

- (void)handleCancelButtonEvent:(QMUIButton *)cancelButton {
    [self hideWithAnimated:YES completion:^(BOOL finished) {
        if (self.cancelButtonBlock) {
            self.cancelButtonBlock(self);
        }
    }];
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
    QMUIModalPresentationViewController *modalPresentationViewController = [[QMUIModalPresentationViewController alloc] init];
    modalPresentationViewController.contentViewMargins = self.dialogViewMargins;
    modalPresentationViewController.maximumContentViewWidth = self.maximumContentViewWidth;
    modalPresentationViewController.contentViewController = self;
    modalPresentationViewController.modal = YES;
    [modalPresentationViewController showWithAnimated:YES completion:completion];
}

- (void)hide {
    [self hideWithAnimated:YES completion:nil];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self.qmui_modalPresentationViewController hideWithAnimated:animated completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

#pragma mark - <QMUIModalPresentationContentViewControllerProtocol>

- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller limitSize:(CGSize)limitSize {
    if (!self.hasCustomContentView) {
        return limitSize;
    }
    
    BOOL isFooterViewShowing = self.footerView && !self.footerView.hidden;
    CGFloat footerHeight = isFooterViewShowing ? self.footerViewHeight : 0;
    
    CGFloat contentViewVerticalMargin = UIEdgeInsetsGetVerticalValue(self.contentViewMargins);
    
    CGSize contentViewLimitSize = CGSizeMake(limitSize.width, limitSize.height - self.headerViewHeight - contentViewVerticalMargin - footerHeight);
    CGSize contentViewSize = [self.contentView sizeThatFits:contentViewLimitSize];
    
    CGSize finalSize = CGSizeMake(fmin(limitSize.width, contentViewSize.width), fmin(limitSize.height, self.headerViewHeight + contentViewSize.height + contentViewVerticalMargin + footerHeight));
    return finalSize;
}

@end

const NSInteger QMUIDialogSelectionViewControllerSelectedItemIndexNone = -1;

@interface QMUIDialogSelectionViewController ()

@property(nonatomic,strong,readwrite) QMUITableView *tableView;
@end

@implementation QMUIDialogSelectionViewController

- (void)didInitialized {
    [super didInitialized];
    
    self.selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone;
    self.selectedItemIndexes = [[NSMutableSet alloc] init];
    BeginIgnoreAvailabilityWarning
    [self loadViewIfNeeded];
    EndIgnoreAvailabilityWarning
}

- (void)initSubviews {
    [super initSubviews];
    self.tableView = [[QMUITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.alwaysBounceVertical = NO;
    
    // 因为要根据 tableView sizeThatFits: 算出 dialog 的高度，所以禁用 estimated 特性，不然算出来结果不准确
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat tableViewMinY = CGRectGetMaxY(self.headerView.frame) + self.contentViewMargins.top;
    CGFloat tableViewHeight = CGRectGetHeight(self.view.bounds) - tableViewMinY - (!self.footerView.hidden ? (CGRectGetHeight(self.footerView.bounds) + self.contentViewMargins.bottom) : 0);
    self.tableView.frame = CGRectMake(self.contentViewMargins.left, tableViewMinY, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentViewMargins), tableViewHeight);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 当前的分组不在可视区域内，则滚动到可视区域（只对单选有效）
    if (self.selectedItemIndex != QMUIDialogSelectionViewControllerSelectedItemIndexNone && self.selectedItemIndex < self.items.count && ![self.tableView qmui_cellVisibleAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItemIndex inSection:0]]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItemIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
    }
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    _selectedItemIndex = selectedItemIndex;
    [self.selectedItemIndexes removeAllObjects];
}

- (void)setselectedItemIndexes:(NSMutableSet<NSNumber *> *)selectedItemIndexes {
    _selectedItemIndexes = selectedItemIndexes;
    self.selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    _allowsMultipleSelection = allowsMultipleSelection;
    self.selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QMUITableViewCell alloc] initForTableView:self.tableView withStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
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
    return TableViewCellNormalHeight;
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

#pragma mark - <QMUIModalPresentationContentViewControllerProtocol>

- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller limitSize:(CGSize)limitSize {
    CGFloat contentViewVerticalMargin = UIEdgeInsetsGetVerticalValue(self.contentViewMargins);
    CGFloat footerHeight = !self.footerView.hidden ? CGRectGetHeight(self.footerView.frame) : 0;
    CGFloat tableViewLimitHeight = limitSize.height - CGRectGetHeight(self.headerView.frame) - footerHeight - contentViewVerticalMargin;
    CGSize tableViewSize = [self.tableView sizeThatFits:CGSizeMake(limitSize.width, tableViewLimitHeight)];
    CGFloat finalTableViewHeight = fmin(tableViewSize.height, tableViewLimitHeight);
    return CGSizeMake(limitSize.width, CGRectGetHeight(self.headerView.frame) + finalTableViewHeight + contentViewVerticalMargin + footerHeight);
}

@end

@interface QMUIDialogTextFieldViewController ()<QMUITextFieldDelegate>

@property(nonatomic, strong, readwrite) QMUILabel *textFieldLabel;
@property(nonatomic, strong, readwrite) CALayer *textFieldSeparatorLayer;
@property(nonatomic, strong, readwrite) QMUITextField *textField;

@end

@implementation QMUIDialogTextFieldViewController

- (void)didInitialized {
    [super didInitialized];
    self.shouldManageTextFieldsReturnEventAutomatically = YES;
    self.enablesSubmitButtonAutomatically = YES;
    BeginIgnoreAvailabilityWarning
    [self loadViewIfNeeded];
    EndIgnoreAvailabilityWarning
}

- (void)initSubviews {
    [super initSubviews];
    
    self.textField = [[QMUITextField alloc] init];
    self.textField.delegate = self;
    self.textField.backgroundColor = UIColorWhite;
    self.textField.textInsets = UIEdgeInsetsMake(self.textField.textInsets.top, 16, self.textField.textInsets.bottom, 16);
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.enablesReturnKeyAutomatically = self.enablesSubmitButtonAutomatically;
    [self.textField addTarget:self action:@selector(handleTextFieldTextDidChangeEvent:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.textField];
    
    self.textFieldLabel = [[QMUILabel alloc] init];
    self.textFieldLabel.font = UIFontBoldMake(12);
    self.textFieldLabel.contentEdgeInsets = UIEdgeInsetsMake(11, 16, 8, 16);
    self.textFieldLabel.text = @"";
    self.textFieldLabel.hidden = YES;
    [self.view addSubview:self.textFieldLabel];
    
    self.textFieldSeparatorLayer = [CALayer layer];
    [self.textFieldSeparatorLayer qmui_removeDefaultAnimations];
    self.textFieldSeparatorLayer.backgroundColor = UIColorSeparator.CGColor;
    [self.view.layer addSublayer:self.textFieldSeparatorLayer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat minY = CGRectGetMaxY(self.headerView.frame) + self.contentViewMargins.top;
    CGFloat horizontalMargin = UIEdgeInsetsGetHorizontalValue(self.contentViewMargins);
    CGFloat widthLimit = CGRectGetWidth(self.view.bounds) - horizontalMargin;
    CGFloat separatorOffsetY = 13.0;
    
    if (!self.textFieldLabel.hidden) {
        [self.textFieldLabel sizeToFit];
        self.textFieldLabel.frame = CGRectMake(self.contentViewMargins.left, minY, widthLimit, CGRectGetHeight(self.textFieldLabel.bounds));
        minY += CGRectGetHeight(self.textFieldLabel.bounds);
    }
    
    CGFloat textFieldHeight = 0;
    if (self.footerView.hidden) {
        textFieldHeight = CGRectGetHeight(self.view.bounds) - self.contentViewMargins.bottom - minY;
    } else {
        textFieldHeight = CGRectGetMinY(self.footerView.frame) - self.contentViewMargins.bottom - minY;
    }
    
    self.textField.frame = CGRectMake(self.contentViewMargins.left, minY, widthLimit, textFieldHeight);
    self.textFieldSeparatorLayer.frame = CGRectMake(self.contentViewMargins.left + self.textField.textInsets.left, CGRectGetMaxY(self.textField.frame) - PixelOne + separatorOffsetY, widthLimit - self.textField.textInsets.left - self.textField.textInsets.right, PixelOne);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
}

#pragma mark - Setters
- (void)setTextFieldTitle:(NSString *)textFieldTitle {
    _textFieldTitle = textFieldTitle;
    
    if (textFieldTitle.length > 0) {
        self.textFieldLabel.hidden = NO;
        self.textFieldLabel.text = textFieldTitle;
    } else {
        self.textFieldLabel.hidden = YES;
    }
    
    [self.view setNeedsLayout];
}

#pragma mark - Submit Button Enables

- (void)setEnablesSubmitButtonAutomatically:(BOOL)enablesSubmitButtonAutomatically {
    _enablesSubmitButtonAutomatically = enablesSubmitButtonAutomatically;
    self.textField.enablesReturnKeyAutomatically = _enablesSubmitButtonAutomatically;
    if (_enablesSubmitButtonAutomatically) {
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
        NSInteger textLength = self.textField.text.qmui_trim.length;
        return 0 < textLength && textLength <= self.textField.maximumTextLength;
    }
    
    return YES;
}

- (void)handleTextFieldTextDidChangeEvent:(QMUITextField *)textField {
    if (self.textField == textField) {
        [self updateSubmitButtonEnables];
    }
}

- (void)addSubmitButtonWithText:(NSString *)buttonText block:(void (^)(__kindof QMUIDialogViewController *dialogViewController))block {
    [super addSubmitButtonWithText:buttonText block:block];
    [self updateSubmitButtonEnables];
}

#pragma mark - <QMUIModalPresentationContentViewControllerProtocol>

- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller limitSize:(CGSize)limitSize {
    CGFloat textFieldHeight = self.textFieldLabel.hidden ? 56.0 : 25.0; // 25.0 考虑了行高导致的 offsetoffset
    CGFloat textFieldTitleHeight = 29.0;
    
    return CGSizeMake(limitSize.width, CGRectGetHeight(self.headerView.frame) + UIEdgeInsetsGetVerticalValue(self.contentViewMargins) + (!self.textFieldLabel.hidden ? textFieldTitleHeight : 0) + textFieldHeight + (!self.footerView.hidden ?  CGRectGetHeight(self.footerView.frame) : 0));
}

#pragma mark - <QMUITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!self.shouldManageTextFieldsReturnEventAutomatically) {
        return NO;
    }
    
    if (textField != self.textField) {
        return NO;
    }
    
    // 有 submitButton 则响应它，没有的话响应 cancel，再没有就降下键盘即可（体验与 UIAlertController 一致）
    
    if (self.submitButton.enabled) {
        [self.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        return NO;
    }
    
    if (self.cancelButton) {
        [self.cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        return NO;
    }
    
    [self.view endEditing:YES];
    return NO;
}

@end
