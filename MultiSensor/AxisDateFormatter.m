//
//  AxisDateFormatter.m
//  MultiSensor
//
//  Created by Apple on 2017/2/16.
//  Copyright © 2017年 ECOA. All rights reserved.
//

#import "AxisDateFormatter.h"


@interface AxisDateFormatter ()
{
    NSDateFormatter *dateFormatter;
}
@end

@implementation AxisDateFormatter

-(id) initWithDateFormat:(NSString*)format{
    self=[super init];
    if (self){
        dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:format];
    }
    return self;
}

-(NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis{
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value]];
}

@end
