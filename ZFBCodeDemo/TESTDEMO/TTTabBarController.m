//
//  TTTabBarController.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "TTTabBarController.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "TTNavigationController.h"

@interface TTTabBarController ()

@end

@implementation TTTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.barTintColor = UIColorFromRGB(0xf7f7f7);
    
    // Do any additional setup after loading the view.
    
    OneViewController *vc1 = [[OneViewController alloc] init];
    [self addChildViewController:vc1 title:@"界面1" imageName:@"haoyou" selectedImageName:@"haoyou_a"];
    
    TwoViewController *vc2 = [[TwoViewController alloc] init];
    [self addChildViewController:vc2 title:@"界面2" imageName:@"faxian" selectedImageName:@"faxian_a"];
    
    ThreeViewController *vc3 = [[ThreeViewController alloc] init];
    [self addChildViewController:vc3 title:@"界面3" imageName:@"faxian" selectedImageName:@"faxian_a"];
}

- (void)addChildViewController:(UIViewController *)childViewController
                         title:(NSString *)title
                     imageName:(NSString *)imageName
             selectedImageName:(NSString *)selectedImageName
{
    childViewController.tabBarItem.title = title;
    
    childViewController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
    
    childViewController.tabBarItem.image = [[UIImage imageNamed:imageName]
                                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    childViewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName]
                                                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    NSDictionary *attributesDicNormal = @{NSForegroundColorAttributeName : UIColorFromRGB(0x929292),
                          NSFontAttributeName : [UIFont systemFontOfSize:10.0]};
    [childViewController.tabBarItem setTitleTextAttributes:attributesDicNormal forState:UIControlStateNormal];
    
    NSDictionary *attributesDicSelected = @{NSForegroundColorAttributeName : UIColorFromRGB(0x00aff0),
                          NSFontAttributeName : [UIFont systemFontOfSize:10.0]};
    [childViewController.tabBarItem setTitleTextAttributes:attributesDicSelected forState:UIControlStateSelected];
    
    // 创建一个导航控制器
    TTNavigationController * nvc = [[TTNavigationController alloc] initWithRootViewController:childViewController];
    
    // 添加 子控制器
    [self addChildViewController:nvc];
}


@end
