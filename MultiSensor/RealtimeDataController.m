//
//  RealtimeDataController.m
//  MultiSensor
//
//  Created by Apple on 2016/9/19.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "RealtimeDataController.h"

@interface RealtimeDataController() <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate, CLLocationManagerDelegate>

@end

@implementation RealtimeDataController

@synthesize pm25;
@synthesize CO;
@synthesize CO2;
@synthesize pressure;
@synthesize temp;
@synthesize humi;
@synthesize gas;
@synthesize VOC;
@synthesize outdoor;
@synthesize indoor;
@synthesize socket;
@synthesize wifiReachability;
@synthesize cache;
@synthesize PIR;
@synthesize fire;
@synthesize icon;

CLLocationManager *locationManager;//ios corelocation
BOOL pauseUpdate;//stop update data
NSString *mac;

-(void)viewDidLoad{
    self.socket =nil;
    NSUserDefaults *nd=[NSUserDefaults standardUserDefaults];
    mac=[nd objectForKey:@"mac"];
    NSLog(@"mac%@", mac);
    pauseUpdate=NO;
    UIImage *backg=[UIImage imageNamed:@"realtimebackground"];
    self.view.layer.contents=(id)backg.CGImage;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"UPDATE_DATA" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"UPDATE_OUTDOOR" object:nil];
    [pm25 setBackgroundColor:Default_Color];
    [pm25 setText:NSLocalizedString(@"no_data",@"")];
    pm25.numberOfLines=0;
    [CO setBackgroundColor:Default_Color];
    [CO setText:NSLocalizedString(@"no_data",@"")];
    CO.numberOfLines=0;
    [CO2 setBackgroundColor:Default_Color];
    [CO2 setText:NSLocalizedString(@"no_data", @"")];
    CO2.numberOfLines=0;
    [pressure setBackgroundColor:Default_Color];
    [pressure setText:NSLocalizedString(@"no_data", @"")];
    pressure.numberOfLines=0;
    [temp setBackgroundColor:Default_Color];
    [temp setText:NSLocalizedString(@"no_data", @"")];
    temp.numberOfLines=0;
    [humi setBackgroundColor:Default_Color];
    [humi setText:NSLocalizedString(@"no_data", @"")];
    humi.numberOfLines=0;
    [gas setBackgroundColor:Default_Color];
    [gas setText:NSLocalizedString(@"no_data", @"")];
    gas.numberOfLines=0;
    [VOC setBackgroundColor:Default_Color];
    [VOC setText:NSLocalizedString(@"no_data", @"")];
    VOC.numberOfLines=0;
    [outdoor setTag:outdoorTag];
    [indoor setTag:indoorTag];
    [PIR setImage:[UIImage imageNamed:@"pir_off"]];
    PIR.contentMode=UIViewContentModeScaleAspectFit;
    [fire setImage:[UIImage imageNamed:@"fire_off"]];
    fire.contentMode=UIViewContentModeScaleAspectFit;
    [icon setImage:[UIImage imageNamed:@"icon"]];
    icon.contentMode=UIViewContentModeScaleAspectFit;
    [self uploadToken];
    self.wifiReachability=[Reachability reachabilityForLocalWiFi];// check local wifi avaliable
    [self.wifiReachability startNotifier];
    [self.wifiReachability currentReachabilityStatus];
    if ([Reachability reachabilityForLocalWiFi]){
        NSLog(@"self startUDPListener");
        if (mac==nil&&![mac isEqualToString:@""]){
            NSLog(@"mac not exists");
        }
        else {
            [self startUDPListener];
        }
    }else {
        
    }
    cache=[[NSMutableArray alloc]initWithCapacity:8];
    
    //CLLocationmanager 獲取用戶位置
    locationManager=[[CLLocationManager alloc]init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        NSLog(@"request locationamanger authorization");
        [locationManager requestAlwaysAuthorization];//給ios8以上版本使用。
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    if (self.socket){
        NSLog(@"stop socket");
        [self.socket pauseReceiving];
        [self.socket close];
    }
    [self.wifiReachability stopNotifier];
}

