//
//  SettingViewController.m
//  MultiSensor
//
//  Created by Apple on 2016/12/5.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "SettingViewController.h"

@implementation SettingViewController

@synthesize co2;
@synthesize co;
@synthesize pm25;
@synthesize press;
@synthesize iaq;
@synthesize temp;
@synthesize humi;
@synthesize gas;
@synthesize fans;
@synthesize pirs;
@synthesize pird;
@synthesize tah;
@synthesize tal;
@synthesize vah;
@synthesize vah2;
@synthesize c2ah;
@synthesize c2ah2;
@synthesize cah;
@synthesize cah2;
@synthesize gah;
@synthesize gah2;
@synthesize dah;
@synthesize dah2;

@synthesize co2L;
@synthesize coL;
@synthesize pm25L;
@synthesize pressL;
@synthesize iaqL;
@synthesize tempL;
@synthesize humiL;
@synthesize gasL;
@synthesize fansL;
@synthesize pirsL;
@synthesize pirdL;
@synthesize tahL;
@synthesize talL;
@synthesize vahL;
@synthesize vah2L;
@synthesize c2ahL;
@synthesize c2ah2L;
@synthesize cahL;
@synthesize cah2L;
@synthesize gahL;
@synthesize gah2L;
@synthesize dahL;
@synthesize dah2L;
@synthesize save;

