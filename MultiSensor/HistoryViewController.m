//
//  HistoryViewController.m
//  MultiSensor
//
//  Created by Apple on 2016/9/20.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController() <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property NSMutableArray *contentChartArray;
@property NSInteger now;
@property (nonatomic,retain) UIPageViewController *pageViewController;
@property (nonatomic,retain) HistoryContentViewController *contentViewController;

@end

@implementation HistoryViewController


-(void)viewDidLoad{
    NSLog(@"HistoryViewController viewdidload");
    NSDictionary *pageOption=@{UIPageViewControllerOptionSpineLocationKey:@(UIPageViewControllerSpineLocationMin)};
    self.pageViewController=[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:pageOption];
    [self.pageViewController setDelegate:self];
    [self.pageViewController setDataSource:self];
    _contentChartArray=[NSMutableArray array];
    [self readHistoryData];
    _now=0;
    HistoryContentViewController *firstViewController=[self controllerAtIndex:0];
    NSArray *contentArray=[NSArray arrayWithObject:firstViewController];
    [_pageViewController setViewControllers:contentArray direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    _pageViewController.view.frame=self.view.bounds;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
}

-(void)viewDidLayoutSubviews{
    self.navigationController.navigationBar.translucent=NO;// testing
}

-(void) readHistoryData{
    //NSLog(@"readHistoryData");
    NSUserDefaults *nd=[NSUserDefaults standardUserDefaults];
    NSString *mac=[nd objectForKey:@"mac"];
    //NSLog(@"mac: %@",mac);
    if (mac!=nil&&![mac isEqualToString:@""]){
        DBHelper *helper=[DBHelper newInstance];
        [helper openDataBase];
        FMResultSet *rs=[helper getDayMax:mac];
        if (rs!=nil){
            while([rs next]){
                [_contentChartArray addObject:[rs resultDictionary]];
            }
        }
        else {
            NSLog(@"nothing in database");
        }
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSLog(@"beforeviewcontroller");
    if (_now==0){
        return nil;
    }
    _now--;
    return [self controllerAtIndex:_now];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSLog(@"afterviewcontroller");
    _now++;
    if (_now==8){
        return nil;
    }
    return [self controllerAtIndex:_now];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    // triggered when flip over
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    // triggered when flip start
}

-(HistoryContentViewController *)controllerAtIndex:(NSInteger) index{
    NSLog(@"controller at index: %d",index);
    HistoryContentViewController *controller = [[HistoryContentViewController alloc]init];
    NSLog(@"setcontentviewdata");
    [controller setContentViewData:_contentChartArray withKey:index];
    return controller;
}


@end
