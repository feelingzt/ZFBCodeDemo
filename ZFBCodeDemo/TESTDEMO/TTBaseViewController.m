//
//  TTBaseViewController.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "TTBaseViewController.h"
#import "TTTabBarController.h"
#import "TTNavigationController.h"

@interface TTBaseViewController ()

@end

@implementation TTBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
 * 获取状态栏的高度+导航栏的高度
 * 带刘海屏幕返回44+44
 * 非刘海屏幕返回20+44
 */
- (CGFloat)getStatusRectAndNavRect{
    //获取状态栏的rect
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    //获取导航栏的rect
    //CGRect navRect = self.navigationController.navigationBar.frame;
    CGRect navRect = [[TTNavigationController alloc] init].navigationBar.frame;
    //导航栏+状态栏的高度
    CGFloat allHeight = statusRect.size.height+navRect.size.height;
    return allHeight;
}

/*
 * 获取底部TabBar的高度
 * 所有机型的TabBar高度都为49pt;
 * 包含HomeIndicator, TabBar高度增长为83pt;
 * 注意: 横屏时HomeIndicator的高度为21pt;
 */
- (CGFloat)getBottomTabBarHeightRect{
    // 这儿取你当前tabBarVC的实例
    UITabBarController *tabBarVC = [[UITabBarController alloc] init];
    //TTabBarController *tabBarVC = [[TTTabBarController alloc] init];
    
    CGFloat tabBarHeight = tabBarVC.tabBar.frame.size.height;
    
    NSLog(@"%f", tabBarHeight);// 固定49
    
    if ([self getStatusRectAndNavRect] == 88) {
        return tabBarHeight + 34;//83 非横屏
    } else if ([self getStatusRectAndNavRect] == 64) {
        return tabBarHeight;//49
    } else {
        return tabBarHeight;//49
    }
}


@end
