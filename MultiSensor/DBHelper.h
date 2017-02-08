//
//  DBHelper.h
//  MultiSensor
//
//  Created by Apple on 2016/11/23.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface DBHelper : NSObject {
    FMDatabase *db;
    BOOL opened;
}

- (void) openDataBase;
- (void) closeDataBase;
- (void) createDataBase;
-(FMResultSet*)getDayMax:(NSString*)mac;
+ (DBHelper *) newInstance;
- (NSString *) getDatabasePath;
-(FMResultSet *)getSensorDevicesList;
-(FMResultSet *)getHistoryData:(NSString *)macaddr;
-(void)saveDeviceWithMAC:(NSString *)macaddr name:(NSString*)devicename host:(NSString*)host;
-(void)saveHistory:(NSString *)query;

@end
