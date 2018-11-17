//
//  AppDelegate.m
//  LotteryApp
//
//  Created by xin chen on 17/4/10.
//  Copyright © 2017年 涂怀安. All rights reserved.
//

#import "AppDelegate.h"
#import "DDApnsModel.h"
#import "DDConfigViewController.h"
#import "IQKeyboardManager.h"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "DDWeixinCallback.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "DDXinLangCallBack.h"
#import <JSPatchPlatform/JSPatch.h>
#import "Sentry.h"
#import <Hyphenate/Hyphenate.h>

//#define JSPatchAPPKey @"5980fc7996687086" //至尊彩票热更新APPKEY

//#define JSPatchKey @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCZLrtn35nI6X8XzmXFnnkg9Tmq\nNTME+0bKUoX/zUnW2Qdd5f9hLM8wSjJ9Fd7Fx0pZG+QCdHxSj3s/bQepfS5uGFip\nZrMQRHbj9IgJ/B2M42nc1zakF5iD9D0nSQCwhQK/0qC1yichemDdDb/tJst4GDZh\nAJYzc2wXLhJcjnzbZwIDAQAB\n-----END PUBLIC KEY-----" //至尊热更新key


//#define JSPatchAPPKey @"e1080936d6746f68" //福彩彩票热更新APPKEY

//#define JSPatchKey @"-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDMLdnv72g0XR8Y6kxKSANhVWEIsbo8FuwRUjCex7rMT/rQBU+yntwHGYBVuqjI6sLgKwkrKtMid7a6LAbih7E/kDGwVM5GC3UyEvRnXHiDiAj/8OcO1lQ6eSK7oAAgCufCOkHUZdX7lHwFkTIYItBVXEJm1GC8W/eueekIrPqYkQIDAQAB-----END PUBLIC KEY-----" //福彩热更新key

//#define JSPatchAPPKey @"6cb05ae5f062833d" //好彩头彩票热更新APPKEY
//
#define _JSPatchKey @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDXRSBZUi6DtPsNX5VyiuWoh864\nf12w21NJUGcX3kny03ejKYcgJ4yPt8k5bd9bn0fBM0abAesXP4Z3/0GT6Pb62TNq\noaSdC0CNvduf9DavTorLK4QECw0NcQ60rrjON9k9IrkAn/vT4A4BhmdfNwom1nFa\nMqDq3caBoZPBgFfvVwIDAQAB\n-----END PUBLIC KEY-----" //好彩头彩票热更新key

@interface AppDelegate ()<JPUSHRegisterDelegate>


@property(nonatomic,assign)BOOL isResetApp;//重新打开app

@end

@implementation AppDelegate

