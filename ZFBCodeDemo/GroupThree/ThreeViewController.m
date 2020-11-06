//
//  ThreeViewController.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/11/6.
//

#import "ThreeViewController.h"

#import "ScanViewController.h"

@interface ThreeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ThreeViewController {
    CGFloat tempDistance;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"二维码扫描";
    // Do any additional setup after loading the view.
    if ([self getStatusRectAndNavRect] == 88) {
        tempDistance = 44 +44;
    }else{
        tempDistance = 20 +44;
    }
    [self.view addSubview:self.tableView];
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
            _tableView.scrollIndicatorInsets = _tableView.contentInset;
        }
        //[_tableView registerClass:[AmountViewCell class] forCellReuseIdentifier:ScanPayCELL0];
        //[_tableView registerNib:[UINib nibWithNibName:@"InputAmountViewCell" bundle:nil] forCellReuseIdentifier:CELLIDen1];
    }
    return _tableView;
}

#pragma mark 数据源  返回有几行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark 设置行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 77;
}

#pragma mark 每行显示内容
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"实现二维码扫描";
        cell.detailTextLabel.text = @"开源组件ZBar ~ iOS7前";
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"实现二维码扫描";
        cell.detailTextLabel.text = @"开源源组件ZXing ~ iOS7前";
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"实现二维码扫描";
        cell.detailTextLabel.text = @"原生的AVFoundation框架 ~ iOS7后";
    }
    return cell;
}

#pragma mark 选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 取消选中状态
    if (indexPath.row == 0) {
        
    }
    if (indexPath.row == 1) {
        
    }
    if (indexPath.row == 2) {
        // 参考文章:https://qa.1r1g.com/sf/ask/833385381/
        // 参考文章: https://www.jianshu.com/p/6a5824d3abb2
        // 参考文章:https://www.jianshu.com/p/dbe2fab0db9e?nomobile=yes
        ScanViewController *vc = [[ScanViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

