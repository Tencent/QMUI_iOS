//
//  QMUIBadgeLabel.m
//  QMUIKit
//
//  Created by molice on 2023/7/26.
//  Copyright © 2023 QMUI Team. All rights reserved.
//

#import "QMUIBadgeLabel.h"
#import "QMUICore.h"

@implementation QMUIBadgeLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
        if (@available(iOS 13.0, *)) {
            self.layer.cornerCurve = kCACornerCurveContinuous;
        }

        if (QMUICMIActivated) {
            self.backgroundColor = BadgeBackgroundColor;
            self.textColor = BadgeTextColor;
            self.font = BadgeFont;
            self.contentEdgeInsets = BadgeContentEdgeInsets;
        } else {
            self.backgroundColor = UIColorRed;
            self.textColor = UIColorWhite;
            self.font = UIFontBoldMake(11);
            self.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
        }
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.attributedText.length == 1) {
        NSMutableAttributedString *text = self.attributedText.mutableCopy;
        [text replaceCharactersInRange:NSMakeRange(0, 1) withString:@"8"];
        CGSize textSize = [text boundingRectWithSize:CGSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        CGSize result = CGSizeFlatted(CGSizeMake(textSize.width + UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), textSize.height + UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets)));
        result.width = MAX(result.width, result.height);
        result.height = result.width;
        return result;
    }
    CGSize result = [super sizeThatFits:size];
    return result;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

@end
