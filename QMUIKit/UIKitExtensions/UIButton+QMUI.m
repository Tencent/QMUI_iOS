/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIButton+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIButton+QMUI.h"
#import "QMUICore.h"

@interface UIButton ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary<NSAttributedStringKey, id> *> *qbt_titleAttributes;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableDictionary<NSNumber *, NSNumber *> *> * qbt_customizeButtonPropDict;

@end

@implementation UIButton (QMUI)

QMUISynthesizeIdStrongProperty(qbt_titleAttributes, setQbt_titleAttributes)
QMUISynthesizeIdStrongProperty(qbt_customizeButtonPropDict, setQbt_customizeButtonPropDict)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setTitle:forState:), NSString *, UIControlState, ^(UIButton *selfObject, NSString *title, UIControlState state) {
            [selfObject _markQMUICustomizeType:QMUICustomizeButtonPropTypeTitle forState:state value:title];
            
            if (!title || !selfObject.qbt_titleAttributes.count) {
                return;
            }
            
            if (state == UIControlStateNormal) {
                [selfObject.qbt_titleAttributes enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                    UIControlState state = [key unsignedIntegerValue];
                    NSString *titleForState = [selfObject titleForState:state];
                    NSAttributedString *string = [[NSAttributedString alloc] initWithString:titleForState attributes:obj];
                    [selfObject setAttributedTitle:[selfObject attributedStringWithEndKernRemoved:string] forState:state];
                }];
                return;
            }
            
            if ([selfObject.qbt_titleAttributes objectForKey:@(state)]) {
                NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:selfObject.qbt_titleAttributes[@(state)]];
                [selfObject setAttributedTitle:[selfObject attributedStringWithEndKernRemoved:string] forState:state];
                return;
            }
        });
        
        // 如果之前已经设置了此 state 下的文字颜色，则覆盖掉之前的颜色
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setTitleColor:forState:), UIColor *, UIControlState, ^(UIButton *selfObject, UIColor *color, UIControlState state) {
            [selfObject _markQMUICustomizeType:QMUICustomizeButtonPropTypeTitleColor forState:state value:color];
            
            NSDictionary *attributes = selfObject.qbt_titleAttributes[@(state)];
            if (attributes) {
                NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
                newAttributes[NSForegroundColorAttributeName] = color;
                [selfObject qmui_setTitleAttributes:[NSDictionary dictionaryWithDictionary:newAttributes] forState:state];
            }
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setTitleShadowColor:forState:), UIColor *, UIControlState, ^(UIButton *selfObject, UIColor *color, UIControlState state) {
            [selfObject _markQMUICustomizeType:QMUICustomizeButtonPropTypeTitleShadowColor forState:state value:color];
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setImage:forState:), UIImage *, UIControlState, ^(UIButton *selfObject, UIImage *image, UIControlState state) {
            [selfObject _markQMUICustomizeType:QMUICustomizeButtonPropTypeImage forState:state value:image];
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setBackgroundImage:forState:), UIImage *, UIControlState, ^(UIButton *selfObject, UIImage *image, UIControlState state) {
            [selfObject _markQMUICustomizeType:QMUICustomizeButtonPropTypeBackgroundImage forState:state value:image];
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UIButton class], @selector(setAttributedTitle:forState:), NSAttributedString *, UIControlState, ^(UIButton *selfObject, NSAttributedString *title, UIControlState state) {
            [selfObject _markQMUICustomizeType:QMUICustomizeButtonPropTypeAttributedTitle forState:state value:title];
        });
        
        if (@available(iOS 13, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UIButton class], @selector(layoutSubviews), ^(UIButton *selfObject) {
                // 临时解决 iOS 13 开启了粗体文本（Bold Text）导致 UIButton Title 显示不完整 https://github.com/Tencent/QMUI_iOS/issues/620
                if (UIAccessibilityIsBoldTextEnabled()) {
                    [selfObject.titleLabel sizeToFit];
                }
            });
        }
    });
}

- (instancetype)qmui_initWithImage:(UIImage *)image title:(NSString *)title {
    BeginIgnoreClangWarning(-Wunused-value)
    [self init];
    EndIgnoreClangWarning
    [self setImage:image forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateNormal];
    return self;
}

