//
//  HBTestPerson.m
//  HBCoreFramework
//
//  Created by knight on 16/4/6.
//  Copyright © 2016年 bj.58.com. All rights reserved.
//

#import "HBTestPerson.h"

@implementation HBTestPerson
- (NSDictionary *)hb_transferDic {
    return @{@"entityname":@"entityName",
             @"entitynum":@"entityNum"};
}

+ (NSDictionary *)hb_objectClassForKeyDic {
    return @{@"testEntities":[HBTestEntity class]};
}

- (void)setEntityAge2:(HBTestEntity *)entityAge {
    _testEntity = entityAge;
}
@end
