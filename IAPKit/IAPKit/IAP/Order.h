//
//  Order.h
//  IAPKit
//
//  Created by 李礼光 on 2017/3/28.
//  Copyright © 2017年 李礼光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPParam.h"
//订单信息
@interface Order : NSObject
@property(nonatomic,copy)NSString *orderId;
@property(nonatomic,strong)NSNumber *code;
@property(nonatomic,strong)NSNumber *payType;
@property(nonatomic,strong)IAPParam *payParam;
@property(nonatomic,copy)NSString *receipt;
@property(nonatomic,copy)NSString *transactionIdentifier;

-(id)initWithDict:(NSDictionary *)dict;
@end
