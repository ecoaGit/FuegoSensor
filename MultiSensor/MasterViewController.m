//
//  MasterViewController.m
//  MultiSensor
//
//  Created by Apple on 2016/9/9.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "RealtimeDataController.h"
#import "DeviceListViewController.h"
#import "HistoryViewController.h"
#import "SearchViewController.h"



@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

@synthesize globalConfig;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    //NSLog(@"present first controller");
    self.realtimeDataController = (RealtimeDataController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.realtimeDataController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.realtimeDataController.navigationItem.leftItemsSupplementBackButton = YES;
    //[self.realtimeDataController.navigationItem.leftBarButtonItem setTitle:@"stedte"];
    //[self.splitViewController setPresentsWithGesture:NO];//stop slide gesture open masterview controller steve 20161212
    
    [self initMasterTable];// set master table section
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;// remove table view line
    [self updateNetworkName];// get current SSID name
    self.globalConfig=[SmartConfigGlobalConfig getInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"masterview prepareforsegue:%@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"realtimeData"]) {
        //NSLog(@"realdata");
        RealtimeDataController *controller = (RealtimeDataController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    else if ([[segue identifier] isEqualToString:@"historyData"]){
        //NSLog(@"history");
        HistoryViewController *controller = (HistoryViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton=YES;
    }
    else if ([[segue identifier] isEqualToString:@"setting"]){
        //NSLog(@"setting");
        HistoryViewController *controller = (HistoryViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton=YES;
    }
    else if ([[segue identifier] isEqualToString:@"deviceList"]) {
        DeviceListViewController *controller = (DeviceListViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    else if ([[segue identifier] isEqualToString:@"searchDevice"]){
        SearchViewController *controller = (SearchViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton=YES;
        //[controller.navigationItem.leftBarButtonItem setTitle:@"search"];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(void)initMasterTable{
    if (!self.objects)
        self.objects = [[NSMutableArray alloc]init];
    NSIndexPath *indexPath;
    [self.objects insertObject:NSLocalizedString(@"search", @"search") atIndex:0];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.objects insertObject:NSLocalizedString(@"list", @"list") atIndex:0];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.objects insertObject:NSLocalizedString(@"setting", @"setting") atIndex:0];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.objects insertObject:NSLocalizedString(@"history", @"history") atIndex:0];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.objects insertObject:NSLocalizedString(@"realtime", @"realtime") atIndex:0];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath :%ld", (long)indexPath.row);
    switch (indexPath.row){
        case 0:
            [self performSegueWithIdentifier:@"realtimeData" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"historyData" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"setting" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"deviceList" sender:self];
            break;
        case 4:
            [self performSegueWithIdentifier:@"searchDevice" sender:self];
            break;
        default:
            break;
    }
}

- (void)updateNetworkName{
    NSLog(@"update network name");
    id ssidInfo = [self fetchSSIDInfo];
    NSString *ssidName = [ssidInfo objectForKey:@"SSID"];
    NSUserDefaults *spref=[NSUserDefaults standardUserDefaults];
    NSString *oldSSID=[spref stringForKey:@"SSID"];
    if (oldSSID==nil||![oldSSID isEqualToString:ssidName]) {
        [spref setObject:ssidName forKey:@"SSID"];
    }
    //if(![self.globalConfig.ssidName isEqual:ssidName]){
    //    self.globalConfig.ssidName=ssidName;
    //    NSLog(@"%@", ssidName);
    //    NSLog(@"Setting new SSID Name: %@", self.globalConfig.ssidName);
    //}
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    //NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    //NSLog(@"Network info: %@", info);
    return info;
}

@end
