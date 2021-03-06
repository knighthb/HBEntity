//
//  HBPropertyInfo.m
//  HBCoreFramework
//
//  Created by knight on 16/4/4.
//  Copyright © 2016年 bj.58.com. All rights reserved.
//

#import "HBPropertyInfo.h"
#import "HBEntityUtil.h"
@interface HBPropertyInfo()
@property (nonatomic, assign, readwrite) objc_property_t property;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *value;
@property (nonatomic, strong, readwrite) Class clazz;
@property (nonatomic, assign, readwrite) SEL getter;
@property (nonatomic, assign, readwrite) SEL setter;
@property (nonatomic, assign, readwrite)HBTypeEncodingPropertyType type;
@property (nonatomic, copy, readwrite)NSString * iVarName;
@property (nonatomic, assign, readwrite) BOOL isNumber;

@end
static NSDictionary * classMap;
static NSDictionary * propertyTypeMap;
@implementation HBPropertyInfo

+ (void)initialize {
    classMap = @{
                 @"B":[NSNumber class],//bool
                 @"i":[NSNumber class],//int enum signed
                 @"d":[NSNumber class],//double
                 @"f":[NSNumber class],//float
                 @"l":[NSNumber class],//long
                 @"s":[NSNumber class],//short
                 @"q":[NSNumber class],//NSInteger
                 @"Q":[NSNumber class],//NSUInteger
                 @"c":[NSNumber class]//bool
                 };
    propertyTypeMap = @{
                 @"B":@(HBTypeEncodingBoolType),//bool
                 @"i":@(HBTypeEncodingIntType),//int enum signed
                 @"d":@(HBTypeEncodingDoubleType),//double
                 @"f":@(HBTypeEncodingFloatType),//float
                 @"l":@(HBTypeEncodingLongType),//long
                 @"s":@(HBTypeEncodingShortType),//short
                 @"q":@(HBTypeEncodingIntegerType),//NSInteger
                 @"Q":@(HBTypeEncodingUIntegerType),//NSUInteger
                 @"c":@(HBTypeEncodingBoolType),//bool
                 };
}

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    if (self) {
        _property = property;
        const char * name = property_getName(property);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        _type = HBTypeEncodingUnkownType;
        char * capitalizedName = malloc(strlen(name)+1);
        stpcpy(capitalizedName, name);
        capitalizedName[0] = capitalizedName[0]-'a'+'A';
        NSString * methodName = [NSString stringWithUTF8String:capitalizedName];
        NSString * originalSetterName = [NSString stringWithFormat:@"set%@:",methodName];
        _setter = sel_registerName([originalSetterName UTF8String]);
        _getter = sel_registerName([methodName UTF8String]);
        const char * attributes = property_getAttributes(property);
        if (attributes) {
            unsigned int attributesCount;
            objc_property_attribute_t * attributes_t = property_copyAttributeList(property, &attributesCount);
            if (attributesCount > 0) {
                for (unsigned int attrIndex = 0; attrIndex < attributesCount; attrIndex ++) {
                    objc_property_attribute_t property_attr_t = attributes_t[attrIndex];
                    if (strEqualTo("T", property_attr_t.name)) {
                        //数字、日期等格式没有处理
                        [self parseClassWithPropertyAttributeValue:property_attr_t.value];
                    }else if(strEqualTo("R", property_attr_t.name)) {
                        _type |= HBTypeEncodingPropertyReadOnly;
                    }else if (strEqualTo("C", property_attr_t.name)) {
                        _type |= HBTypeEncodingPropertyCopy;
                    }else if (strEqualTo("&", property_attr_t.name)) {
                        _type |= HBTypeEncodingPropertyRetain;
                    }else if (strEqualTo("D", property_attr_t.name)) {
                        _type |= HBTypeEncodingPropertyDynamic;
                    }else if (strEqualTo("W", property_attr_t.name)) {
                        _type |= HBTypeEncodingPropertyWeak;
                    }else if (strEqualTo("N", property_attr_t.name)) {
                        _type |= HBTypeEncodingPropertyNonAtomic;
                    }else if (strEqualTo("S", property_attr_t.name)) {
                        NSString * setterName = [NSString stringWithUTF8String:property_attr_t.value];
                        _setter = sel_registerName([setterName UTF8String]);
                    }else if (strEqualTo("G", property_attr_t.name)) {
                        NSString * getterName = [NSString stringWithUTF8String:property_attr_t.value];
                        _getter = sel_registerName([getterName UTF8String]);
                    }else if (strEqualTo("V", property_attr_t.name)) {
                        _iVarName = [NSString stringWithUTF8String:property_attr_t.value];
                    }
                }
            }
            free(attributes_t);
        }
        free(capitalizedName);
    }
    return self;
}

- (void)parseClassWithPropertyAttributeValue:(const char *)attrValue {
   const char * classType = "";
    size_t len = strlen(attrValue);
    if (len <= 0) classType = "";
    char * value = malloc(sizeof(char *)*strlen(attrValue));
    if ('@'==attrValue[0]) {//id 类型
        _isNumber = NO;
        if (len==1) {
            classType = "NSValue";
        }
        unsigned int i;
        unsigned int j = 0;
        for (i=0; i < len; i++) {
            char tmp = attrValue[i];
            if ('@'!=tmp && '\"'!=tmp) {
                value[j++] = attrValue[i];
            }
        }
        value[j]= '\0';
        if (strEqualTo(value, "NSNumber")) {
            _isNumber = YES;
        }
        classType = value;
    }else {
        if (len == 1) {
            _isNumber = YES;
            NSString * key = [NSString stringWithUTF8String:attrValue];
            _type |= [propertyTypeMap[key] integerValue];
            classType = NSStringFromClass(classMap[key]).UTF8String;
        }
        classType = "NSString";
    }
    NSString * className = [[NSString alloc ]initWithCString:classType encoding:NSUTF8StringEncoding];
    _clazz = NSClassFromString(className);
    free(value);
    classType = nil;
}

- (BOOL)canSetValue {
    if (_type != HBTypeEncodingPropertyReadOnly && _type!=HBTypeEncodingPropertyDynamic && _type != HBTypeEncodingUnkownType) {
        return YES;
    }else {
        return NO;
    }
}
@end
