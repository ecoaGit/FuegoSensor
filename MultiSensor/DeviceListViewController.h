//
//  DeviceListViewController.h
//  MultiSensor
//
//  Created by Apple on 2016/9/22.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartConfigGlobalConfig.h"
#import "DBHelper.h"


@interface DeviceListViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic,retain) NSMutableArray *device;
@property (nonatomic,retain) NSMutableDictionary *recentDevice;
@property (nonatomic,retain) SmartConfigGlobalConfig *globalconfig;
@property (nonatomic,retain) NSMutableData *data;
@property (nonatomic,retain) UIAlertController *alert;

@end
