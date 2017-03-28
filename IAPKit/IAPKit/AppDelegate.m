//
//  AppDelegate.m
//  IAPKit
//
//  Created by 李礼光 on 2017/3/27.
//  Copyright © 2017年 李礼光. All rights reserved.
//

#import "AppDelegate.h"
#import "IAPManager.h"
@interface AppDelegate ()

@property (nonatomic, strong) IAPManager *iapManager;

@end

@implementation AppDelegate

- (IAPManager *)iapManager {
    return [IAPManager shareinstance];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.iapManager removeIAPObserver];
    [self.iapManager addIAPObserver];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //验证购买内容
    NSLog(@"程序激活");
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.iapManager removeIAPObserver];
}


@end
