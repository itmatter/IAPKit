//
//  ViewController.m
//  IAPKit
//
//  Created by 李礼光 on 2017/3/27.
//  Copyright © 2017年 李礼光. All rights reserved.
//

#import "ViewController.h"
#import "IAPManager.h"



@interface ViewController ()


@property (nonatomic, strong) IAPManager *iapManager;

@end


static const NSString *coin10  = @"coin10";
static const NSString *coin200 = @"coin200";

@implementation ViewController
- (IAPManager *)iapManager {
    return [IAPManager shareinstance];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (IBAction)coin10:(id)sender {
    [self purchaseSomeThing:10];
}

- (IBAction)coin200:(id)sender {
    [self purchaseSomeThing:200];
}



/*
 内购逻辑:
 
 向appStore服务器查询商品(内购商品)
        |-- 查询失败
        |-- 查询成功
                |-- 实现购买
                        |-- 购买失败
                        |-- 购买成功
                                |-- 将购买凭证发送至服务器
                                            |-- 购买结束
 
 
 
 */

- (void)purchaseSomeThing:(NSInteger)coin{
    NSSet *products;
    if (coin == 10) {
        products = [NSSet setWithObjects:coin10, nil];  //消耗型项目
    } else {
        products = [NSSet setWithObjects:coin200, nil]; //非消耗型项目
    }
    [self.iapManager queryProductsWithIds:products
                                    start:^{
                                        NSLog(@"查询商品");
                                    } completionResponse:^(NSArray *items) {
                                        NSLog(@"查询成功");
                                        if (items.count == 0) {return;}
                                        
                                        IAPParam *param = [self setupParam:items];

                                        [self.iapManager makePaymentWithProductParam:param
                                                                  completionResponse:^(NSString *response) {
                                                                      NSLog(@"完成购买");
                                                                      
                                                                  } otherPaymentFinish:^{
                                                                      NSLog(@"取消了购买");
                                                                      
                                                                  } errorResponse:^(NSError *error) {
                                                                      NSLog(@"完成失败");

                                                                  }];
                                        
                                        
                                    } errorResponse:^(NSError *error) {
                                        NSLog(@"查询失败 error = %@ ", error);
                                    }];
}

- (IAPParam *)setupParam : (NSArray *)items {
    //购买
    IAPParam *param = [[IAPParam alloc]init];
    param.extra = @"";
    param.roleID = @"";
    param.serverID = @"";
    param.productID = @"";
    param.product = [items lastObject];
    return param;
}

@end
