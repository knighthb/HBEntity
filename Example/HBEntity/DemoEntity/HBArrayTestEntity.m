//
//  HBArrayTestEntity.m
//  HBCoreFramework
//
//  Created by knight on 16/4/6.
//  Copyright © 2016年 bj.58.com. All rights reserved.
//

#import "HBArrayTestEntity.h"
#import "HBTestEntity.h"
@implementation HBArrayTestEntity
+ (NSDictionary *)hb_objectClassForKeyDic {
    return @{@"array":[HBTestEntity class]};
}
@end
