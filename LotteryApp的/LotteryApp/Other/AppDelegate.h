//
//  AppDelegate.h
//  LotteryApp
//
//  Created by xin chen on 17/4/10.
//  Copyright © 2017年 涂怀安. All rights reserved.
//

#import <UIKit/UIKit.h>

#if kUseScreenShotGesture
#import "TamScreenShotView.h"
#endif

//static NSString *appKey = @"8ea7930a43ffbbc08ffb2cbb";//至尊极光推送key
//static NSString *appKey = @"cdaf73903d642f60342aa679";//福彩极光推送key
//static NSString *appKey = @"535c498bccc3edbe7fcbe106";//好彩头彩票极光推送key
//#define appKey = [DDDomainNameTool sharedInstance].HOSTURL

static NSString *channel = @"fir.im";//@"fir.im";//@"App Store";//发布渠道
static BOOL isProduction = TRUE;//TRUE;//FALSE;//是否为生产环境

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic,assign)BOOL isNeedUpdate;//是否需要更新
+ (AppDelegate* )shareAppDelegate;
@property (strong, nonatomic) UIWindow *window;

#if kUseScreenShotGesture
@property (nonatomic, strong)TamScreenShotView *screenshotView;
//重新设置rootViewConroller前需要调用
-(void)removeRootVc;
-(void)addRootVc;
#endif

@property(nonatomic,assign)BOOL isHaveBackVc;//是否返回的控制器中存在DDBuyLotteryDetailViewController

@end

