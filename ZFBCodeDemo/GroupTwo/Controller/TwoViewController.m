//
//  TwoViewController.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "TwoViewController.h"
#import "TwoViewCell.h"
#import "BottomPopView.h"
#import "UENPasswordView.h"

@interface TwoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BottomPopView *bottomPopView;

@property (nonatomic, strong) UENPasswordView *passwordView;

@end

@implementation TwoViewController

static BOOL flag = NO;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"ShowPopView";
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

#pragma mark - LazyLoad
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
            _tableView.scrollIndicatorInsets = _tableView.contentInset;
        }
        [_tableView registerClass:[TwoViewCell class] forCellReuseIdentifier:@"TwoViewCell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TwoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"弹窗模版";
    }
    if (indexPath.row == 1) {
        cell.titleLabel.text = @"仿支付宝支付密码弹窗";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        self.bottomPopView = [[BottomPopView alloc] init];
        [self.bottomPopView showInView];
    }
    if (indexPath.row == 1) {
        [self payClick];
    }
}

- (void)payClick {
    __weak typeof(self) weakSelf = self;
    self.passwordView = [[UENPasswordView alloc] init];
    self.passwordView.title = @"输入交易密码";
    self.passwordView.loadingText = @"提交中...";
    [self.passwordView showInView];
    
    
    self.passwordView.finish = ^(NSString *password) {
        [weakSelf.passwordView hideKeyboard];
        [weakSelf.passwordView startLoading];
        NSLog(@"Password  =  %@", password);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            flag = !flag;
            if (flag) {
                NSLog(@"申购成功，跳转到成功页");
                [weakSelf.passwordView requestComplete:YES message:@"支付成功，做一些处理"];
                [weakSelf.passwordView stopLoading];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.passwordView dismissView];
                });
            } else {
                NSLog(@"申购失败，跳转到失败页");
                [weakSelf.passwordView requestComplete:NO message:@"支付失败，做一些处理"];
                [weakSelf.passwordView stopLoading];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.passwordView dismissView];
                });
            }
        });
    };
}



@end