- (void)qmui_calculateHeightAfterSetAppearance {
    [self setTitle:@"测" forState:UIControlStateNormal];
    [self sizeToFit];
    [self setTitle:nil forState:UIControlStateNormal];
}

- (BOOL)qmui_hasCustomizedButtonPropForState:(UIControlState)state {
    if (self.qbt_customizeButtonPropDict) {
        return self.qbt_customizeButtonPropDict[@(state)].count > 0;
    }
    
    return NO;
}

- (BOOL)qmui_hasCustomizedButtonPropWithType:(QMUICustomizeButtonPropType)type forState:(UIControlState)state {
    if (self.qbt_customizeButtonPropDict && self.qbt_customizeButtonPropDict[@(state)]) {
        return [self.qbt_customizeButtonPropDict[@(state)][@(type)] boolValue];
    }
    
    return NO;
}

#pragma mark - Title Attributes

- (void)qmui_setTitleAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state {
    if (!attributes) {
        [self.qbt_titleAttributes removeObjectForKey:@(state)];
        [self setAttributedTitle:nil forState:state];
        return;
    }
    
    if (!self.qbt_titleAttributes) {
        self.qbt_titleAttributes = [NSMutableDictionary dictionary];
    }
    
    // 如果传入的 attributes 没有包含文字颜色，则使用用户之前通过 setTitleColor:forState: 方法设置的颜色
    if (![attributes objectForKey:NSForegroundColorAttributeName]) {
        NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        newAttributes[NSForegroundColorAttributeName] = [self titleColorForState:state];
        attributes = [NSDictionary dictionaryWithDictionary:newAttributes];
    }
    self.qbt_titleAttributes[@(state)] = attributes;
    
    // 确保调用此方法设置 attributes 之前已经通过 setTitle:forState: 设置的文字也能应用上新的 attributes
    NSString *originalText = [self titleForState:state];
    [self setTitle:originalText forState:state];
    
    // 一个系统的不好的特性（bug?）：如果你给 UIControlStateHighlighted（或者 normal 之外的任何 state）设置了包含 NSFont/NSKern/NSUnderlineAttributeName 之类的 attributedString ，但又仅用 setTitle:forState: 给 UIControlStateNormal 设置了普通的 string ，则按钮从 highlighted 切换回 normal 状态时，font 之类的属性依然会停留在 highlighted 时的状态
    // 为了解决这个问题，我们要确保一旦有 normal 之外的 state 通过设置 qbt_titleAttributes 属性而导致使用了 attributedString，则 normal 也必须使用 attributedString
    if (self.qbt_titleAttributes.count && !self.qbt_titleAttributes[@(UIControlStateNormal)]) {
        [self qmui_setTitleAttributes:@{} forState:UIControlStateNormal];
    }
}

// 去除最后一个字的 kern 效果
- (NSAttributedString *)attributedStringWithEndKernRemoved:(NSAttributedString *)string {
    if (!string || !string.length) {
        return string;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    [attributedString removeAttribute:NSKernAttributeName range:NSMakeRange(string.length - 1, 1)];
    return [[NSAttributedString alloc] initWithAttributedString:attributedString];
}

#pragma mark - customize state

- (void)_markQMUICustomizeType:(QMUICustomizeButtonPropType)type forState:(UIControlState)state value:(id)value {
    if (value) {
        [self _setQMUICustomizeType:type forState:state];
    } else {
        [self _removeQMUICustomizeType:type forState:state];
    }
}

- (void)_setQMUICustomizeType:(QMUICustomizeButtonPropType)type forState:(UIControlState)state {
    if (!self.qbt_customizeButtonPropDict) {
        self.qbt_customizeButtonPropDict = [NSMutableDictionary dictionary];
    }
    
    if (!self.qbt_customizeButtonPropDict[@(state)]) {
        self.qbt_customizeButtonPropDict[@(state)] = [NSMutableDictionary dictionary];
    }
    
    self.qbt_customizeButtonPropDict[@(state)][@(type)] = @(YES);
}

- (void)_removeQMUICustomizeType:(QMUICustomizeButtonPropType)type forState:(UIControlState)state {
    if (!self.qbt_customizeButtonPropDict || !self.qbt_customizeButtonPropDict[@(state)]) {
        return;
    }
    
    [self.qbt_customizeButtonPropDict[@(state)] removeObjectForKey:@(type)];
}

@end
