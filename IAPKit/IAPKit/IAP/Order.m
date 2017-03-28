
//
//  Order.m
//  IAPKit
//
//  Created by 李礼光 on 2017/3/28.
//  Copyright © 2017年 李礼光. All rights reserved.
//

#import "Order.h"

@implementation Order
-(id)initWithDict:(NSDictionary *)dict
{
    self=[super init];
    if (self) {
        @try {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                if ([[dict allKeys] containsObject:@"code"]) {
                    self.code=[dict objectForKey:@"code"];
                }
                if ([[dict allKeys] containsObject:@"orderId"]) {
                    self.orderId=[dict objectForKey:@"orderId"];
                }
                if ([[dict allKeys] containsObject:@"payType"]) {
                    self.payType=[dict objectForKey:@"payType"];
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

@end
