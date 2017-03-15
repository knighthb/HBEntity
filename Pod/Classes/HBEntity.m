//
//  HBEntity.m
//  HBCoreFramework
//
//  Created by knight on 16/3/25.
//  Copyright © 2016年 bj.58.com. All rights reserved.
//

#import "HBEntity.h"
#import "HBPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "HBEntityUtil.h"
@implementation HBEntity
+ (BOOL)boolValueWith:(NSString *)boolString {
    if ([boolString isKindOfClass:[NSString class]]) {
        if (boolString && boolString.length > 0) {
            const char * lowercaseBoolString = boolString.lowercaseString.UTF8String;
            //只要不是no、false和0都返回YES
            if (strEqualTo("no", lowercaseBoolString) ||
                strEqualTo("false", lowercaseBoolString) ||
                strEqualTo("0", lowercaseBoolString)) {
                return NO;
            }else {
                return YES;
            }
        }
    }else {
        id boolValue = boolString;
        if (kCFBooleanTrue == (__bridge CFBooleanRef)(boolValue)) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSDictionary *)reverseTransferDic:(NSDictionary *)transferDic {
    if (!transferDic || transferDic.count <=0) {
        return transferDic;
    }else {
        NSMutableDictionary * reverseTransferDic = @{}.mutableCopy;
        [transferDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            reverseTransferDic[obj] = key;
        }];
        return reverseTransferDic;
    }
}


+ (instancetype)transferEntityWithObject:(id)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [self transferEntityWithDic:object];
    }else if ([object isKindOfClass:[NSArray class]]) {
        return [self transferEntityWithArray:object];
    }
    return [[self alloc] init];
}

+ (instancetype)transferEntityWithArray:(NSArray *)array {
    unsigned int outCount;
    NSDictionary * reverseTransferDic = nil;
    id instance = [[self alloc] init];
    
    if ([instance respondsToSelector:@selector(hb_transferDic)]) {
        reverseTransferDic = [self reverseTransferDic:[instance hb_transferDic]];
    }
    objc_property_t * properties = class_copyPropertyList([self class], &outCount);
    if (outCount > 0) {
        for (unsigned int index = 0; index < outCount; index++) {
            struct objc_property * property = properties[index];
            const char * name =  property_getName(property);
            NSString * key = [NSString stringWithUTF8String:name];
            if ([[self hb_filerArray] containsObject:key]) {
                continue;
            }
            if (reverseTransferDic) {
                if (reverseTransferDic[key]) {
                    key = reverseTransferDic[key];
                }
            }
            HBPropertyInfo * propertyInfo = [[HBPropertyInfo alloc] initWithProperty:property];
            id data =[self entityArray:array withKey:key];
            if ([propertyInfo canSetValue]) {
                ((void (*)(id,SEL,id))(void *)objc_msgSend)(instance,propertyInfo.setter,data);
            }
            
        }
    }
    free(properties);
    return instance;

}

+ (NSMutableArray *)entityArray:(NSArray *)array withKey:(NSString *)key{
    if ([array isKindOfClass:[NSArray class]]) {
        NSMutableArray * instanceArray = @[].mutableCopy;
        for (unsigned int index = 0; index<[array count]; index++) {
            if ([self conformsToProtocol:@protocol(HBEntityProtocol)] &&
                [self respondsToSelector:@selector(hb_objectClassForKeyDic)]) {
                NSDictionary * mapedKeyClass = [self hb_objectClassForKeyDic];
                if (mapedKeyClass) {
                    Class cls = mapedKeyClass[key];
                    if (cls && ![cls isSubclassOfClass:[NSNull class]]) {
                        if ([cls isSubclassOfClass:[NSString class]]) {
                            NSString * string = array[index];
                            [instanceArray addObject:string];
                        }else {
                            id data = [cls transferEntityWithObject:array[index]];
                            [instanceArray addObject:data];
                        }
                    }
                }
            }
        }
        return instanceArray;
    }
    return nil;
}

