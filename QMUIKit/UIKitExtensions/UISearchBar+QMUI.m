//
//  UISearchBar+QMUI.m
//  qmui
//
//  Created by MoLice on 16/5/26.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UISearchBar+QMUI.h"
#import "QMUICore.h"
#import "UIImage+QMUI.h"

@implementation UISearchBar (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(setPlaceholder:), @selector(qmui_setPlaceholder:));
    });
}

- (void)qmui_setPlaceholder:(NSString *)placeholder {
    [self qmui_setPlaceholder:placeholder];
    if (self.qmui_placeholderColor || self.qmui_font) {
        NSMutableDictionary<NSString *, id> *attributes = [[NSMutableDictionary alloc] init];
        if (self.qmui_placeholderColor) {
            attributes[NSForegroundColorAttributeName] = self.qmui_placeholderColor;
        }
        if (self.qmui_font) {
            attributes[NSFontAttributeName] = self.qmui_font;
        }
        self.qmui_textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:attributes];
    }
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
}

- (UIFont *)qmui_font {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_font);
}

- (UITextField *)qmui_textField {
    UITextField *textField = [self valueForKey:@"searchField"];
    return textField;
}

- (void)qmui_styledAsQMUISearchBar {
    // 搜索框的字号及 placeholder 的字号
    UIFont *font = SearchBarFont;
    if (font) {
        self.qmui_font = font;
    }
    
    // 搜索框的文字颜色
    UIColor *textColor = SearchBarTextColor;
    if (textColor) {
        self.qmui_textColor = SearchBarTextColor;
    }
    
    // placeholder 的文字颜色
    UIColor *placeholderColor = SearchBarPlaceholderColor;
    if (placeholderColor) {
        self.qmui_placeholderColor = SearchBarPlaceholderColor;
    }
    
    self.placeholder = @"搜索";
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchTextPositionAdjustment = UIOffsetMake(5, 0);
    
    // 设置搜索icon
    UIImage *searchIconImage = SearchBarSearchIconImage;
    if (searchIconImage) {
        if (!CGSizeEqualToSize(searchIconImage.size, CGSizeMake(13, 13))) {
            QMUILog(@"搜索框放大镜图片（SearchBarSearchIconImage）的大小最好为 (13, 13)，否则会失真，目前的大小为 %@", NSStringFromCGSize(searchIconImage.size));
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
    UIColor *textFieldBackgroundColor = SearchBarTextFieldBackground;
    if (textFieldBackgroundColor) {
        [self setSearchFieldBackgroundImage:[[[UIImage qmui_imageWithColor:SearchBarTextFieldBackground size:CGSizeMake(60, 28) cornerRadius:SearchBarTextFieldCornerRadius] qmui_imageWithBorderColor:SearchBarTextFieldBorderColor borderWidth:PixelOne cornerRadius:SearchBarTextFieldCornerRadius] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)] forState:UIControlStateNormal];
    }
    
    // 整条bar的背景
    // iOS7及以后不用barTintColor设置背景是因为这么做的话会出现上下border，去不掉，所以iOS6和7都改为用backgroundImage实现
    UIColor *barTintColor = SearchBarBarTintColor;
    if (barTintColor) {
        UIImage *backgroundImage = [[[UIImage qmui_imageWithColor:SearchBarBarTintColor size:CGSizeMake(10, 10) cornerRadius:0] qmui_imageWithBorderColor:SearchBarBottomBorderColor borderWidth:PixelOne borderPosition:QMUIImageBorderPositionBottom] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

@end
