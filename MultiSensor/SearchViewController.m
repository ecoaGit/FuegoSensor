//
//  SearchViewController.m
//  MultiSensor
//
//  Created by Apple on 2016/9/20.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "SearchViewController.h"

int const discoveryTimeout = 60;
int const MDNSRestartTime = 15;
float progression=0;
BOOL discoveryInProgress;

@interface SearchViewController()<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate,GCDAsyncSocketDelegate, UITextFieldDelegate>

@end

@implementation SearchViewController

NSInteger path;

@synthesize SSID;
@synthesize apPass;
@synthesize deviceName;
@synthesize SSIDLabel;
@synthesize apPassLabel;
@synthesize devNameLabel;
@synthesize start_button;
@synthesize progressbar;
@synthesize devices;
@synthesize socket;

-(void)viewDidLoad{
    NSLog(@"get globalconfig instance");
    self.globalConfig = [SmartConfigGlobalConfig getInstance];
    self.mdnsService=[SmartConfigDiscoverMDNS getInstance];
    [self detectWifi];
    [SSIDLabel setText:NSLocalizedString(@"ssid", @"ssid")];
    [apPassLabel setText:NSLocalizedString(@"pass", @"password")];
    [devNameLabel setText:NSLocalizedString(@"devname", @"device name")];
    [start_button setTitle:NSLocalizedString(@"search_start", @"start") forState:UIControlStateNormal];
    self.progressbar=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.progressbar setFrame:CGRectMake(20, self.view.frame.size.height/2, self.view.frame.size.width-40, 100)];
    self.progressbar.trackTintColor=[UIColor lightGrayColor];
    self.progressbar.center=self.view.center;
    self.progressbar.hidden=YES;
    [self.view addSubview:self.progressbar];
    
    [self.SSID addTarget:self action:@selector(ssidDidChange) forControlEvents:UIControlEventEditingChanged];
    NSNotificationCenter *defCenter=[NSNotificationCenter defaultCenter];
    [defCenter addObserver:self selector:@selector(deviceAdded:) name:@"deviceFound" object:nil];
    self.devices=[[NSMutableDictionary alloc]init];
    self.deviceList.dataSource=self;
    self.deviceList.separatorStyle=UITableViewCellSeparatorStyleNone;
    //[self.deviceList setBackgroundColor:[UIColor grayColor]];
    self.added = NO;
    self.socket=nil;
    //catch return key on keyboard
    self.apPass.delegate=self;
    self.apPass.enablesReturnKeyAutomatically=YES;
    self.SSID.delegate=self;
    self.SSID.enablesReturnKeyAutomatically=YES;
    self.deviceName.delegate=self;
    self.deviceName.enablesReturnKeyAutomatically=YES;
}

-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *spref=[NSUserDefaults standardUserDefaults];
    //NSLog(@"set ssid text %@", [spref stringForKey:@"SSID"]);
    [self.SSID setText:[spref stringForKey:@"SSID"]];
}

- (IBAction)buttonAction:(UIButton*)button{
    
    // detect if we have wifi reachability
    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    
    if ( netStatus != ReachableViaWiFi )
    { // No activity if no wifi
        NSLog(@"No Wifi");
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No WiFi detected" message:@"Switch to AP Provisioning?" delegate:self cancelButtonTitle:@"YES"otherButtonTitles:@"NO", nil];
        //[alert setTag:2];
        //[alert show];
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"No WiFi detected" message:@"Switch to AP Provisioning?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:NO completion:nil];
    }
    else if([self.apPass.text length] == 0) // password is empty
    {
        NSLog(@"Password is empty");
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"No AP Password entered" message:@"Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message: delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        //[alert setTag:1];
        //[alert show];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:NO completion:nil];
    }
    else
    {
        [self continueStartAction:button];
    }
}


- (void) continueStartAction:(UIButton*)button{
   // self.discoveryInProgress = YES;
    // hide button
    //button.hidden = YES;
    //self.cancelButton.hidden = NO;
    // stop UI interaction
    //    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    // show progress bar
   // self.progressBar.hidden = NO;
   // self.progressTime = 0;
    self.progressbar.hidden=NO;
    progression=0.0;
    [self.progressbar setProgress:progression];
    discoveryInProgress=YES;
    self.discoveryTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [self startTransmitting];
    // start discovery using TI lib
}

- (void) mDnsDiscoverStart {
    [self.mdnsService startMDNSDiscovery:self.deviceName.text];
}

- (void) mDnsDiscoverStop {
    [self.mdnsService stopMDNSDiscovery];
    
}

