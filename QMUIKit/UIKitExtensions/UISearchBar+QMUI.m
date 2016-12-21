//
//  UISearchBar+QMUI.m
//  qmui
//
//  Created by MoLice on 16/5/26.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UISearchBar+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "UIImage+QMUI.h"

@implementation UISearchBar (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(setPlaceholder:), @selector(qmui_setPlaceholder:));
    });
}

static char kAssociatedObjectKey_PlaceholderColor;
- (void)setPlaceholderColor:(UIColor *)argv {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor, argv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: argv}];
    }
}

- (UIColor *)placeholderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor);
}

- (void)qmui_setPlaceholder:(NSString *)placeholder {
    [self qmui_setPlaceholder:placeholder];
    // placeholder的颜色
    if (self.placeholderColor) {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
    }
}

static char kAssociatedObjectKey_TextColor;
- (void)setTextColor:(UIColor *)argv {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_TextColor, argv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.textField.textColor = argv;
}

- (UIColor *)textColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_TextColor);
}

- (void)styledAsQMUISearchBar {
    self.textColor = UIColorBlack;
    self.placeholderColor = SearchBarPlaceholderColor;
    self.placeholder = @"搜索";
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchTextPositionAdjustment = UIOffsetMake(5, 0);
    
    // 设置搜索icon
    UIImage *searchIconImage = SearchBarSearchIconImage;
    if (searchIconImage) {
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
    [self setSearchFieldBackgroundImage:[[[UIImage imageWithColor:SearchBarTextFieldBackground size:CGSizeMake(60, 28) cornerRadius:SearchBarTextFieldCornerRadius] imageWithBorderColor:SearchBarTextFieldBorderColor borderWidth:PixelOne cornerRadius:SearchBarTextFieldCornerRadius] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)] forState:UIControlStateNormal];
    
    // 整条bar的背景
    // iOS7及以后不用barTintColor设置背景是因为这么做的话会出现上下border，去不掉，所以iOS6和7都改为用backgroundImage实现
    UIImage *backgroundImage = [[[UIImage imageWithColor:SearchBarBarTintColor size:CGSizeMake(10, 10) cornerRadius:0] imageWithBorderColor:SearchBarBottomBorderColor borderWidth:PixelOne borderPosition:QMUIImageBorderPositionBottom] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (UITextField *)textField {
    UITextField *textField = [self valueForKey:@"_searchField"];
    return textField;
}

@end
