//
//  IAPManager.h
//  IAPKit
//
//  Created by 李礼光 on 2017/3/27.
//  Copyright © 2017年 李礼光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPParam.h"

//关于请求商品
typedef void (^queryComplete)(NSArray *);           //请求成功
typedef void (^queryError)(NSError *);              //请求失败

//关于购买商品
typedef void (^paymentCompletion)(NSString *);         //购买成功
typedef void (^paymentError)(NSError *);               //购买失败
typedef void (^otherPaymentFinish)();                  //其他购买方式



@interface IAPManager : NSObject

+ (instancetype)shareinstance;


#pragma mark -Public Interfaces For iAP
/**
 *  @abstract   建议在app启动时候调用
 */
- (void)addIAPObserver;

/**
 *  @abstract   建议在app结束运行的时候调用
 */
- (void)removeIAPObserver;


/**
 *  @abstract   向app后台请求商品
 *
 *  @param productIds      app后台设置的内购商品
 *  @param startBlock      开始请求时回调
 *  @param completionBlock 请求成功时回调
 *  @param errorBlock      错误处理
 */
- (void)queryProductsWithIds:(NSSet *)productIds
                       start:(void(^)())startBlock
          completionResponse:(queryComplete)completionBlock
               errorResponse:(queryError)errorBlock;

/**
 *  @abstract  购买产品
 *
 *  @param proParam        产品的相关信息. 包括: 服务器id, 角色id, 用户id, 商品的额外信息等..
 *  @param completionBlock 购买成功时回调
 *  @param finishBlock     其他购买操作
 *  @param errorBlock      购买失败时回调
 */
- (void)makePaymentWithProductParam:(IAPParam *)proParam
                 completionResponse:(paymentCompletion)completionBlock
                 otherPaymentFinish:(otherPaymentFinish)finishBlock
                      errorResponse:(paymentError)errorBlock;


/**
 *  @abstract   验证本地订单.
 *
 *  @note   你可以在AppDelegate的这个代理方法中调用: - (void)applicationDidBecomeActive:(UIApplication *)application
 *  考虑点:当内购完成后,AppStore返回一个交易事务,这个时候发送给服务器,通知服务器发货,当出现网络异常的时候,这里可以验证本地的订单信息.
 *  如果有收据凭证,那么通知服务器.补发商品
 */
- (void)verifyCacheOrderInventory;




/**
 *  @abstract请求
 *
 *  @param productIds 商品参数
 */
- (void)startRequestProduct : (NSSet *)productIds ;

@end
