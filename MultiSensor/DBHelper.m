//
//  DBHelper.m
//  MultiSensor
//
//  Created by Apple on 2016/11/23.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper

static DBHelper *sInstance;

- (void) openDataBase{
    if (opened){
        return;
    }
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaMultiSensorDatabase.db"];
    db = [FMDatabase databaseWithPath:dbPath];
    opened = [db open];
    if (opened) {
        NSLog(@"DBHelper: database opened");
    }
    else {
        NSLog(@"DBHelper: failed when opening database");
    }
}
- (void) closeDataBase{
    if (db.open) {
        NSLog(@"DBHelper: database closed");
        [db close];
    }
    return;
}
- (void) createDataBase{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *databasePath = [self getDatabasePath];
    
    // check if database exists
    if ([fileManager fileExistsAtPath:databasePath]) {
        NSLog(@"DBHelper: database already exists");
        return;
    }
    // create database
    db = [FMDatabase databaseWithPath:databasePath];
    if (!db.open) {
        NSLog(@"DBHelper: could not open database");
        return;
    }
    NSLog(@"DBHelper: create table");
    // create sensordevices table
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS sensordevices (_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, macaddr TEXT, devicename TEXT, host TEXT )"];
    // create history table
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS history_data (_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, _date TEXT, macaddr TEXT, `40025` TEXT, `40026` TEXT, `40027` TEXT, `40028` TEXT, `40029` TEXT,`40030` TEXT, `40031` TEXT, `40032` TEXT)"];
    [db close];
}
+ (DBHelper *) newInstance{
    @synchronized (self) {
        if (sInstance == nil) {
            sInstance = [[DBHelper alloc] init];
            //[sInstance createDataBase];
        }
    }
    return sInstance;
}
- (NSString *) getDatabasePath{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaMultiSensorDatabase.db"];
    return dbPath;
}
-(void) saveDeviceWithMAC:(NSString *)macaddr name:(NSString*)devicename host:(NSString*)host{
    if (!db.open){
        NSLog(@"could not open database");
        return;
    }
    int count=[db intForQuery:@"SELECT count(*) FROM sensordevices where macaddr='%@'", macaddr];
    NSString *query;
    if (count==0){
        query=[NSString stringWithFormat:@"INSERT INTO sensordevices (macaddr,devicename,host) VALUES ('%@','%@','%@')", macaddr, devicename, host];
        [self execsql:query];
    }
    else {
        query=[NSString stringWithFormat:@"UPDATE sensordevices SET devicename='%@', host='%@' WHERE macaddr='%@' ;", devicename, host, macaddr];
        [self execsql:query];
    }
}

- (void) saveHistory:(NSString *)query{
    if (!db.open){
        NSLog(@"could not open database");
        return;
    }
    BOOL result=[db executeUpdate:query];
    if (result){
        NSLog(@"save success");
    }
    else {
        NSLog(@"save failed");
    }
}

- (void)execsql:(NSString *)sql{
    NSLog(@"DBHelper: execsql");
    if (db.open) {
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"DBHelper: execsql success");
        }
        else {
            NSLog(@"DBHelper: execsql failed");
        }
    }
    else {
        NSLog(@"DBHelper: open db first");
    }
}

-(FMResultSet *)getSensorDevicesList{
    if (!db.open){
        NSLog(@"DBHelper: could not open databse");
        return nil;
    }
    return [db executeQuery:@"SELECT * FROM sensordevices ORDER by _id"];
}

-(FMResultSet *)getHistoryData:(NSString *)macaddr{
    if (!db.open){
        NSLog(@"could not open database");
        return nil;
    }
    NSLog(@"%@", macaddr);
    FMResultSet *rt=[db executeQuery:[NSString stringWithFormat:@"SELECT * FROM history_data WHERE macaddr ='%@' ORDER by _date", macaddr]];
    NSLog(@"%@",[[db lastError]description]);
    return rt;
}

-(FMResultSet *)getDayMax:(NSString*)mac{
    if (!db.open){
        NSLog(@"DBHelper: could not open databse");
        return nil;
    }
    if(![mac isEqualToString:@""]){
        FMResultSet *rt=[db executeQuery:[NSString stringWithFormat:@"SELECT _date, max(`40025`) as max40025, max(`40026`) as max40026,max(`40027`) as max40027, max(`40028`) as max40028,max(`40029`) as max40029, max(`40030`) as max40030,max(`40031`) as max40031, max(`40032`) as max40032 FROM history_data WHERE macaddr='%@' GROUP by strftime('%%Y-%%m-%%d-%%H',_date) ORDER BY date(_date) ;",mac]];
        NSLog(@"%@",[db lastError]);
        return rt;
    }
    return nil;
}
@end
