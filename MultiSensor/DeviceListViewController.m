//
//  DeviceListViewController.m
//  MultiSensor
//
//  Created by Apple on 2016/9/22.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "DeviceListViewController.h"

@interface DeviceListViewController()<UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate, NSURLConnectionDelegate>

@end

@implementation DeviceListViewController

@synthesize globalconfig;
@synthesize device;
@synthesize recentDevice;
@synthesize alert;
int count;

-(void)viewDidLoad{
    self.device = [[NSMutableArray alloc]init];
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //避免navigation item擋住tableview第一個cell
    [self.tableView setContentInset:UIEdgeInsetsMake(32, 0, 0, 0)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"SYNC_COMPLETE" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"SYNC_FAILED" object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [self getDeviceList];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:@"deviceCell"];
    if (cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"deviceCell"];
        [cell setClipsToBounds:NO];
    }
    if (self.device!=nil){
        [cell.textLabel setText:[[self.device objectAtIndex:indexPath.row]objectForKey:@"devicename"]];
        [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        [cell.detailTextLabel setText:[[self.device objectAtIndex:indexPath.row]objectForKey:@"macaddr"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.device != nil){
        NSUserDefaults *nd=[NSUserDefaults standardUserDefaults];
        [nd setObject:[[self.device objectAtIndex:indexPath.row] objectForKey:@"macaddr"] forKey:@"mac"];
        if ([nd synchronize]){
            NSLog(@"Device Seleted");
            [self syncSetting:[[self.device objectAtIndex:indexPath.row] objectForKey:@"macaddr"]];
            alert=[UIAlertController alertControllerWithTitle:@"MultiSensor Notification" message:NSLocalizedString(@"sync", @"") preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:NO completion:nil];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.device count];
}

-(void)getDeviceList{
    NSLog(@"getDeviceList");
    DBHelper *helper=[DBHelper newInstance];
    [helper openDataBase];
    FMResultSet *rs=[helper getSensorDevicesList];
    if (rs!=nil){
        //NSLog(@"rs is not nil");
        while (rs.next){
            //NSLog(@"%@" ,[[rs resultDictionary]description]);
            [self.device addObject:[rs resultDictionary]];
        }
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }else {
        //NSLog(@"rs is nil");
    }
    [rs close];
    [helper closeDataBase];
}

-(void) alertWithMessage :( NSString *) message{
    
}

-(void)syncSetting:(NSString *)mac{
    NSLog(@"sync setting");
    NSMutableDictionary *js_dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"YES",@"Initial",mac,@"macaddr", nil];
    NSError *err = nil;
    NSData *post_data = [NSJSONSerialization dataWithJSONObject:js_dic options:0 error:&err];
    NSString *urlString=@"http://ecoacloud.com:80/cloudserver/Fuego_Sync";
    NSURL *url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", post_data.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:post_data];
    count=0;
    for (int i=0;i<3;i++){
        NSURLConnection *connect = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // url connection error
    NSLog(@"urlconnection error %@",[error localizedDescription]);
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    if ([httpResponse statusCode]==200){
        [self.data setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)rdata{
    count++;
    NSLog(@"didReceiveData");
    //[self.data appendData:rdata];
    if (rdata!=nil){
        NSError *err=nil;
        NSDictionary *jsob=[NSJSONSerialization JSONObjectWithData:rdata options:NSJSONReadingMutableLeaves error:&err];
        //NSLog([jsob description]);
        if([jsob objectForKey:@"40001"]!=nil){
            NSUserDefaults *nd=[NSUserDefaults standardUserDefaults];
            [nd setObject:[jsob objectForKey:@"40002"] forKey:@"CO2Ofs"];
            [nd setObject:[jsob objectForKey:@"40003"] forKey:@"DustOfs"];
            [nd setObject:[jsob objectForKey:@"40004"] forKey:@"pressOfs"];
            [nd setObject:[jsob objectForKey:@"40005"] forKey:@"COOfs"];
            [nd setObject:[jsob objectForKey:@"40006"] forKey:@"IaqOfs"];
            [nd setObject:[jsob objectForKey:@"40007"] forKey:@"TempOfs"];
            [nd setObject:[jsob objectForKey:@"40008"] forKey:@"HumiOfs"];
            [nd setObject:[jsob objectForKey:@"40009"] forKey:@"GasOfs"];
            [nd setObject:[jsob objectForKey:@"40010"] forKey:@"FanSpeed"];
            [nd setObject:[jsob objectForKey:@"40011"] forKey:@"PirSensitive"];
            [nd setObject:[jsob objectForKey:@"40012"] forKey:@"PirDelay"];
            [nd setObject:[jsob objectForKey:@"40013"] forKey:@"TempAlmHigh"];
            [nd setObject:[jsob objectForKey:@"40014"] forKey:@"TempAlmLow"];
            [nd setObject:[jsob objectForKey:@"40015"] forKey:@"VocAlmHigh"];
            [nd setObject:[jsob objectForKey:@"40016"] forKey:@"VocAlmHigh2"];
            [nd setObject:[jsob objectForKey:@"40017"] forKey:@"CO2AlmStep1"];
            [nd setObject:[jsob objectForKey:@"40018"] forKey:@"CO2AlmStep2"];
            [nd setObject:[jsob objectForKey:@"40019"] forKey:@"COAlmHigh"];
            [nd setObject:[jsob objectForKey:@"40020"] forKey:@"COAlmHigh2"];
            [nd setObject:[jsob objectForKey:@"40021"] forKey:@"GasAlmHigh"];
            [nd setObject:[jsob objectForKey:@"40022"] forKey:@"GasAlmHigh2"];
            [nd setObject:[jsob objectForKey:@"40023"] forKey:@"DustAlmHigh"];
            NSLog(@"%@", [jsob objectForKey:@"40024"]);
            [nd setObject:[jsob objectForKey:@"40024"] forKey:@"DustAlmHigh2"];
            if(![nd synchronize]){
                    NSLog(@"initial setting synchronize failed");
                if(count==3){
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"SYNC_FAILED" object:nil];
                }
            }
            else{
                if(count==3){
                    NSLog(@"initial setting sync completed");
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"SYNC_COMPLETE" object:nil];
                }
            }
        }
    }
}

-(void)receiveNotification:(NSNotification*)notify{
    if([notify.name isEqualToString:@"SYNC_COMPLETE"]){
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [alert setMessage:NSLocalizedString(@"sync_ok", @"")];
    }
    else if([notify.name isEqualToString:@"SYNC_FAILED"]){
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [alert setMessage:NSLocalizedString(@"sync_fail", @"")];
    }
}

@end
