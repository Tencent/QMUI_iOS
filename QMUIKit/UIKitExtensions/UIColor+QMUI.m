//
//  UIColor+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UIColor+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "NSString+QMUI.h"

@implementation UIColor (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 使用[UIColor colorWithRed:green:blue:alpha:]方法创建的颜色，都是UIDeviceRGBColor类型的而不是UIColor类型的，所以要重写这个class
        ReplaceMethod(NSClassFromString(@"UIDeviceRGBColor"), @selector(description), @selector(qmui_description));
    });
}

- (NSString *)qmui_description {
    NSInteger red = self.red * 255;
    NSInteger green = self.green * 255;
    NSInteger blue = self.blue * 255;
    CGFloat alpha = self.alpha;
    NSString *description = [NSString stringWithFormat:@"color = RGBA: (%@, %@, %@, %.2f), AARRGGBB: %@", @(red), @(green), @(blue), alpha, [self hexString]];
    return description;
}

+ (UIColor *)colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

- (NSString *)hexString {
    NSInteger alpha = self.alpha * 255;
    NSInteger red = self.red * 255;
    NSInteger green = self.green * 255;
    NSInteger blue = self.blue * 255;
    return [[NSString stringWithFormat:@"#%@%@%@%@",
            [self alignColorHexStringLength:[NSString hexStringWithInteger:alpha]],
            [self alignColorHexStringLength:[NSString hexStringWithInteger:red]],
            [self alignColorHexStringLength:[NSString hexStringWithInteger:green]],
            [self alignColorHexStringLength:[NSString hexStringWithInteger:blue]]] lowercaseString];
}

// 对于色值只有单位数的，在前面补一个0，例如“F”会补齐为“0F”
- (NSString *)alignColorHexStringLength:(NSString *)hexString {
    return hexString.length < 2 ? [@"0" stringByAppendingString:hexString] : hexString;
}

+ (CGFloat)colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

- (CGFloat)red {
    CGFloat r;
    if ([self getRed:&r green:0 blue:0 alpha:0]) {
        return r;
    }
    return 0;
}

- (CGFloat)green {
    CGFloat g;
    if ([self getRed:0 green:&g blue:0 alpha:0]) {
        return g;
    }
    return 0;
}

- (CGFloat)blue {
    CGFloat b;
    if ([self getRed:0 green:0 blue:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (CGFloat)alpha {
    CGFloat a;
    if ([self getRed:0 green:0 blue:0 alpha:&a]) {
        return a;
    }
    return 0;
}

- (CGFloat)hue {
    CGFloat h;
    if ([self getHue:&h saturation:0 brightness:0 alpha:0]) {
        return h;
    }
    return 0;
}

- (CGFloat)saturation {
    CGFloat s;
    if ([self getHue:0 saturation:&s brightness:0 alpha:0]) {
        return s;
    }
    return 0;
}

- (CGFloat)brightness {
    CGFloat b;
    if ([self getHue:0 saturation:0 brightness:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (UIColor *)colorWithoutAlpha {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    if ([self getRed:&r green:&g blue:&b alpha:0]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
    } else {
        return nil;
    }
}

- (UIColor *)colorWithAlpha:(CGFloat)alpha backgroundColor:(UIColor *)backgroundColor {
    return [UIColor colorWithBackendColor:backgroundColor frontColor:[self colorWithAlphaComponent:alpha]];
    
}

- (UIColor *)colorWithAlphaAddedToWhite:(CGFloat)alpha {
    return [self colorWithAlpha:alpha backgroundColor:UIColorWhite];
}

- (UIColor *)transitionToColor:(UIColor *)toColor progress:(CGFloat)progress {
    return [UIColor colorFromColor:self toColor:toColor progress:progress];
}

+ (UIColor *)colorWithBackendColor:(UIColor *)backendColor frontColor:(UIColor *)frontColor {
    CGFloat bgAlpha = [backendColor alpha];
    CGFloat bgRed = [backendColor red];
    CGFloat bgGreen = [backendColor green];
    CGFloat bgBlue = [backendColor blue];
    
    CGFloat frAlpha = [frontColor alpha];
    CGFloat frRed = [frontColor red];
    CGFloat frGreen = [frontColor green];
    CGFloat frBlue = [frontColor blue];
    
    CGFloat resultAlpha = frAlpha + bgAlpha * (1 - frAlpha);
    CGFloat resultRed = (frRed * frAlpha + bgRed * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultGreen = (frGreen * frAlpha + bgGreen * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultBlue = (frBlue * frAlpha + bgBlue * bgAlpha * (1 - frAlpha)) / resultAlpha;
    return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:resultAlpha];
}

+ (UIColor *)colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress {
    progress = MIN(progress, 1.0f);
    CGFloat fromRed = fromColor.red;
    CGFloat fromGreen = fromColor.green;
    CGFloat fromBlue = fromColor.blue;
    CGFloat fromAlpha = fromColor.alpha;
    
    CGFloat toRed = toColor.red;
    CGFloat toGreen = toColor.green;
    CGFloat toBlue = toColor.blue;
    CGFloat toAlpha = toColor.alpha;
    
    CGFloat finalRed = fromRed + (toRed - fromRed) * progress;
    CGFloat finalGreen = fromGreen + (toGreen - fromGreen) * progress;
    CGFloat finalBlue = fromBlue + (toBlue - fromBlue) * progress;
    CGFloat finalAlpha = fromAlpha + (toAlpha - fromAlpha) * progress;
    
    return [UIColor colorWithRed:finalRed green:finalGreen blue:finalBlue alpha:finalAlpha];
}

+ (UIColor *)randomColor {
    CGFloat red = ( arc4random() % 255 / 255.0 );
    CGFloat green = ( arc4random() % 255 / 255.0 );
    CGFloat blue = ( arc4random() % 255 / 255.0 );
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (BOOL)colorIsDark {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    float referenceValue = 0.411;
    float colorDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));
    
    return 1.0 - colorDelta > referenceValue;
}

- (UIColor *)inverseColor {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                               green:(1.0 - componentColors[1])
                                                blue:(1.0 - componentColors[2])
                                               alpha:componentColors[3]];
    return newColor;
}

@end