- (void)detectWifi{
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability connectionRequired];
    [self.wifiReachability startNotifier];
    //NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    //NSLog(@"Net Status: %d", netStatus);
}

/*
 This method start the transmitting the data to connected
 AP. Nerwork validation is also done here. All exceptions from
 library is handled.
 */
- (void)startTransmitting{
    @try {
        [self connectLibrary];
        if (self.firstTimeConfig == nil) {
            return;
        }
        [self sendAction];
    }
    @catch (NSException *exception) {
        NSLog(@"%s exception == %@",__FUNCTION__,[exception description]);
        [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:[exception description] waitUntilDone:NO];
    }
    @finally {
    }
}

// check for internet and initiate the libary object for further transmit.
-(void) connectLibrary{
    NSLog(@"connectLibrary");
    @try {
        [self disconnectFromLibrary];
        self.passwordKey = [self.apPass.text length] ? self.apPass.text : nil;
        //NSString *paddedEncryptionKey = self.scPass.text;
        self.freeData = [NSData alloc];
        if([self.deviceName.text length]){
            char freeDataChar[[self.deviceName.text length] + 3];
            // prefix
            freeDataChar[0] = 3;
            // device name length
            freeDataChar[1] = [self.deviceName.text length];
            for(int i = 0; i < [self.deviceName.text length]; i++){
                freeDataChar[i+2] = [self.deviceName.text characterAtIndex:i];
            }
            // added terminator
            freeDataChar[[self.deviceName.text length] + 2] = '\0';
            NSString *freeDataString = [[NSString alloc] initWithCString:freeDataChar encoding:NSUTF8StringEncoding];
            NSLog(@"free data char %s", freeDataChar);
            self.freeData = [freeDataString dataUsingEncoding:NSUTF8StringEncoding ];
        }
        else{
            self.freeData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSString *ipAddress = [FirstTimeConfig getGatewayAddress];
        NSLog(@"ip address %@", ipAddress);
        self.firstTimeConfig = [[FirstTimeConfig alloc] initWithData:ipAddress withSSID:self.SSID.text withKey:self.passwordKey withFreeData:self.freeData withEncryptionKey:Nil numberOfSetups:4 numberOfSyncs:10 syncLength1:3 syncLength2:23 delayInMicroSeconds:1000];
        [self mDnsDiscoverStart];
        // set timer to fire mDNS after 15 seconds
        self.mdnsTimer = [NSTimer scheduledTimerWithTimeInterval:MDNSRestartTime target:self selector:@selector(mDnsDiscoverStart) userInfo:nil repeats:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"%s exception == %@",__FUNCTION__,[exception description]);
        [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:[exception description] waitUntilDone:NO];
    }
}

// disconnect libary method involves to release the existing object and assign nil.
-(void) disconnectFromLibrary{
    self.firstTimeConfig = nil;
}

/*
 This method begins configuration transmit
 In case of a failure the method throws an OSFailureException.
 */
-(void) sendAction{
    @try {
        NSLog(@"%s begin", __PRETTY_FUNCTION__);
        [self.firstTimeConfig transmitSettings];
        NSLog(@"%s end", __PRETTY_FUNCTION__);
    }
    @catch (NSException *exception) {
        NSLog(@"exception === %@",[exception description]);
        [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:[exception description] waitUntilDone:NO];
    }
    @finally {}
}

-(void) ssidDidChange{
    //NSLog(@"%@", self.SSID.text);
    //NSLog(@"%@", self.globalConfig.ssidName);
    if( [self.SSID.text isEqualToString:self.globalConfig.ssidName] ){
        self.modifiedSSID = NO;
        //self.ssidWarning.hidden = YES;
    }
    else{
        self.modifiedSSID = YES;
        //self.ssidWarning.hidden = NO;
    }
}

/* timeout discovery */
-(void) discoveryTimedOut {
    [self stopDiscovery];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Configuration process timed out." message:@"Switch to AP Provisioning?" delegate:self cancelButtonTitle:@"YES"otherButtonTitles:@"NO", nil];
    //[alert show];
    if (!self.added) {
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Configuration process timed out." message:@"Switch to AP Provisioning?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:NO completion:nil];
    }
    else {
        [self updateRecentDevice];
    }
    discoveryInProgress=NO;
}

-(void) stopDiscovery {
    [self.mdnsTimer invalidate];
    discoveryInProgress = NO;
    [self.firstTimeConfig stopTransmitting];
    self.progressbar.hidden = YES;
    [self.discoveryTimer invalidate];
    [self mDnsDiscoverStop];
}

