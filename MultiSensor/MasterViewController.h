//
//  MasterViewController.h
//  MultiSensor
//
//  Created by Apple on 2016/9/9.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartConfigGlobalConfig.h"
#import <SystemConfiguration/CaptiveNetwork.h>
//#import "SearchViewController.h"

//@class DetailViewController;
@class RealtimeDataController;
//@class HistoryViewController;

@interface MasterViewController : UITableViewController

//@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) RealtimeDataController *realtimeDataController;
@property (retain, atomic) SmartConfigGlobalConfig *globalConfig;

@end

