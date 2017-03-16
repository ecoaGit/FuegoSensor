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
@property NSArray *pageArray;
@property NSInteger now;
@property (nonatomic,retain) UIPageViewController *pageViewController;
@property (nonatomic,retain) HistoryContentViewController *contentViewController;

@end

@implementation HistoryViewController

-(void)viewDidLoad{
    NSLog(@"HistoryViewController viewdidload");
    NSDictionary *pageOption=@{UIPageViewControllerOptionSpineLocationKey:@(UIPageViewControllerSpineLocationMin),
                               UIPageViewControllerOptionInterPageSpacingKey:@(20)};
    self.pageViewController=[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:pageOption];
    [self.pageViewController setDelegate:self];
    [self.pageViewController setDataSource:self];
    _contentChartArray=[NSMutableArray array];
    [self readHistoryData];
    [self initPageArray];
    _now=0;
   // HistoryContentViewController *firstViewController=[self controllerAtIndex:0];
    HistoryContentViewController *firstViewController=(HistoryContentViewController *)[_pageArray objectAtIndex:0];
    NSArray *contentArray=[NSArray arrayWithObject:firstViewController];
    [_pageViewController setViewControllers:contentArray direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    _pageViewController.view.frame=self.view.bounds;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
}

-(void)viewDidLayoutSubviews{
    self.navigationController.navigationBar.translucent=NO;// testing
}

-(void)initPageArray{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for(int i=0;i<8;i++){
        HistoryContentViewController *controller = [[HistoryContentViewController alloc]init];
        //NSLog(@"setcontentviewdata");
        [controller setContentViewData:_contentChartArray withKey:i];
        [array addObject:controller];
    }
    _pageArray=[[NSArray alloc]initWithArray:array];
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
    //NSLog(@"beforeviewcontroller :%d", _now);
    NSUInteger index=[self indexOfViewController:(HistoryContentViewController *)viewController];
    NSLog(@"index %d", index);
    if (index==0){
        return nil;
    }
    index--;
    return [_pageArray objectAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index=[self indexOfViewController:(HistoryContentViewController *)viewController];
    index++;
    if (index==8){
        return nil;
    }
    return [_pageArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    // triggered when flip over
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    // triggered when flip start
}

-(NSInteger)indexOfViewController:(HistoryContentViewController *)controller{
    return controller.contentKey;
}

-(HistoryContentViewController *)controllerAtIndex:(NSInteger) index{
    //NSLog(@"controller at index: %d",index);
    HistoryContentViewController *controller = [[HistoryContentViewController alloc]init];
    //NSLog(@"setcontentviewdata");
    [controller setContentViewData:_contentChartArray withKey:index];
    return controller;
}



@end