-(void) alertWithMessage :( NSString *) message{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"MultiSensor Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:NO completion:nil];
}

-(void)updateProgress {
    progression++;
    [self.progressbar setProgress:progression/discoveryTimeout];
    self.progressTime ++;
    if(self.progressTime >= discoveryTimeout) {
        [self discoveryTimedOut];
    }
}

-(void)deviceAdded:(id)sender{
    NSLog(@"device Added");
    self.added=YES;
    if(discoveryInProgress == YES){
        // [self stopDiscovery];
        //[self alertWithMessage:@"A new device was discovered. Please go to the Devices tab to access your device"];
        //[self updateRecentDevice];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.devices count];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.devices!=nil){
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"MultiSensor Notification" message:NSLocalizedString(@"add_device", @"add device") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                path=indexPath.row;
                NSArray *keys=[self.devices allKeys];
                NSString *url=[[self.devices objectForKey:keys[indexPath.row]]objectForKey:@"url"];
                NSURL *nsurl=[NSURL URLWithString:url];
                WebViewController *webCon = [[WebViewController alloc]init];
                [webCon loadWebView:nsurl];
                [self presentViewController:webCon animated:YES completion:^{
                    [self getDeviceMAC:url];
                }];
            }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:NO completion:nil];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self.deviceList dequeueReusableCellWithIdentifier:@"deviceCell"];
    if (cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"deviceCell"];
    }
    if (self.devices!=nil){
        NSArray *keys=[self.devices allKeys];
        [cell.textLabel setText:[[devices objectForKey:keys[indexPath.row]]objectForKey:@"name"]];
        [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        [cell.detailTextLabel setText:[[devices objectForKey:keys[indexPath.row]]objectForKey:@"url"]];
        // date
        //name
        //recent
        //url
    }
    return cell;
}
-(void)updateRecentDevice{
    NSLog(@"update recent device");
    self.devices = [_globalConfig getDevices];
    NSLog(@"device count %d", [[_globalConfig getDevices]count]);
    [self.deviceList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)getDeviceMAC:(NSString*)url{
    if (self.socket==nil){
        self.socket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_queue_create("MAC_queue", NULL)];
    }
    NSError *err = nil;
    //NSLog(@"url: %@",url);
    url=[url substringFromIndex:7];
    if (![socket connectToHost:[url componentsSeparatedByString:@":"][0] onPort:80 error:&err]){
        NSLog(@"connect to get MAC failed:%@",err);
    }
    
}
- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSString *url=@"GET /MAC.html HTTP/1.0\r\n\r\n";
    [self.socket writeData:[url dataUsingEncoding:NSUTF8StringEncoding] withTimeout:15 tag:writeMacCommandTag];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // read data
    NSLog(@"delegate: receive data");
    if (tag==readMacHeaderTag){
        [self.socket readDataWithTimeout:-1 tag:readMacContentTag];
    }else if (tag==readMacContentTag){
        if (data != nil) {
            //NSLog([data description]);
            NSString *mac=[self parseMAC:data];
            if (![mac isEqualToString:@""]){
                DBHelper *helper=[DBHelper newInstance];
                NSArray *keys=[self.devices allKeys];
                NSString *url=[[self.devices objectForKey:keys[path]]objectForKey:@"url"];
                NSString *name=[[self.devices objectForKey:keys[path]]objectForKey:@"name"];
                [helper openDataBase];
                [helper saveDeviceWithMAC:mac name:name host:url];
                [helper closeDataBase];
            }
        }
        [self.socket disconnect];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"disconnect with error: %@", err);
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == writeMacCommandTag) {
        NSLog(@"write sccuess");
        [self.socket readDataWithTimeout:-1 tag:readMacHeaderTag];
    }
}

-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    NSLog(@"read timeout method called");
    return -1;
}

-(NSString *)parseMAC:(NSData *)data{
    NSLog(@"parseMAC");
    const unsigned *macBytes = [data bytes];
    if (macBytes!=nil) {
        NSString *MAC =[NSString stringWithUTF8String:macBytes];
        return [MAC uppercaseString];
    }
    else {return @"";}
}
-(void)syncDevice{
    //NSMutableDictionary *js_dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"YES",@"Initial", nil];
    //NSError *err = nil;
    
    NSString *urlString=@"http://ecoacloud.com:80/cloudserver/Fuego_Sync";
    NSURL *url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textfieldshouldreturn");
    [textField resignFirstResponder];
    return YES;
}


@end

