//
//  IAPParam.h
//  IAPKit
//
//  Created by 李礼光 on 2017/3/27.
//  Copyright © 2017年 李礼光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
//内购参数
@interface IAPParam : NSObject

//这里的参数随自己决定,或者自己另外创建一个类
@property(copy,nonatomic)NSString *serverID;            // 游戏服ID
@property(copy,nonatomic)NSString *roleID;              // 游戏角色ID
@property(strong,nonatomic)SKProduct *product;          // 如果是第三方支付，则不需要传此参数
@property(copy,nonatomic)NSString *productID;           // 产品ID
@property(copy,nonatomic)NSString *extra;               // 支付成功时原样返回至游戏服务器的额外参数
@property(copy,nonatomic)NSString *orderID;             // 订单ID




@end
