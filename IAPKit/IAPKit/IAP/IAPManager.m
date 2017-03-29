//
//  IAPManager.m
//  IAPKit
//
//  Created by 李礼光 on 2017/3/27.
//  Copyright © 2017年 李礼光. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "IAPManager.h"
#import "Order.h"

#import "MBProgressHUD.h"
#import "NSData+Base64.h"


#define isShowLog 1

#if isShowLog
    #define LGLog(format,...) {(NSLog)((format), ##__VA_ARGS__);}
#else
    #define LGLog(format,...) {}
#endif

#define ORDER_ID                @"orderId"
#define ORDER_AMOUNT            @"amount"
#define ORDER_RECEIPT           @"receipt"
#define ORDER_PRODUCT_ID        @"productId"
#define ORDER_LOCAL_TITLE       @"localTitle"
#define ORDER_LOCAL_DESC        @"localDescription"
#define ORDER_SERVER_ID         @"serverId"
#define ORDER_USER_ID           @"account"
#define ORDER_ROLE_ID           @"roleId"
#define ORDER_PRICE             @"price"
#define ORDER_EXTRA             @"extra"

@interface IAPManager()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (nonatomic, copy) queryComplete mCompletionResBlock;              //请求成功
@property (nonatomic, copy) queryError mErrorResBlock;                      //请求失败

@property (nonatomic, copy) paymentCompletion  mPaymentCompletionBlock;     //支付成功
@property (nonatomic, copy) paymentError mPaymentErrorBlock;                //支付失败
@property (nonatomic, copy) otherPaymentFinish mOtherPaymentFinishBlock;    //其他支付方式完成


@property (nonatomic, strong) UIView *hubView;      //蒙版
@property (nonatomic, strong) IAPParam *iapParam;   //内购参数

@end

@implementation IAPManager

+ (instancetype)shareinstance {
    static IAPManager *manager = nil;
    // 添加同步锁,一次只能一个线程访问,如果有多个线程访问,等待,一个访问结束后下一个访问
    @synchronized (self) {
        if (manager == nil) {
            manager = [[IAPManager alloc]init];
        }
    }
    return manager;
}
- (UIView *)hubView {
    if (_hubView == nil) {
        _hubView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _hubView.backgroundColor = [UIColor clearColor];
        return _hubView;
    }
    return _hubView;
}

- (IAPParam *)iapParam {
    if (!_iapParam) {
        _iapParam = [[IAPParam alloc]init];
        _iapParam.roleID = @"1";
        _iapParam.serverID = @"2";
        _iapParam.productID = @"3";
        _iapParam.extra = @"4";
    }
    return _iapParam;
}

#pragma mark - 添加和移除IAPObserver
//将此类设置为iAP observer职务
- (void)addIAPObserver {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

//将此类移除iAP observer职务
- (void)removeIAPObserver {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}




#pragma mark - 第一步:查询商品
- (void)queryProductsWithIds:(NSSet *)productIds
                       start:(void(^)())startBlock
          completionResponse:(queryComplete)completionBlock
               errorResponse:(queryError)errorBlock {
    
    startBlock();
    
    self.mCompletionResBlock = completionBlock;
    self.mErrorResBlock = errorBlock;
    
    //请求商品.请求成功后跳转到代理方法,代理方法执行block
    [self startRequestProduct:productIds];
    
    [self progressVShow];
}

//发起查询请求
- (void)startRequestProduct : (NSSet *)productIds {
    //开始向apple服务器请求 相关delegate请看SKProductsRequestDelegate
    SKProductsRequest *proRqt = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    proRqt.delegate = self;
    [proRqt start];
    //这里的请求就是苹果内购的请求了,实现代理方法,获得请求到数据之后的操作
}



#pragma mark - 内购请求代理
//接收到请求
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self progressVHide];

    if (response.products.count == 0) {
        LGLog(@"app后台没有找到对应的商品");
    } else {
        LGLog(@"app后台对应的商品:");
        [self showProductInfo:response];
        
        self.iapParam.product = [response.products lastObject];
        
        
        
        
        
        //执行购买
        [self makePaymentWithProductParam:_iapParam
                       completionResponse:^(NSString *items) {
                           
                       }otherPaymentFinish:^{
                           
                       }errorResponse:^(NSError *error) {
                                
                       }];
        
        
    }
    
};




