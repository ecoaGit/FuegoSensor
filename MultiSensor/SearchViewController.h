//
//  SearchViewController.h
//  MultiSensor
//
//  Created by Apple on 2016/9/20.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "SmartConfigGlobalConfig.h"
#import "SmartConfigDiscoverMDNS.h"
#import "FirstTimeConfig.h"
#import "WebViewController.h"
#import "GCDAsyncSocket.h"
#import "DBHelper.h"

#define readMacHeaderTag 0
#define readMacContentTag 1
#define writeMacCommandTag 2
#define writeSyncCommandTag 3


@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate, GCDAsyncSocketDelegate>


@property (nonatomic, retain) IBOutlet UITextField *apPass;
@property (nonatomic, retain) IBOutlet UITextField *SSID;
@property (nonatomic, retain) IBOutlet UITextField *deviceName;
@property (nonatomic, retain) IBOutlet UITableView *deviceList;
@property (nonatomic, retain) IBOutlet UILabel *SSIDLabel;
@property (nonatomic, retain) IBOutlet UILabel *apPassLabel;
@property (nonatomic, retain) IBOutlet UILabel *devNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *start_button;

@property (nonatomic, retain) Reachability *wifiReachability;
@property (nonatomic) SmartConfigDiscoverMDNS *mdnsService;
@property (retain, atomic) SmartConfigGlobalConfig *globalConfig;
@property (nonatomic) FirstTimeConfig *firstTimeConfig;

@property (weak, nonatomic) id ssidInfo;
@property (nonatomic) BOOL modifiedSSID;
@property (weak, nonatomic) NSTimer *mdnsTimer;
@property (weak, nonatomic) NSTimer *updateTimer;
@property (weak, nonatomic) NSTimer *discoveryTimer;
@property (retain, atomic) NSData *freeData;
@property (retain, atomic) NSString *passwordKey;
@property (nonatomic, retain) UIProgressView *progressbar;
@property (nonatomic,retain) NSMutableDictionary *devices;
@property int progressTime;
@property BOOL added;
@property (retain, nonatomic) GCDAsyncSocket *socket;

@end