+ (AppDelegate* )shareAppDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //热更新
    [JSPatch startWithAppKey:[DDDomainNameTool sharedInstance].JSPatchAPPKey];
    [JSPatch setupRSAPublicKey:[DDDomainNameTool sharedInstance].JSPatchKey];
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = YES;
    manager.toolbarDoneBarButtonItemText = @"完成";
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];

    //清除缓存
    [DDCommTool clearCache];
    //显示状态栏
    [application setStatusBarHidden:NO];

    //获取配置信息
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [DDCommTool requestServiceInfoInView:nil success:^{
//
//        } fail:^{
//
//        }];
//    });
    
    NSError *error = nil;
    SentryClient *client = [[SentryClient alloc] initWithDsn:@"https://fd67b3110bc04e45be0d1115967cb999@sentry.hctmalls.com/3" didFailWithError:&error];
    SentryClient.sharedClient = client;
    [SentryClient.sharedClient startCrashHandlerWithError:&error];
    if (nil != error) {
        DDLog(@"%@", error);
    }
//    [self badNext];
    if (![NSString isEmpty:GetUserName] && [NSString isEmpty:GetReturn_ratio_rate]) {//登录状态 无返点时 默认设置为1
        SetReturn_ratio_rate(@"1");
    }
    
    //主视图
//    TamTabBarController *tabBarController = [[TamTabBarController alloc]init];
//    TamNavigationController *nav = [[TamNavigationController alloc]initWithRootViewController:tabBarController];
//    nav.navigationBarHidden = YES;
//    self.window.rootViewController = nav;
    DDConfigViewController *configViewController = [[DDConfigViewController alloc]init];
    TamNavigationController *_nav = [[TamNavigationController alloc]initWithRootViewController:configViewController];
    self.window.rootViewController = _nav;
    //截图
#if kUseScreenShotGesture
    self.screenshotView = [[TamScreenShotView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [self.window insertSubview:self.screenshotView atIndex:0];
    self.screenshotView.hidden = YES;
#endif
    
    //判断是否第一次进入并且处理事件
    if (![DDUserDefault boolForKey:DDAppNOFirst]) {//第一次进入app
        SetJGregistrationID(@"");//设置极光注册id为空
        [DDUserDefault setBool:YES forKey:DDAppNOFirst];
        [DDUserDefault setBool:YES forKey:IsOpenShakeAudio];//默认开启摇一摇声音
        SetLot_result_switch(1);
        [application setApplicationIconBadgeNumber:0];
        [JPUSHService setBadge:0];
    }
    
    
    EMOptions *options = [EMOptions optionsWithAppkey:@"1104181015177658#app1"];
    options.apnsCertName = @"istore_dev";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
//    //检查是否更新版本
//    [DDCommTool checkAppVersionWithView:nil complete:^(BOOL isNeedUpdate) {
//        self.isNeedUpdate = isNeedUpdate;
//    }];
//    //注册微信
//    if ([WXApi registerApp:WXAPPId]) {
//        DDLog(@"微信注册成功");
//    }else{
//        DDLog(@"微信注册失败");
//    }
//    //注册新浪微博
//    [WeiboSDK enableDebugMode:YES];
//    if ([WeiboSDK registerApp:XinLangAppKey]) {
//        DDLog(@"新浪微博注册成功");
//    }else{
//        DDLog(@"新浪微博注册失败");
//    }
    //-----------------------以下为推送设置--------------------------------
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    
    [JPUSHService setupWithOption:launchOptions appKey:[DDDomainNameTool sharedInstance].appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    //极光监听
    if ([NSString isEmpty:GetJGregistrationID]) {
        [[DDJGTool shareInstance] jiGuangNoti];
    }
    if ([NSString isEmpty:GetToken] == NO) {
        [self getChatRoomNetWork];

    }
    return YES;
}

- (void)getChatRoomNetWork{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSString *deviceNo = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if ([APP_Name isEqualToString:@"至尊彩票"]) {
        
        params[@"from_app"] = @"ZZCP";
    } else if ([APP_Name isEqualToString:@"CK彩票"]) {
        params[@"from_app"] = @"FCCP";
    } else if ([APP_Name isEqualToString:@"好彩头彩票"]) {
        params[@"from_app"] = @"CP57";
    } else if ([APP_Name containsString:@"测试"]) {
        params[@"from_app"] = @"CPTEST";
        
    }
    params[@"device_no"] = [NSString stringWithFormat:@"%@",deviceNo];
    [DDHttpTool get:GetHxUserURL params:params isToken:YES MBInView:nil isErrorAlert:NO viewController:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableDictionary *json = [DDCommTool removeTime_consumedWithJson:responseObject];
        if ([json[@"status"] intValue] == 1) {
            NSDictionary *dataDict = json[@"data"];
            NSDictionary *userDict = dataDict[@"user"];
            SetHxUserName(userDict[@"username"]);
            SetHxPassWord(userDict[@"password"]);
            SetChatRoomId(userDict[@"room_id"]);
            SetChatUserLevelId(userDict[@"isChatLimit"]);
            SetChatUserLevelType(userDict[@"levelType"]);
            NSNumber  *guest =  userDict[@"is_guest"];
            
            //            if (guest.intValue == 1) {
            //                SetChatUserLevelName(userDict[@"nickname"]);
            //            }else{
            //
            //            }
            SetChatUserIsSilent(userDict[@"is_silent"]);
            [[EMClient sharedClient] loginWithUsername:GetHxUserName
                                              password:GetHxPassWord
                                            completion:^(NSString *aUsername, EMError *aError) {
                                                if (!aError) {
                                                    NSLog(@"登录成功");
                                                } else {
                                                    NSLog(@"登录失败");
                                                }
                                            }];
            
            
        }else{
            
        }
        
    } fail:^(NSURLSessionDataTask *task, id responseObject) {
        
        
    } tokenFail:^(BOOL isExpire){
        
    }];
}



- (void)badNext{
    
    [SentryClient.sharedClient crash];
    
    @throw [NSException exceptionWithName:@"627test"
                                                           reason:@"you don’t really want to known"
                                                         userInfo:nil];
    
    NSArray * ar = @[@1,@2];
    NSNumber * aa  = ar[4];
}
-(void)removeRootVc
{
#if kUseScreenShotGesture
    [self.screenshotView removeObs];
#endif
}

-(void)addRootVc
{
#if kUseScreenShotGesture
    [self.screenshotView addObs];
#endif
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    DDLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support 前台获取信息
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
//    [self setBadgeWithContent:content];
    
    DDLog(@"获取的信息willPresentNotification:%@",userInfo);
//    ,notification.request.content
//    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *body = content.body;    // 推送消息体 == userInfo[@"aps"][@"alert"]
//    NSString *subtitle = content.subtitle;  // 推送消息的副标题
//    NSString *title = content.title;  // 推送消息的标题
//    DDLog(@"获取的信息willPresentNotification:%@\n%@",badge,body);
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
// 前端显示
//    if (self.isNeedUpdate && [DDCommTool currentIsCanWeb] && ([GetTheUpdate_type intValue] == 1)){//强制更新app时
//        completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionBadge); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
//    }else{
    //不提示数字 告诉服务器设置为当前显示的
    /*下面为app内显示
     */
    completionHandler(UNNotificationPresentationOptionSound);
    NSInteger IconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [JPUSHService setBadge:IconBadgeNumber];
    
//    [DDStatusBarAlertView showMessage:body touchEventBlock:^{
//        [DDCommTool clickPushNotiTellServerWithP_id:userInfo[@"p_id"] p_t:userInfo[@"p_t"]];
//        [DDApnsModel apsnManagerWithJump:userInfo[@"jump"]];
//    }];
    [DDNavAlertView showMessage:body touchEventBlock:^{
        [DDCommTool clickPushNotiTellServerWithP_id:userInfo[@"p_id"] p_t:userInfo[@"p_t"]];
        [DDApnsModel apsnManagerWithJump:userInfo[@"jump"]];
    }];
}

//-(void)resetBageNumber{
//    UILocalNotification *clearEpisodeNotification = [[UILocalNotification alloc] init];
//    clearEpisodeNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(1*1)];
//    clearEpisodeNotification.timeZone = [NSTimeZone defaultTimeZone];
//    clearEpisodeNotification.applicationIconBadgeNumber = -1;
//    [[UIApplication sharedApplication] scheduleLocalNotification:clearEpisodeNotification];
//    
//}

// iOS 10 Support 后台获取信息 点击系统通知界面
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationContent *content = response.notification.request.content;
    DDLog(@"获取的信息didReceiveNotificationResponse:%@",userInfo);
//    [self setBadgeWithContent:content];
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
//        //每点击一条桌面图标减一 并且告诉服务器
//        NSInteger IconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
//        if (IconBadgeNumber > 0) {
//            IconBadgeNumber--;
//            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:IconBadgeNumber];
//            [JPUSHService setBadge:IconBadgeNumber];
//        }else{
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [JPUSHService setBadge:0];
//        }

        [DDCommTool clickPushNotiTellServerWithP_id:userInfo[@"p_id"] p_t:userInfo[@"p_t"]];
        [DDApnsModel apsnManagerWithJump:userInfo[@"jump"]];
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

//处理用户自己删除通知栏【失败】
-(void)setBadgeWithContent:(UNNotificationContent *)content
{
//    NSNumber *badge = content.badge;  // 推送消息的角标
//    NSInteger IconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;//本地的badge
//    DDLog(@"本地图标数量:%ld,网络:%@",IconBadgeNumber,badge);
//    NSInteger badgeM = [badge intValue]-IconBadgeNumber;
//    if (badgeM > 2) {//如果大于2[一般是比前一个通知多1个]
//        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeM];
//        [JPUSHService setBadge:badgeM];
//    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self commManagePushInfoWithApplication:application notification:userInfo];
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self commManagePushInfoWithApplication:application notification:userInfo];
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}

/**
 *  ios10之前处理信息
 */
-(void)commManagePushInfoWithApplication:(UIApplication *)application notification:(NSDictionary *)userInfo
{
    if ([[UIDevice currentDevice].systemVersion intValue] < 10.0) {
        // 应用在前台
        if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
//            [DDStatusBarAlertView showMessage:userInfo[@"aps"][@"alert"] touchEventBlock:^{
//                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//                [JPUSHService setBadge:0];
//                
//                [DDCommTool clickPushNotiTellServerWithP_id:userInfo[@"p_id"] p_t:userInfo[@"p_t"]];
//                [DDApnsModel apsnManagerWithJump:userInfo[@"jump"]];
//            }];
            
            [DDNavAlertView showMessage:userInfo[@"aps"][@"alert"] touchEventBlock:^{
                
                [DDCommTool clickPushNotiTellServerWithP_id:userInfo[@"p_id"] p_t:userInfo[@"p_t"]];
                [DDApnsModel apsnManagerWithJump:userInfo[@"jump"]];
            }];
            
        }else{
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [JPUSHService setBadge:0];
            
            [DDCommTool clickPushNotiTellServerWithP_id:userInfo[@"p_id"] p_t:userInfo[@"p_t"]];
            [DDApnsModel apsnManagerWithJump:userInfo[@"jump"]];
        }
            
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.window endEditing:YES];
}



-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *string =[url absoluteString];
    DDLog(@"handleOpenURL:%@",string);
    if([string hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:[DDWeixinCallback shareInstance]];
    }else if([string hasPrefix:@"ten"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if ([string hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:[DDXinLangCallBack shareInstance]];
    }
    return YES;
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *string =[url absoluteString];
    DDLog(@"sourceApplication:%@",string);
    if([string hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:[DDWeixinCallback shareInstance]];
    }else if([string hasPrefix:@"ten"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if ([string hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:[DDXinLangCallBack shareInstance]];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [DDLotteryTool shareInstance].isCanRequestData = NO;
    [[EMClient sharedClient] applicationDidEnterBackground:application];

    // 开启后台任务,让程序保持运行状态
    [application beginBackgroundTaskWithExpirationHandler:nil];

    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[EMClient sharedClient] applicationWillEnterForeground:application];
    [DDLotteryTool shareInstance].isCanRequestData = YES;

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [JPUSHService setBadge:0];
//    [application setApplicationIconBadgeNumber:0];
//    [application cancelAllLocalNotifications];
    
    //JSPatch补丁
#ifdef DEBUG
    [JSPatch setupDevelopment];
#endif
    [JSPatch sync];
    
    if (self.isNeedUpdate && [DDCommTool currentIsCanWeb]) {
        if ([GetTheUpdate_type intValue] == 1){//强制更新才需要
            [TamAlertView dismissAlertView];
            TamAlertView *alertView = [TamAlertView showAlertViewWithTitle:[NSString stringWithFormat:@"版本更新提示(v%@)",GetTheNewestVersion] content:GetTheDescription cancel:NULL sure:@"立即更新" animaType:0 cancelAction:^{
                
            } sureAction:^{
                [DDCommTool pushSystemApp:GetTheLink];
            }];
            [alertView.sureBtn setTitleColor:MYColor_whiteTheme forState:UIControlStateNormal];
            alertView.sureBtn.backgroundColor = MYColor_MainTheme;

        }
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DDLog(@"APP内存警告");
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
