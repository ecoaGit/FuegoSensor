//
//  AppDelegate.m
//  MultiSensor
//
//  Created by Apple on 2016/9/9.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    // push notification
    // for iOS 8.0 above
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else { // for below iOS 8.0
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    DBHelper *helper=[DBHelper newInstance];
    [helper createDataBase];
    return YES;
}

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *iosDeviceToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x", ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]), ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:iosDeviceToken forKey:@"APNS_TOKEN"];
    [userDefaults synchronize];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] &&
         [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    //NSLog(@"did receiveremote fetchcompletionhandler");
    if (userInfo!=nil){
        if ([userInfo objectForKey:@"Fuego_alert"]!=nil){
            NSData *nd = [[userInfo objectForKey:@"Fuego_alert"] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jserror;
            NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:nd options:NSJSONReadingMutableContainers error:&jserror];
            //NSLog(@"%@", jsonObj);
            NSString *alarmType = [jsonObj objectForKey:@"type"];
            if([alarmType isEqualToString:@"fuego_sync"]){
                DBHelper *helper=[DBHelper newInstance];
                NSDateFormatter *ndf=[[NSDateFormatter alloc]init];
                [ndf setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                //NSLog(@"%@", [ndf stringFromDate:[NSDate date]]);
                [helper openDataBase];
                NSString *sql=[NSString stringWithFormat:@"INSERT INTO history_data (_date, macaddr, `40025`,`40026`,`40027`,`40028`,`40029`,`40030`,`40031`,`40032`) VALUES ('%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@')",[ndf stringFromDate:[NSDate date]],[jsonObj objectForKey:@"mac"],[jsonObj objectForKey:@"40025"],[jsonObj objectForKey:@"40026"],[jsonObj objectForKey:@"40027"],[jsonObj objectForKey:@"40028"],[jsonObj objectForKey:@"40029"],[jsonObj objectForKey:@"40030"],[jsonObj objectForKey:@"40031"],[jsonObj objectForKey:@"40032"]];
                //NSLog(@"sql:%@",sql);
                [helper saveHistory:sql];
                [helper closeDataBase];
                return;
            }
            else if ([alarmType isEqualToString:@"fuego_alarm"]){
               // NSLog(@"local notif");
                NSString *alarmKey=[jsonObj objectForKey:@"alarm"];
                UILocalNotification *alert=[[UILocalNotification alloc]init];
                alert.timeZone = [NSTimeZone defaultTimeZone];
                alert.repeatInterval = 0;
                alert.alertTitle= @"MultiSensor Notification";
                alert.alertBody = NSLocalizedString(alarmKey,@"alert");
                alert.alertAction = @"Active app";
                alert.applicationIconBadgeNumber = 1;
                alert.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication]presentLocalNotificationNow:alert];
                return;
            }
            else {
                return;
            }
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    if (userInfo!=nil){
        if ([userInfo objectForKey:@"Fuego_alert"]!=nil){
            NSData *nd = [[userInfo objectForKey:@"Fuego_alert"] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jserror;
            NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:nd options:NSJSONReadingMutableContainers error:&jserror];
            NSLog(@"%@", jsonObj);
            NSString *alarmType = [jsonObj objectForKey:@"type"];
            if([alarmType isEqualToString:@"fuego_sync"]){
                DBHelper *helper=[DBHelper newInstance];
                NSDateFormatter *ndf=[[NSDateFormatter alloc]init];
                [ndf setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                //NSLog(@"%@", [ndf stringFromDate:[NSDate date]]);
                [helper openDataBase];
                NSString *sql=[NSString stringWithFormat:@"INSERT INTO history_data (_date, macaddr, `40025`,`40026`,`40027`,`40028`,`40029`,`40030`,`40031`,`40032`) VALUES ('%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@')",[ndf stringFromDate:[NSDate date]],[jsonObj objectForKey:@"mac"],[jsonObj objectForKey:@"40025"],[jsonObj objectForKey:@"40026"],[jsonObj objectForKey:@"40027"],[jsonObj objectForKey:@"40028"],[jsonObj objectForKey:@"40029"],[jsonObj objectForKey:@"40030"],[jsonObj objectForKey:@"40031"],[jsonObj objectForKey:@"40032"]];
                //NSLog(@"sql:%@",sql);
                [helper saveHistory:sql];
                [helper closeDataBase];
                return;
            }
            else if ([alarmType isEqualToString:@"fuego_alarm"]){
                NSLog(@"local notif");
                NSString *alarmKey=[jsonObj objectForKey:@"alarm"];
                UILocalNotification *alert=[[UILocalNotification alloc]init];
                alert.timeZone = [NSTimeZone defaultTimeZone];
                alert.repeatInterval = 0;
                alert.alertTitle= @"MultiSensor Notification";
                alert.alertBody = NSLocalizedString(alarmKey,@"alert");
                alert.alertAction = @"Active app";
                alert.applicationIconBadgeNumber = 1;
                alert.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication]presentLocalNotificationNow:alert];
                return;
            }
            else {
                return;
            }
        }
    }
    return;
}

@end
