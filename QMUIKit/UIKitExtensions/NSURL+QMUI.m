//
//  NSURL+QMUI.m
//  QMUIKit
//
//  Created by TQ on 2018/11/11.
//  Copyright © 2018 QMUI Team. All rights reserved.
//

#import "NSURL+QMUI.h"

@implementation NSURL (QMUI)

- (NSDictionary<NSString *, NSString *> *)qmui_queryItems {
    if (!self.absoluteString.length) {
        return nil;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:self.absoluteString];
    
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name) {
            [params setObject:obj.value ?: [NSNull null] forKey:obj.name];
        }
    }];
    return [params copy];
}

@end