-(void)startUDPListener{
    self.socket=[[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *err=nil;
    if (![self.socket bindToPort:14377 error:&err]){
        NSLog(@"bindToPort failed, error: %@", err);
        return;
    }
    [self ListenToUDP:self.socket];
}

-(void)ListenToUDP:(GCDAsyncUdpSocket *)udpsocket{
    NSLog(@"listening udp packet");
    NSError *err=nil;
    if (![self.socket beginReceiving:&err]){
        NSLog(@"beginReceiving error: %@", err);
    }
}

-(void)readUDPPacket:(NSData *)packet{
    //NSLog(@"read udp packet");
    NSInteger length=[packet length];
    //NSLog(@"length %d", length);
    if (length > 0) {
        Byte *buff =(Byte*)malloc(length);
        [packet getBytes:buff length:length];
        if ((buff[2]&0xFF)==255&&(buff[3]&0xFF)==254) {
            //int totalLength=(buff[0]&0xFF)<<8|(buff[1]&0xFF);
            //if (totalLength!=length);
            //NSString *Id=[NSString stringWithFormat:@"%c%c",(buff[5]&0xFF),(buff[6]&0xFF)];
            //NSString *group=[NSString stringWithFormat:@"%c", (buff[8]&0xFF)];
            if ((buff[9]&0xFF)==119) {
                //NSLog(@"read ok");
                NSString *decodeMAC = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X", buff[10], buff[11], buff[12], buff[13], buff[14], buff[15]];
                //NSLog(@"mac: %@",decodeMAC);
                if (![[mac uppercaseString]isEqualToString:[decodeMAC uppercaseString]]){
                    return;
                }
                int namelength=(buff[17]&0xFF);
                Byte *namebuf=(Byte*)malloc(namelength);
                for (int i=0;i<namelength;i++){
                    namebuf[i]=buff[18+i];
                }
                //NSString *name=[[NSString alloc]initWithBytes:namebuf length:namelength encoding:NSUTF8StringEncoding];
                NSMutableDictionary *jsob=[self readBytes:buff withLength:length startOffset:namelength+18];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"UPDATE_DATA" object:jsob];
            }
            else {
                NSLog(@"read not ok");
            }
        }
        else {
            NSLog(@"%c",buff[2]);
        }
    }
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    if (address != nil){
       // NSLog(@"address: %@", [[NSString alloc]initWithData:address encoding:NSUTF8StringEncoding]);
    }
   // NSLog(@"udp didReceiveData");
    //NSLog(@"data: %@", [[NSString alloc]initWithData:data]);
    [self readUDPPacket:data];
}

-(IBAction)buttonAction:(id)sender{
    if ([sender tag]==indoorTag) {
        NSLog(@"indoor");
        //do indoor thing
        [self applyCache];
        pauseUpdate=NO;
        UIImage *backg=[UIImage imageNamed:@"realtimebackground"];
        self.view.layer.contents=(id)backg.CGImage;
    }
    else if ([sender tag]==outdoorTag) {
        NSLog(@"outdoor");
        UIImage *backg=[UIImage imageNamed:@"outdoorbackground"];
        self.view.layer.contents=(id)backg.CGImage;
        [self holdCache];
        pauseUpdate=YES;
        [self openData];
    }
}

- (NSMutableDictionary *)readBytes:(Byte *)byte withLength:(NSUInteger)length startOffset:(NSUInteger)offset{
    NSMutableDictionary *jsob=[[NSMutableDictionary alloc]init];
    NSUInteger ilength=length;
    NSUInteger idx=offset;
    NSString *addr=@"",*value=@"";
    while (idx<ilength){
        if (byte[idx]==(Byte)0x73){
            addr=[NSString stringWithFormat:@"%d",(byte[idx+1]&0xFF)];
            value=[NSString stringWithFormat:@"%d",(byte[idx+2]&0xFF)];
            idx+=3;
        }
        else if (byte[idx]==(Byte)0x74){
            addr=[NSString stringWithFormat:@"%d",(byte[idx+1]&0xFF)];
            value=[NSString stringWithFormat:@"%d",(byte[idx+2]&0xFF)];
            idx+=3;
        }
        else if (byte[idx]==(Byte)0x75){
            addr=[NSString stringWithFormat:@"%d",((byte[idx+1]&0xFF)<<8|(byte[idx+2]&0xFF))];
            value=[NSString stringWithFormat:@"%d",((byte[idx+3&0xFF])<<8|(byte[idx+4]&0xFF))];
            idx+=5;
        }
        else if (byte[idx]==(Byte)0x76){
            addr=[NSString stringWithFormat:@"%d",((byte[idx+1]&0xFF)<<8|(byte[idx+2]&0xFF))];
            value=[NSString stringWithFormat:@"%d",((byte[idx+3&0xFF])<<8|(byte[idx+4]&0xFF))];
            idx+=5;
        }
        else {
            idx++;
        }
        [jsob setObject:value forKey:addr];
    }
    return jsob;
}

-(void)receiveNotification:(NSNotification*)notify{
    //NSLog(@"notification receive");
    if([notify.name isEqualToString:@"UPDATE_DATA"]){
        NSMutableDictionary *jsob=[notify object];
        if (jsob==nil)
            return;
        NSUserDefaults *nd=[NSUserDefaults standardUserDefaults];
        if(!([nd objectForKey:@"COOfs"]!=nil)){
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
            [nd setObject:[jsob objectForKey:@"40024"] forKey:@"DustAlmHigh2"];
            if(![nd synchronize]){
                NSLog(@"initial setting synchronize failed");
            }
        }
        if (!pauseUpdate){
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[jsob objectForKey:@"6"]integerValue]==1){
                    [PIR setImage:[UIImage imageNamed:@"pir_on"]];
                }
                else if ([[jsob objectForKey:@"6"]integerValue]==0){
                    [PIR setImage:[UIImage imageNamed:@"pir_off"]];
                }
                if ([[jsob objectForKey:@"5"]integerValue]==1){
                    [fire setImage:[UIImage imageNamed:@"fire_on"]];
                }
                else if ([[jsob objectForKey:@"5"]integerValue]==0){
                    [fire setImage:[UIImage imageNamed:@"fire_off"]];
                }
                [CO2 setText:[NSString stringWithFormat:@"%@ \n%@ ppm",NSLocalizedString(@"co2", @""),[jsob objectForKey:@"40025"]]];
                [pm25 setText:[NSString stringWithFormat:@"PM2.5 \n%@ μg/m3",[jsob objectForKey:@"40026"]]];
                NSString *value=[jsob objectForKey:@"40027"];
                [pressure setText:[NSString stringWithFormat:@"%@ \n%.2f hPa",NSLocalizedString(@"press",@"") ,([value floatValue]/10.0)]];
                [CO setText:[NSString stringWithFormat:@"%@ \n%@ ppm",NSLocalizedString(@"co", @""),[jsob objectForKey:@"40028"]]];
                value=[jsob objectForKey:@"40029"];
                [VOC setText:[NSString stringWithFormat:@"%@ \n%d ppm",NSLocalizedString(@"voc", @""),([value integerValue]/10)]];
                value=[jsob objectForKey:@"40030"];
                [temp setText:[NSString stringWithFormat:@"%@ \n%.2f°C",NSLocalizedString(@"temp", @""),([value floatValue]/100.0)]];
                value=[jsob objectForKey:@"40031"];
                [humi setText:[NSString stringWithFormat:@"%@ \n%.2f RH%%",NSLocalizedString(@"humi", @""),([value floatValue]/10.0)]];
                [gas setText:[NSString stringWithFormat:@"%@ \n%@ ppm",NSLocalizedString(@"gas", @""),[jsob objectForKey:@"40032"]]];
                [humi setBackgroundColor:Default_Color];
                [pressure setBackgroundColor:Default_Color];
            int co2Value=[CO2.text integerValue];
            int coValue=[CO.text integerValue];
            int pm25Value=[pm25.text integerValue];
            float vocValue=[VOC.text floatValue];
            float tempValue=[temp.text integerValue];
            int gasValue=[gas.text integerValue];
            if (co2Value<800)
                [CO2 setBackgroundColor:PM25_Level_0];
            else if (800<=co2Value&&co2Value<1000)
                [CO2 setBackgroundColor:PM25_Level_1];
            else if (1000<=co2Value&&co2Value<1500)
                [CO2 setBackgroundColor:PM25_Level_2];
            else if (1500<=co2Value)
                [CO2 setBackgroundColor:PM25_Level_3];
            if(pm25Value<35)
                [pm25 setBackgroundColor:PM25_Level_0];
            else if(35<=pm25Value&&pm25Value<53)
                [pm25 setBackgroundColor:PM25_Level_1];
            else if(53<=pm25Value&&pm25Value<70)
                [pm25 setBackgroundColor:PM25_Level_2];
            else if(pm25Value>=70)
                [pm25 setBackgroundColor:PM25_Level_3];
            if (coValue<2)
                [CO setBackgroundColor:PM25_Level_0];
            else if(2<=coValue&&coValue<5)
                [CO setBackgroundColor:PM25_Level_1];
            else if(5<=coValue&&coValue<10)
                [CO setBackgroundColor:PM25_Level_2];
            else if(10<=coValue)
                [CO setBackgroundColor:PM25_Level_3];
            if(vocValue<10.0)
                [VOC setBackgroundColor:PM25_Level_0];
            else if(10.0<=vocValue&&vocValue<20.0)
                [VOC setBackgroundColor:PM25_Level_1];
            else if(20.0<=vocValue&&vocValue<29.0)
                [VOC setBackgroundColor:PM25_Level_2];
            else if(29.0<=vocValue)
                [VOC setBackgroundColor:PM25_Level_3];
            if(tempValue<4500.0)
                [temp setBackgroundColor:PM25_Level_0];
            else if(4500.0<=tempValue&&tempValue<5500.0)
                [temp setBackgroundColor:PM25_Level_1];
            else if(5500.0<=tempValue&&tempValue>6500.0)
                [temp setBackgroundColor:PM25_Level_2];
            else if(6500<=tempValue)
                [temp setBackgroundColor:PM25_Level_3];
            if(gasValue<500)
                [gas setBackgroundColor:PM25_Level_0];
            else if(500<=gasValue&&gasValue<1000)
                [gas setBackgroundColor:PM25_Level_1];
            else if(1000<=gasValue&&gasValue<2000)
                [gas setBackgroundColor:PM25_Level_2];
            else if(gasValue>2000)
                [gas setBackgroundColor:PM25_Level_3];
            });
            
        }
    }
    else if([notify.name isEqualToString:@"UPDATE_OUTDOOR"]){
        NSMutableDictionary *jsob=[notify object];
        if (jsob==nil)
            return;
        //NSLog(@"%@",[jsob description]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [pm25 setText:[NSString stringWithFormat:@"PM2.5\n%@ ppm",[jsob objectForKey:@"PM2.5"]]];
            [CO2 setText:[NSString stringWithFormat:@"SO2\n%@ ppm",[jsob objectForKey:@"SO2"]]];
            [CO setText:[NSString stringWithFormat:@"CO\n%@ ppm",[jsob objectForKey:@"CO"]]];
            [temp setText:[NSString stringWithFormat:@"O3\n%@ ppm",[jsob objectForKey:@"O3"]]];
            [humi setText:[NSString stringWithFormat:@"NO2\n%@ ppm",[jsob objectForKey:@"NO2"]]];
            [gas setText:[NSString stringWithFormat:@"NOx\n%@ ppm",[jsob objectForKey:@"NOx"]]];
            [VOC setText:[NSString stringWithFormat:@"NO\n%@ ppm",[jsob objectForKey:@"NO"]]];
            [pressure setText:[NSString stringWithFormat:@"PM10\n %@ ppm",[jsob objectForKey:@"PM10"]]];
            [pm25 setBackgroundColor:PM25_Level_1];
            [CO2 setBackgroundColor:PM25_Level_1];
            [CO setBackgroundColor:PM25_Level_1];
            [temp setBackgroundColor:PM25_Level_1];
            [humi setBackgroundColor:PM25_Level_1];
            [gas setBackgroundColor:PM25_Level_1];
            [VOC setBackgroundColor:PM25_Level_1];
            [pressure setBackgroundColor:PM25_Level_1];
        });
    }
}