-(void)viewDidLoad{
    NSLog(@"settingview viewdidload");
    [co2L setText:NSLocalizedString(@"setting_co2ofs", @"")];
    [coL setText:NSLocalizedString(@"setting_coofs", @"")];
    [pm25L setText:NSLocalizedString(@"setting_pm25ofs", @"")];
    [pressL setText:NSLocalizedString(@"setting_pressofs", @"")];
    [iaqL setText:NSLocalizedString(@"setting_iaqofs", @"")];
    [tempL setText:NSLocalizedString(@"setting_tempofs", @"")];
    [humiL setText:NSLocalizedString(@"setting_humiofs", @"")];
    [gasL setText:NSLocalizedString(@"setting_gasofs", @"")];
    [fansL setText:NSLocalizedString(@"setting_fanspeed", @"")];
    [pirsL setText:NSLocalizedString(@"setting_pirsensitive", @"")];
    [pirdL setText:NSLocalizedString(@"setting_pirdelay", @"")];
    [tahL setText:NSLocalizedString(@"setting_tempalmhigh", @"")];
    [talL setText:NSLocalizedString(@"setting_tempalmlow", @"")];
    [vahL setText:NSLocalizedString(@"setting_vocalmhigh", @"")];
    [vah2L setText:NSLocalizedString(@"setting_vocalmhigh2", @"")];
    [c2ahL setText:NSLocalizedString(@"setting_co2almhigh", @"")];
    [c2ah2L setText:NSLocalizedString(@"setting_co2almhigh2", @"")];
    [cahL setText:NSLocalizedString(@"setting_coalmhigh", @"")];
    [cah2L setText:NSLocalizedString(@"setting_coalmhigh2", @"")];
    [gahL setText:NSLocalizedString(@"setting_gasalmhigh", @"")];
    [gah2L setText:NSLocalizedString(@"setting_gasalmhigh2", @"")];
    [dahL setText:NSLocalizedString(@"setting_dustalmhigh", @"")];
    [dah2L setText:NSLocalizedString(@"setting_dustalmhigh2", @"")];
    [save setTitle:NSLocalizedString(@"setting_save", @"") forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    [self readSetting];
}

-(void)readSetting{
    NSUserDefaults *nd=[NSUserDefaults standardUserDefaults];
    [co2 setText:[nd stringForKey:@"CO2Ofs"]];
    [co2 setDelegate:self];
    [pm25 setText:[nd stringForKey:@"DustOfs"]];
    [pm25 setDelegate:self];
    [press setText:[nd stringForKey:@"pressOfs"]];
    [press setDelegate:self];
    [co setText:[nd stringForKey:@"COOfs"]];
    [co setDelegate:self];
    [iaq setText:[nd stringForKey:@"IaqOfs"]];
    [iaq setDelegate:self];
    [temp setText:[nd stringForKey:@"TempOfs"]];
    [temp setDelegate:self];
    [humi setText:[nd stringForKey:@"HumiOfs"]];
    [humi setDelegate:self];
    [gas setText:[nd stringForKey:@"GasOfs"]];
    [gas setDelegate:self];
    [fans setText:[nd stringForKey:@"FanSpeed"]];
    [fans setDelegate:self];
    [pirs setText:[nd stringForKey:@"PirSensitive"]];
    [pirs setDelegate:self];
    [pird setText:[nd stringForKey:@"PirDelay"]];
    [pird setDelegate:self];
    [tah setText:[nd stringForKey:@"TempAlmHigh"]];
    [tah setDelegate:self];
    [tal setText:[nd stringForKey:@"TempAlmLow"]];
    [tal setDelegate:self];
    [vah setText:[nd stringForKey:@"VocAlmHigh"]];
    [vah setDelegate:self];
    [vah2 setText:[nd stringForKey:@"VocAlmHigh2"]];
    [vah2 setDelegate:self];
    [c2ah setText:[nd stringForKey:@"CO2AlmStep1"]];
    [c2ah setDelegate:self];
    [c2ah2 setText:[nd stringForKey:@"CO2AlmStep2"]];
    [c2ah2 setDelegate:self];
    [cah setText:[nd stringForKey:@"COAlmHigh"]];
    [cah setDelegate:self];
    [cah2 setText:[nd stringForKey:@"COAlmHigh2"]];
    [cah2 setDelegate:self];
    [gah setText:[nd stringForKey:@"GasAlmHigh"]];
    [gah setDelegate:self];
    [gah2 setText:[nd stringForKey:@"GasAlmHigh2"]];
    [gah2 setDelegate:self];
    [dah setText:[nd stringForKey:@"DustAlmHigh"]];
    [dah setDelegate:self];
    [dah2 setText:[nd stringForKey:@"DustAlmHigh2"]];
    [dah2 setDelegate:self];
}

-(void)saveSetting{
    NSLog(@"saveSetting");
    NSUserDefaults *nd=[NSUserDefaults standardUserDefaults];
    [nd setValue:[co2 text] forKey:@"CO2Ofs"];
    [nd setValue:[pm25 text] forKey:@"DustOfs"];
    [nd setValue:[press text] forKey:@"pressOfs"];
    [nd setValue:[co text] forKey:@"COOfs"];
    [nd setValue:[iaq text] forKey:@"IaqOfs"];
    [nd setValue:[temp text] forKey:@"TempOfs"];
    [nd setValue:[humi text] forKey:@"HumiOfs"];
    [nd setValue:[gas text] forKey:@"GasOfs"];
    [nd setValue:[fans text] forKey:@"FanSpeed"];
    [nd setValue:[pirs text] forKey:@"PirSensitive"];
    [nd setValue:[pird text] forKey:@"PirDelay"];
    [nd setValue:[tah text] forKey:@"TempAlmHigh"];
    [nd setValue:[tal text] forKey:@"TempAlmLow"];
    [nd setValue:[vah text] forKey:@"VocAlmHigh"];
    [nd setValue:[vah2 text] forKey:@"VocAlmHigh2"];
    [nd setValue:[c2ah text] forKey:@"CO2AlmStep1"];
    [nd setValue:[c2ah2 text] forKey:@"CO2AlmStep2"];
    [nd setValue:[cah text] forKey:@"COAlmHigh"];
    [nd setValue:[cah2 text] forKey:@"COAlmHigh2"];
    [nd setValue:[gah text] forKey:@"GasAlmHigh"];
    [nd setValue:[gah2 text] forKey:@"GasAlmHigh2"];
    [nd setValue:[dah text] forKey:@"DustAlmHigh"];
    [nd setValue:[dah2 text] forKey:@"DustAlmHigh2"];
    if(![nd synchronize]){
        NSLog(@"saveSetting synchroize failed");
    }
    NSMutableDictionary *js_dic=[[NSMutableDictionary alloc]init];
    [js_dic setObject:@"0" forKey:@"40001"];
    [js_dic setObject:[co2 text] forKey:@"40002"];
    [js_dic setObject:[pm25 text] forKey:@"40003"];
    [js_dic setObject:[press text] forKey:@"40004"];
    [js_dic setObject:[co text] forKey:@"40005"];
    [js_dic setObject:[iaq text] forKey:@"40006"];
    [js_dic setObject:[temp text] forKey:@"40007"];
    [js_dic setObject:[humi text] forKey:@"40008"];
    [js_dic setObject:[gas text] forKey:@"40009"];
    [js_dic setObject:[fans text] forKey:@"40010"];
    [js_dic setObject:[pirs text] forKey:@"40011"];
    [js_dic setObject:[pird text] forKey:@"40012"];
    [js_dic setObject:[tah text] forKey:@"40013"];
    [js_dic setObject:[tal text] forKey:@"40014"];
    [js_dic setObject:[vah text] forKey:@"40015"];
    [js_dic setObject:[vah2 text] forKey:@"40016"];
    [js_dic setObject:[c2ah text] forKey:@"40017"];
    [js_dic setObject:[c2ah2 text] forKey:@"40018"];
    [js_dic setObject:[cah text] forKey:@"40019"];
    [js_dic setObject:[cah2 text] forKey:@"40020"];
    [js_dic setObject:[gah text] forKey:@"40021"];
    [js_dic setObject:[gah2 text] forKey:@"40022"];
    [js_dic setObject:[dah text] forKey:@"40023"];
    [js_dic setObject:[dah2 text] forKey:@"40024"];
    [js_dic setObject:@"yes" forKey:@"Setting"];
    [js_dic setObject:[nd objectForKey:@"mac"] forKey:@"macaddr"];
    //ndic
    NSError *err = nil;
    NSData *post_data = [NSJSONSerialization dataWithJSONObject:js_dic options:0 error:&err];NSString *urlString=@"http://ecoacloud.com:80/cloudserver/fuego";
    NSURL *url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", post_data.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:post_data];
    //NSURLConnection *connect = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDataTask *task=[session dataTaskWithRequest:request];
    [task resume];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
