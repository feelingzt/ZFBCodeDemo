//
//  DataModel.h
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic, copy) NSString *name;

- (id)initWithDic:(NSDictionary*)dic;

+ (id)ordersWithDic:(NSDictionary*)dic;

@end

