//
//  DataModel.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "DataModel.h"

@implementation DataModel

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.name = [dic objectForKey:@"name"];
    }
    return self;
}

+ (id)ordersWithDic:(NSDictionary *)dic {
    DataModel *dataModel = [[DataModel alloc] initWithDic:dic];
    return dataModel;
}

@end
