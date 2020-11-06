//
//  TTNavigationController.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "TTNavigationController.h"

@interface TTNavigationController ()

@end

@implementation TTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UINavigationBar appearance].translucent = NO;
    // Do any additional setup after loading the view.
}


// 重写自定义的UINavigationController中的push方法: 处理tabbar的显示隐藏
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
     if (self.childViewControllers.count==1) {
         viewController.hidesBottomBarWhenPushed = YES;
     }
     [super pushViewController:viewController animated:animated];
}

@end