-(void)uploadToken{
    NSUserDefaults *nd=[NSUserDefaults standardUserDefaults];
    if([nd objectForKey:@"APNS_TOKEN"]!=nil&&[nd objectForKey:@"mac"]){
        NSLog(@"upload token");
        NSString *token=[nd stringForKey:@"APNS_TOKEN"];
        NSString *mac=[nd stringForKey:@"mac"];
        NSDictionary *js_dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                token,@"token",
                                mac, @"macaddr",
                                @"iOS", @"type", nil];
        // upload token
        NSError *error;
        NSData *post_data = [NSJSONSerialization dataWithJSONObject:js_dic options:0 error:&error];
        NSURL *URL = [NSURL URLWithString:@"http://ecoacloud.com:80/cloudserver/fuego"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", post_data.length] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:post_data];
        NSURLConnection *connect = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    }
}

-(void)readDataFromDatabase{
    if (mac!=nil&&![mac isEqualToString:@""]){
        DBHelper *helper=[DBHelper newInstance];
        [helper openDataBase];
        FMResultSet *rs=[helper getHistoryData:mac];
        if (rs!=nil&&[rs columnCount]>0){
            [CO2 setText:[NSString stringWithFormat:@"%@ \n%@ ppm",NSLocalizedString(@"co2", @""),[rs objectForColumnName:@"40025"]]];
            [pm25 setText:[NSString stringWithFormat:@"PM2.5 \n%@ μg/m3",[rs objectForColumnName:@"40026"]]];
            NSString *value=[rs objectForColumnName:@"40027"];
            [pressure setText:[NSString stringWithFormat:@"%@ \n%.2f hPa",NSLocalizedString(@"press",@"") ,([value floatValue]/10.0)]];
            [CO setText:[NSString stringWithFormat:@"%@ \n%@ ppm",NSLocalizedString(@"co", @""),[rs objectForColumnName:@"40028"]]];
            value=[rs objectForColumnName:@"40029"];
            [VOC setText:[NSString stringWithFormat:@"%@ \n%d ppm",NSLocalizedString(@"voc", @""),([value integerValue]/10)]];
            value=[rs objectForColumnName:@"40030"];
            [temp setText:[NSString stringWithFormat:@"%@ \n%.2f°C",NSLocalizedString(@"temp", @""),([value floatValue]/100.0)]];
            value=[rs objectForColumnName:@"40031"];
            [humi setText:[NSString stringWithFormat:@"%@ \n%.2f RH%%",NSLocalizedString(@"humi", @""),([value floatValue]/10.0)]];
            [gas setText:[NSString stringWithFormat:@"%@ \n%@ ppm",NSLocalizedString(@"gas", @""),[rs objectForColumnName:@"40032"]]];
            int co2Value=[CO2.text integerValue];
            int coValue=[CO.text integerValue];
            int pm25Value=[pm25.text integerValue];
            float vocValue=[VOC.text floatValue];
            float tempValue=[temp.text integerValue];
            int gasValue=[gas.text integerValue];
            if (co2Value<800)
                [CO2 setBackgroundColor:PM25_Level_0];
            else if (800<=co2Value&&co2Value<1000)
                [CO2 setBackgroundColor:PM25_Level_1];
            else if (1000<=co2Value&&co2Value<1500)
                [CO2 setBackgroundColor:PM25_Level_2];
            else if (1500<=co2Value)
                [CO2 setBackgroundColor:PM25_Level_3];
            if(pm25Value<35)
                [pm25 setBackgroundColor:PM25_Level_0];
            else if(35<=pm25Value&&pm25Value<53)
                [pm25 setBackgroundColor:PM25_Level_1];
            else if(53<=pm25Value&&pm25Value<70)
                [pm25 setBackgroundColor:PM25_Level_2];
            else if(pm25Value>=70)
                [pm25 setBackgroundColor:PM25_Level_3];
            if (coValue<2)
                [CO setBackgroundColor:PM25_Level_0];
            else if(2<=coValue&&coValue<5)
                [CO setBackgroundColor:PM25_Level_1];
            else if(5<=coValue&&coValue<10)
                [CO setBackgroundColor:PM25_Level_2];
            else if(10<=coValue)
                [CO setBackgroundColor:PM25_Level_3];
            if(vocValue<10.0)
                [VOC setBackgroundColor:PM25_Level_0];
            else if(10.0<=vocValue&&vocValue<20.0)
                [VOC setBackgroundColor:PM25_Level_1];
            else if(20.0<=vocValue&&vocValue<29.0)
                [VOC setBackgroundColor:PM25_Level_2];
            else if(29.0<=vocValue)
                [VOC setBackgroundColor:PM25_Level_3];
            if(tempValue<4500.0)
                [temp setBackgroundColor:PM25_Level_0];
            else if(4500.0<=tempValue&&tempValue<5500.0)
                [temp setBackgroundColor:PM25_Level_1];
            else if(5500.0<=tempValue&&tempValue>6500.0)
                [temp setBackgroundColor:PM25_Level_2];
            else if(6500<=tempValue)
                [temp setBackgroundColor:PM25_Level_3];
            if(gasValue<500)
                [gas setBackgroundColor:PM25_Level_0];
            else if(500<=gasValue&&gasValue<1000)
                [gas setBackgroundColor:PM25_Level_1];
            else if(1000<=gasValue&&gasValue<2000)
                [gas setBackgroundColor:PM25_Level_2];
            else if(gasValue>2000)
                [gas setBackgroundColor:PM25_Level_3];
        }
        [rs close];
        [helper closeDataBase];
    }
}

