//
//  HistoryContentViewController.h
//  MultiSensor
//
//  Created by Apple on 2016/10/3.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts-swift.h>
//#import <Charts/Charts.h>

@interface HistoryContentViewController : UIViewController

-(void)setContentViewData:(NSMutableArray *)viewData withKey:(NSInteger)key;

@end
