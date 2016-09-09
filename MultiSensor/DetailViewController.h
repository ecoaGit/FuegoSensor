//
//  DetailViewController.h
//  MultiSensor
//
//  Created by Apple on 2016/9/9.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