+ (instancetype)transferEntityWithDic:(NSDictionary *)dic {
    unsigned int outCount;
    NSDictionary * reverseTransferDic = nil;
    id instance = [[self alloc] init];

    if ([instance respondsToSelector:@selector(hb_transferDic)]) {
        reverseTransferDic = [self reverseTransferDic:[instance hb_transferDic]];
    }
    objc_property_t * properties = class_copyPropertyList([self class], &outCount);
    if (outCount > 0) {
        for (unsigned int index = 0; index < outCount; index++) {
            struct objc_property * property = properties[index];
            const char * name =  property_getName(property);
            NSLog(@"%s",name);
            NSString * key = [NSString stringWithUTF8String:name];
            if ([[self hb_filerArray] containsObject:key]) {
                continue;
            }
            if (reverseTransferDic) {
                if (reverseTransferDic[key]) {
                    key = reverseTransferDic[key];
                }
            }
            HBPropertyInfo * propertyInfo = [[HBPropertyInfo alloc] initWithProperty:property];
            Class clazz = propertyInfo.clazz;
            if ([clazz isSubclassOfClass:[NSArray class]]) {
                if ([self conformsToProtocol:@protocol(HBEntityProtocol)] &&
                    [self respondsToSelector:@selector(hb_objectClassForKeyDic)]) {
                    NSDictionary * mapedKeyClass = [self hb_objectClassForKeyDic];
                    if (mapedKeyClass) {
                        Class cls = mapedKeyClass[key];
                        if (cls && ![cls isSubclassOfClass:[NSNull class]]) {
                            clazz = cls;
                            id data = [self entityArray:dic[key] withKey:key];
                            if ([propertyInfo canSetValue]) {
                                ((void (*)(id,SEL,id))(void *)objc_msgSend)(instance,propertyInfo.setter,data);
                            }
                        }else {
                            id data = dic[key];
                            if ([propertyInfo canSetValue]) {
                                ((void (*)(id,SEL,id))(void *)objc_msgSend)(instance,propertyInfo.setter,data);
                            }
                        }
                    }
                }
            }else if ([clazz conformsToProtocol:@protocol(HBEntityProtocol)]) {
                //自定义实体
                id data = [clazz transferEntityWithObject:dic[key]];
                if ([propertyInfo canSetValue]) {
                    ((void (*)(id,SEL,id))(void *)objc_msgSend)(instance,propertyInfo.setter,data);
                }
            }else {
                //普通
                if (!propertyInfo.isNumber) {
                    if ([propertyInfo canSetValue]) {
                        id value = dic[key];
                        if ([value isKindOfClass:[NSNumber class]]) {
                            if ([@"NSString" isEqualToString:NSStringFromClass(propertyInfo.clazz)]) {
                                value = [NSString stringWithFormat:@"%@",value];
                            }
                        }
                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(instance,propertyInfo.setter,value);
                    }
                }else {
                    if (propertyInfo.isNumber) {
                        NSNumber * data = nil;
                        if(propertyInfo.type & HBTypeEncodingBoolType) {
                            data = [NSNumber numberWithBool:[self boolValueWith:dic[key]]];

                        }else {
                            NSNumberFormatter * numFormatter =   [[NSNumberFormatter alloc] init];
                            data = [numFormatter numberFromString:[NSString stringWithFormat:@"%@",dic[key]]];
                        }
                        [self sendMsgToInstance:instance withSetter:propertyInfo withNumber:data];
                    }
                }
            }
        }
    }
    free(properties);
    return instance;
}

+ (void)sendMsgToInstance:(id )instance
               withSetter:(HBPropertyInfo *) propertyInfo
               withNumber:(NSNumber *)number{
    if ([propertyInfo canSetValue]) {
        if (propertyInfo.type & HBTypeEncodingUIntegerType) {
            ((void (*)(id,SEL,NSUInteger))(void *)objc_msgSend)(instance,propertyInfo.setter,[number unsignedIntegerValue]);
        }
        else if (propertyInfo.type & HBTypeEncodingIntegerType) {
            ((void (*)(id,SEL,NSInteger))(void *)objc_msgSend)(instance,propertyInfo.setter,[number integerValue]);
        }else if (propertyInfo.type & HBTypeEncodingBoolType) {
            ((void (*)(id,SEL,BOOL))(void *)objc_msgSend)(instance,propertyInfo.setter,[number boolValue]);
        }else if (propertyInfo.type & HBTypeEncodingDoubleType){
            ((void (*)(id,SEL,double))(void *)objc_msgSend)(instance,propertyInfo.setter,[number doubleValue]);
        }else if (propertyInfo.type & HBTypeEncodingFloatType) {
            ((void (*)(id,SEL,float))(void *)objc_msgSend)(instance,propertyInfo.setter,[number floatValue]);
        }else if (propertyInfo.type & HBTypeEncodingIntType) {
            ((void (*)(id,SEL,int))(void *)objc_msgSend)(instance,propertyInfo.setter,[number intValue]);
        }else if (propertyInfo.type & HBTypeEncodingLongType) {
            ((void (*)(id,SEL,long))(void *)objc_msgSend)(instance,propertyInfo.setter,[number longValue]);
        }else if (propertyInfo.type & HBTypeEncodingShortType) {
            ((void (*)(id,SEL,short))(void *)objc_msgSend)(instance,propertyInfo.setter,[number shortValue]);
        }else {
            ((void (*)(id,SEL,NSNumber*))(void *)objc_msgSend)(instance,propertyInfo.setter,number);
        }
    }
    
}

+ (NSArray *)hb_filerArray{
    return @[@"hash",@"superclass",@"description",@"debugDescription"];
}
@end
