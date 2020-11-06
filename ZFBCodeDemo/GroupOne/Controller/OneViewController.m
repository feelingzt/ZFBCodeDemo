//
//  OneViewController.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "OneViewController.h"
#import "DataModel.h"

@interface OneViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"仿支付宝扣款顺序";
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    //CGFloat viewY = [self getStatusRectAndNavRect];
    CGFloat viewHeight = SCREEN_HEIGHT - [self getBottomTabBarHeightRect];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, viewHeight);
    
    [self loadData];
    
    [self getBottomTabBarHeightRect];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * IDentifer = @"IDentifer";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDentifer];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDentifer];
    }
    
    DataModel *model = _dataArray[indexPath.row];
    
    cell.textLabel.text = model.name;
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/*
 * 选择编辑模式, 添加模式很少用, 默认是删除;
 */
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

/*
 * 排序, 当移动了某一行时候会调用;
 * 编辑状态下, 只要实现这个方法, 就能实现拖动排序;
 */
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    // 取出要拖动的模型数据
    DataModel *model = _dataArray[sourceIndexPath.row];
    
    // 删除之前行的数据
    [_dataArray removeObject:model];
    
    // 插入数据到新的位置
    [_dataArray insertObject:model atIndex:destinationIndexPath.row];
}


#pragma mark - lazyload

// 注意: 懒加载的时候不能用 self. 若用 self. 会造成死循环

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - loaddata
- (void)loadData {
    // 取出数据
    NSString *pathStr  = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"plist"];
    NSArray *tempArray = [NSArray arrayWithContentsOfFile:pathStr];
    for (int i = 0; i < tempArray.count; i++) {
        DataModel *model = [DataModel ordersWithDic:tempArray[i]];
        [self.dataArray addObject:model];
    }
    
    [self.tableView setEditing:YES animated:YES];
}


@end
