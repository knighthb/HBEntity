//
//  HBEntity.h
//  HBCoreFramework
//
//  Created by knight on 16/3/25.
//  Copyright © 2016年 bj.58.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HBEntityProtocol <NSObject>
@optional
- (NSDictionary *)hb_transferDic;

+ (NSDictionary *)hb_objectClassForKeyDic;

@end
@interface HBEntity : NSObject<HBEntityProtocol>

+ (instancetype)transferEntityWithDic:(NSDictionary *)dic;
+ (instancetype)transferEntityWithObject:(id)object;
@end
