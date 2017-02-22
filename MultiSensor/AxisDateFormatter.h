//
//  AxisDateFormatter.h
//  MultiSensor
//
//  Created by Apple on 2017/2/16.
//  Copyright © 2017年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Charts;

@interface AxisDateFormatter : NSObject <IChartAxisValueFormatter>

-(id) initWithDateFormat:(NSString*)format;

@end
