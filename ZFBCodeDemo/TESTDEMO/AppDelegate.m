//
//  AppDelegate.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "AppDelegate.h"
#import "TTTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    /*
     * UIWindow * window = [[UIApplication sharedApplication].delegate window];
     * window.rootViewController = [[TTTabBarController alloc] init];
     */
    
    TTTabBarController *tabbarc = [[TTTabBarController alloc] init];
    self.window.rootViewController = tabbarc;
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end