//什么情况会到这里??? 无网络的状态.或其他(暂时没考虑到)
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    LGLog(@"-------弹出错误信息----------");

    if (self.mErrorResBlock) {
        self.mErrorResBlock(error);
    }
}

- (void)requestDidFinish:(SKRequest *)request{
    LGLog(@"----------反馈信息结束--------------");

};





#pragma mark - 请求购买(第二步)
- (void)makePaymentWithProductParam:(IAPParam *)proParam
                 completionResponse:(paymentCompletion)completionBlock
                 otherPaymentFinish:(otherPaymentFinish)finishBlock
                      errorResponse:(paymentError)errorBlock {
    
    //先判断内容参数是否正确
    
    
    if ([SKPaymentQueue canMakePayments]) {
        //向服务器请求orderID
        [self progressVShow];
        [self makePaymentWithProduct:proParam.product orderID: @"VS123111" ];
    };
    
    
    
    self.mOtherPaymentFinishBlock = finishBlock;
    self.mPaymentCompletionBlock = completionBlock;
    self.mPaymentErrorBlock = errorBlock;

    
    
    
}

//进入购买流程 通过storeKit向苹果服务器请求购买
- (void)makePaymentWithProduct:(SKProduct *)product orderID:(NSString *)orderId {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        payment.applicationUsername=orderId;
    }
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



//购买成功 进入向服务器验证流程
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSString *receipt = @"";
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        receipt = [[transaction transactionReceipt] base64EncodedStringWithSeparateLines:YES];
    }else {
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
        receipt= [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    // 发送receipt给本地服务器,验证有效性
    //  交易事务,收据凭证,产品信息
    NSString *productIdentifier = [[transaction payment] productIdentifier];
    [self validateTransaction:transaction receipt:receipt productIdentifier:productIdentifier];
}


//服务器验证
- (void)validateTransaction:(SKPaymentTransaction *)transaction receipt:(NSString *)receipt productIdentifier:(NSString *)productIdentifier {
    //具体需要服务器确认需要什么样的参数做判断.
}


#pragma mark - 购买代理方法
- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions  {
    LGLog(@"queue : %@",queue);
    LGLog(@"transactions : %@",transactions);
    
     for (SKPaymentTransaction *aTransaction in transactions) {
         
         SKPaymentTransactionState transactionState = aTransaction.transactionState;
         LGLog(@"completeTransaction : %ld", (long)transactionState);
         switch (transactionState) {
             case SKPaymentTransactionStatePurchasing: { // 购买中
                 LGLog(@"购买中....");
                 
             }
                 break;
             case SKPaymentTransactionStatePurchased: {  //购买成功,进入向服务器验证流程
                 [self progressVHide];
                 LGLog(@"购买成功 : %@",aTransaction.payment.productIdentifier);
                 [queue finishTransaction:aTransaction];//结束交易后调用代理方法 removedTransactions
                 
                 //购买成功 进入向服务器验证流程
                 //这里要考虑,当这里如果网络挂掉了,服务器并没有收到验证,那么用户直接将程序退出再进入的话,这里该怎么处理???最好将信息存在本地.
                 
                 [self completeTransaction:aTransaction];
                 
             }
                 break;
             case SKPaymentTransactionStateRestored: {   // 已购买,或者重新购买
                 LGLog(@"已购买");
                 [queue finishTransaction:aTransaction];
                 [self progressVHide];

             }
                 break;
             case SKPaymentTransactionStateFailed: { // 用户取消交易,或者交易失败
                 [queue finishTransaction:aTransaction];
                 LGLog(@"取消购买");
                 [self progressVHide];


             }
                 break;
             default:{LGLog(@"处理异常");[self progressVHide];}break;
         }

         
         
     }
    
}

- (void)handleErrorStatus:(NSInteger)errorCode { 
    NSError *error = [NSError errorWithDomain:@"payment error" code:errorCode userInfo:nil];
    if (self.mPaymentErrorBlock) {
        self.mPaymentErrorBlock(error);
    }
    if (self.mOtherPaymentFinishBlock) {
        self.mOtherPaymentFinishBlock();
    }
}


// 发送交易时从队列中删除(通过finishTransaction:)。
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    LGLog(@"11111111 : %s",__func__);
}

