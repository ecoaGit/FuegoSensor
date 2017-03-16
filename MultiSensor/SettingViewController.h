//
//  SettingViewController.h
//  MultiSensor
//
//  Created by Apple on 2016/12/5.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate>

@property (nonatomic,retain) IBOutlet UITextField *co2;
@property (nonatomic,retain) IBOutlet UITextField *co;
@property (nonatomic,retain) IBOutlet UITextField *pm25;
@property (nonatomic,retain) IBOutlet UITextField *press;
@property (nonatomic,retain) IBOutlet UITextField *iaq;
@property (nonatomic,retain) IBOutlet UITextField *gas;
@property (nonatomic,retain) IBOutlet UITextField *temp;
@property (nonatomic,retain) IBOutlet UITextField *humi;
@property (nonatomic,retain) IBOutlet UITextField *fans;//fan speed
@property (nonatomic,retain) IBOutlet UITextField *pirs;//pir sensitive
@property (nonatomic,retain) IBOutlet UITextField *pird;//pir delay
@property (nonatomic,retain) IBOutlet UITextField *tah;//temp alm high
@property (nonatomic,retain) IBOutlet UITextField *tal;//temp alm low
@property (nonatomic,retain) IBOutlet UITextField *vah;//voc alm high
@property (nonatomic,retain) IBOutlet UITextField *vah2;//voc alm high 2
@property (nonatomic,retain) IBOutlet UITextField *c2ah;
@property (nonatomic,retain) IBOutlet UITextField *c2ah2;
@property (nonatomic,retain) IBOutlet UITextField *cah;
@property (nonatomic,retain) IBOutlet UITextField *cah2;
@property (nonatomic,retain) IBOutlet UITextField *gah;
@property (nonatomic,retain) IBOutlet UITextField *gah2;
@property (nonatomic,retain) IBOutlet UITextField *dah;
@property (nonatomic,retain) IBOutlet UITextField *dah2;
@property (nonatomic,retain) IBOutlet UILabel *co2L;
@property (nonatomic,retain) IBOutlet UILabel *coL;
@property (nonatomic,retain) IBOutlet UILabel *pm25L;
@property (nonatomic,retain) IBOutlet UILabel *pressL;
@property (nonatomic,retain) IBOutlet UILabel *iaqL;
@property (nonatomic,retain) IBOutlet UILabel *gasL;
@property (nonatomic,retain) IBOutlet UILabel *tempL;
@property (nonatomic,retain) IBOutlet UILabel *humiL;
@property (nonatomic,retain) IBOutlet UILabel *fansL;//fan speed
@property (nonatomic,retain) IBOutlet UILabel *pirsL;//pir sensitive
@property (nonatomic,retain) IBOutlet UILabel *pirdL;//pir delay
@property (nonatomic,retain) IBOutlet UILabel *tahL;//temp alm high
@property (nonatomic,retain) IBOutlet UILabel *talL;//temp alm low
@property (nonatomic,retain) IBOutlet UILabel *vahL;//voc alm high
@property (nonatomic,retain) IBOutlet UILabel *vah2L;//voc alm high 2
@property (nonatomic,retain) IBOutlet UILabel *c2ahL;
@property (nonatomic,retain) IBOutlet UILabel *c2ah2L;
@property (nonatomic,retain) IBOutlet UILabel *cahL;
@property (nonatomic,retain) IBOutlet UILabel *cah2L;
@property (nonatomic,retain) IBOutlet UILabel *gahL;
@property (nonatomic,retain) IBOutlet UILabel *gah2L;
@property (nonatomic,retain) IBOutlet UILabel *dahL;
@property (nonatomic,retain) IBOutlet UILabel *dah2L;
@property (nonatomic,retain) IBOutlet UIButton *save;

@end
