//
//  RealtimeDataController.h
//  MultiSensor
//
//  Created by Apple on 2016/9/19.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "pollMode.h"
#import "Reachability.h"
#import "DBHelper.h"

@interface RealtimeDataController : UIViewController <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate, CLLocationManagerDelegate>

#define Default_Color [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:144.0/255.0]
#define PM25_Level_0 [UIColor colorWithRed:0.0 green:236.0/255.0 blue:0.0 alpha:144.0/255.0]
#define PM25_Level_1 [UIColor colorWithRed:255.0/255.0 green:220.0/255.0 blue:53.0/255.0 alpha:144.0/255.0]
#define PM25_Level_2 [UIColor colorWithRed:234.0/255.0 green:0.0 blue:0.0 alpha:144.0/255.0]
#define PM25_Level_3 [UIColor colorWithRed:91.0/255.0 green:0.0 blue:174.0/255.0 alpha:144.0/255.0]

#define outdoorTag 0x00
#define indoorTag 0x01

@property (retain,nonatomic) IBOutlet UILabel *pm25;
@property (retain,nonatomic) IBOutlet UILabel *CO;
@property (retain,nonatomic) IBOutlet UILabel *CO2;
@property (retain,nonatomic) IBOutlet UILabel *VOC;
@property (retain,nonatomic) IBOutlet UILabel *temp;
@property (retain,nonatomic) IBOutlet UILabel *humi;
@property (retain,nonatomic) IBOutlet UILabel *gas;
@property (retain,nonatomic) IBOutlet UILabel *pressure;
@property (retain,nonatomic) IBOutlet UIButton *outdoor;
@property (retain,nonatomic) IBOutlet UIButton *indoor;
@property (retain,nonatomic) IBOutlet UIImageView *PIR;
@property (retain,nonatomic) IBOutlet UIImageView *fire;
@property (retain,nonatomic) GCDAsyncUdpSocket *socket;
@property (retain) Reachability *wifiReachability;
@property (retain,nonatomic) NSMutableArray *cache;
@property (retain,nonatomic) IBOutlet UIImageView *icon;

@end
