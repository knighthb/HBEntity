//
//  HBTestPerson.h
//  HBCoreFramework
//
//  Created by knight on 16/4/6.
//  Copyright © 2016年 bj.58.com. All rights reserved.
//

#import "HBEntity.h"
#import "HBTestEntity.h"
@interface HBTestPerson : HBEntity
@property (nonatomic , copy)NSString * entityName;
@property (nonatomic , strong) NSString *entityNum;
@property (nonatomic , strong,setter=setEntityAge2:) HBTestEntity *testEntity;
@property (nonatomic , strong) NSMutableArray<HBTestEntity *> * testEntities;
@property (nonatomic , assign) BOOL boolTest;
@end
