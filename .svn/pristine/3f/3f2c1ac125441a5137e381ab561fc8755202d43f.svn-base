//
//  NSAttributedString+QMUI.m
//  qmui
//
//  Created by MoLice on 16/9/23.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "NSAttributedString+QMUI.h"
#import "QMUICommonDefines.h"
#import "NSString+QMUI.h"

@implementation NSAttributedString (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        ReplaceMethod([[[NSAttributedString alloc] initWithString:@""] class], @selector(initWithString:), @selector(qmui_initWithString:));
        ReplaceMethod([[[NSAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), @selector(qmui_initWithString:attributes:));
    });
}

- (instancetype)qmui_initWithString:(NSString *)str {
    str = str ?: @"";
    return [self qmui_initWithString:str];
}

- (instancetype)qmui_initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    str = str ?: @"";
    return [self qmui_initWithString:str attributes:attrs];
}

- (NSUInteger)qmui_lengthWhenCountingNonASCIICharacterAsTwo {
    return self.string.qmui_lengthWhenCountingNonASCIICharacterAsTwo;
}

@end

@implementation NSMutableAttributedString (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        ReplaceMethod([[[NSMutableAttributedString alloc] initWithString:@""] class], @selector(initWithString:), @selector(qmui_initWithString:));
        ReplaceMethod([[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), @selector(qmui_initWithString:attributes:));
    });
}

- (instancetype)qmui_initWithString:(NSString *)str {
    str = str ?: @"";
    return [self qmui_initWithString:str];
}

- (instancetype)qmui_initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    str = str ?: @"";
    return [self qmui_initWithString:str attributes:attrs];
}

@end