-(void)openData{
    // 呼叫定位
    if (locationManager!=nil){
        NSLog(@"start updating location");
        [locationManager startUpdatingLocation];
    }
}

-(void)holdCache{
    [cache insertObject:[pm25 text] atIndex:0];
    [cache insertObject:[pressure text] atIndex:1];
    [cache insertObject:[CO text] atIndex:2];
    [cache insertObject:[CO2 text] atIndex:3];
    [cache insertObject:[VOC text] atIndex:4];
    [cache insertObject:[temp text] atIndex:5];
    [cache insertObject:[humi text] atIndex:6];
    [cache insertObject:[gas text] atIndex:7];
}

-(void)applyCache{
    [pm25 setText:[cache objectAtIndex:0]];
    [pressure setText:[cache objectAtIndex:1]];
    [CO setText:[cache objectAtIndex:2]];
    [CO2 setText:[cache objectAtIndex:3]];
    [VOC setText:[cache objectAtIndex:4]];
    [temp setText:[cache objectAtIndex:5]];
    [humi setText:[cache objectAtIndex:6]];
    [gas setText:[cache objectAtIndex:7]];
}

// CLLocationManagerDelegate 代理方法
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(nonnull CLLocation *)newLocation fromLocation:(nonnull CLLocation *)oldLocation{
    NSLog(@"locationmanager didupdatetolocation");
    CLGeocoder *gecoder=[[CLGeocoder alloc] init];
    //根據經緯度取得地址
    [gecoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray* _Nullable placemarks, NSError * _Nullable error) {
        //可能出現多個結果
        CLPlacemark *placeMark=[placemarks objectAtIndex:0];
        //NSLog([placeMark.addressDictionary objectForKey:@"State"]);
        //NSString *stateStr=[placeMark.addressDictionary objectForKey:@"State"];
        NSString *cityStr=[placeMark.addressDictionary objectForKey:@"City"];
        // openData平台 AQI資料集 url
        NSString *token=@"hni1KsKTO0S1QAPDtBco9Q";
        NSString *url=@"http://opendata.epa.gov.tw/webapi/api/rest/datastore/355000000I-001805/?format=json&token=";
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url,token]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        NSURLSession *session=[NSURLSession sharedSession];
        NSURLSessionDataTask *sessionTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if (data!=nil){
                //讀取AQI資料
                NSError *j_er=nil;
                NSDictionary *js_dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&j_er];
                if (js_dic!=nil){
                    //NSLog(@"%@", [js_dic description]);
                    NSMutableArray *records=[[js_dic objectForKey:@"result"] objectForKey:@"records"];
                    //NSLog(@"%@", [records description]);
                    BOOL match=NO;
                    for (int i=0;i<[records count];i++){
                        NSString *siteName=[[records objectAtIndex:i]objectForKey:@"SiteName"];
                        //NSLog(siteName);
                        if([cityStr containsString:siteName]){
                            match=YES;
                            NSString *data=[records objectAtIndex:i];
                            //NSLog(@"string of data:%@", data);
                            //站點名稱與geocoder取得地名相同
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"UPDATE_OUTDOOR" object:data];
                        }
                        if(match){
                            i=[records count];
                        }
                    }
                }
                else if(j_er!=nil){
                }
            }
        }];
        [sessionTask resume];
    }];
    //取得第一個結果後停止更新
    [manager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}
@end