// 发送时遇到一个错误添加事务从用户的购买历史回到队列中。
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    LGLog(@"22222222 : %s",__func__);

}

// 发送所有事务时从用户的购买历史已经成功添加了回队列。
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    LGLog(@"33333333 : %s",__func__);

}

//当下载状态发生了变化调用。
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
    LGLog(@"44444444 : %s",__func__);

}









#pragma mark - 将支付信息缓存到本地

/*-----------------------------------------------------------------------
 
    这里面要存储什么本地内容要根据业务逻辑来确定,以下的内容很粗糙,
    可以忽略里面的代码逻辑,自己来处理,这里面得自己完善一下
 
 
 -----------------------------------------------------------------------*/
- (void)saveOrder:(Order *)order {
    @try {
        //获取字典
        NSMutableDictionary *dictionary = [self getDictionaryWithOrder:order];
        //将字典信息存储到偏好设置中
        [self saveOrderToUserDefault:[NSMutableDictionary dictionaryWithDictionary:dictionary]];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}


//将MVOrder转化为dictionary 以便储存到NSUserDefault
- (NSMutableDictionary *)getDictionaryWithOrder:(Order *)order {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    @try {
        LGLog(@"将订单信息保存在字典中");
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return dictionary;
}



//将支付信息缓存到本地 实现方法
- (void)saveOrderToUserDefault:(NSDictionary *)order {
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSArray *orderList=[userDefault objectForKey:@"list"];
    
    if (orderList==nil) {
        orderList=[[NSArray alloc] init];
    }
    
    if (orderList == nil) {
        orderList = [NSArray arrayWithObject:order];
        [userDefault setObject:orderList forKey:@"list"];
        [userDefault synchronize];
    }else {
        LGLog(@"做一些信息保存")
    };
}



#pragma mark - 验证本地缓存
- (void)verifyCacheOrderInventory {
    
}









#pragma mark - 其他方法
- (void)showProductInfo:(SKProductsResponse *)response{
    for (SKProduct *item in response.products) {
        LGLog(@"---------------------------------------------------");
        LGLog(@"product info");
        LGLog(@"  基本描述: %@", [item description]);
        LGLog(@"  IAP的id: %@", item.productIdentifier);
        LGLog(@"  地区编码: %@", item.priceLocale.localeIdentifier);
        LGLog(@"  本地价格: %@", item.price);
        LGLog(@"  语言代码: %@", [item.priceLocale objectForKey:NSLocaleLanguageCode]);
        LGLog(@"  国家代码: %@", [item.priceLocale objectForKey:NSLocaleCountryCode]);
        LGLog(@"  货币代码: %@", [item.priceLocale objectForKey:NSLocaleCurrencyCode]);
        LGLog(@"  货币符号: %@", [item.priceLocale objectForKey:NSLocaleCurrencySymbol]);
        LGLog(@"  本地标题: %@", item.localizedTitle);
        LGLog(@"  本地描述: %@", item.localizedDescription);
        LGLog(@"%@",item);
        LGLog(@"---------------------------------------------------");
    }
}




- (void)progressVShow {
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.hubView];
    [MBProgressHUD showHUDAddedTo:self.hubView animated:YES];
}

- (void)progressVHide {
    if ([_hubView superview]) {
        [MBProgressHUD hideHUDForView:_hubView animated:YES];
        [_hubView removeFromSuperview];
    }
}


- (NSDictionary *)modelToJSON:(id)model {
    IAPParam *param = (IAPParam *)model;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:param.roleID forKey:@"roleID"];
    [dic setObject:param.serverID forKey:@"serverID"];
    [dic setObject:param.product forKey:@"product"];
    [dic setObject:param.productID forKey:@"productID"];
    [dic setObject:param.extra forKey:@"extra"];

    return dic;
}








@end
