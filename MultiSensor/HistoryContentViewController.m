//
//  HistoryContentViewController.m
//  MultiSensor
//
//  Created by Apple on 2016/10/3.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "HistoryContentViewController.h"

//#import <Charts/Charts-Swift.h>

@interface HistoryContentViewController() <ChartViewDelegate>
@property (nonatomic,retain) LineChartView *chartView;
@end

@implementation HistoryContentViewController

-(void)viewDidLoad{
    NSLog(@"ContentView chart viewdidload");
    [self.chartView animateWithXAxisDuration:1.0f];
}

-(void)setContentViewData:(NSMutableArray *)viewData withKey:(NSInteger)key{
    NSString *objKey=@"";
    NSString *chartTitle=@"";
    switch(key){
        case 0:
            objKey=@"max40025";
            chartTitle=@"CO2 ppm";
            break;
        case 1:
            objKey=@"max40026";
            chartTitle=@"PM2.5 ppm";
            break;
        case 2:
            objKey=@"max40027";
            chartTitle=@"Pressure h/Pa";
            break;
        case 3:
            objKey=@"max40028";
            chartTitle=@"CO ppm";
            break;
        case 4:
            objKey=@"max40029";
            chartTitle=@"VOC ppm";
            break;
        case 5:
            objKey=@"max40030";
            chartTitle=@"Temperature °C";
            break;
        case 6:
            objKey=@"max40031";
            chartTitle=@"Humidity %";
            break;
        case 7:
            objKey=@"max40032";
            chartTitle=@"Gas ppm";
            break;
        default:
            break;
    }
    //NSLog(objKey);
    NSMutableArray *yData=[[NSMutableArray alloc]init];
    //NSMutableArray *xData=[[NSMutableArray alloc]init];
    // for initialized chart
    self.chartView=[[LineChartView alloc]init];
    [self.chartView setDelegate:self];
    UILabel *label=[[UILabel alloc]init];
    [label setText:chartTitle];
    [label setBackgroundColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1.0]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    [label setFont:[UIFont systemFontOfSize:21.0]];
    [self.chartView setFrame:CGRectMake(0, 60, self.view.bounds.size.width, (self.view.bounds.size.height-120))];
    [self.view addSubview:label];
    [self.view addSubview:self.chartView];
    _chartView.backgroundColor=[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:144.0/255.0];
    _chartView.gridBackgroundColor=[UIColor grayColor];
    self.chartView.dragEnabled=YES;
    self.chartView.drawGridBackgroundEnabled=YES;
    self.chartView.noDataText=@"---";
    self.chartView.doubleTapToZoomEnabled=NO;//取消双击缩放
    self.chartView.dragEnabled=YES;//启用拖拽图标
    self.chartView.dragDecelerationEnabled=YES;//拖拽后是否有惯性效果
    self.chartView.dragDecelerationFrictionCoef=0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
    self.chartView.scaleYEnabled=YES;//Y轴缩放
    // Y axis
    self.chartView.rightAxis.enabled=NO;//不绘制右边轴
    //_chartView.backgroundColor=[UIColor grayColor];
    ChartYAxis *yAxis=self.chartView.leftAxis;//获取左边Y轴
    //leftAxis.labelCount = 5;//Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
    yAxis.forceLabelsEnabled=NO;//不强制绘制指定数量的label
    //leftAxis.showOnlyMinMaxEnabled=NO;//是否只显示最大值和最小值
    //leftAxis.axisMinValue =0;//设置Y轴的最小值
    yAxis.axisMinimum=0;//从0开始绘制
    yAxis.axisMaxValue = 105;//设置Y轴的最大值
    yAxis.inverted = NO;//是否将Y轴进行上下翻转
    yAxis.axisLineWidth=1.0/[UIScreen mainScreen].scale;//Y轴线宽
    yAxis.axisLineColor=[UIColor blackColor];//Y轴颜色
    yAxis.valueFormatter=[[ChartDefaultAxisValueFormatter alloc] initWithFormatter:[[NSNumberFormatter alloc] init]];//自定义格式
    //leftAxis.valueFormatter.positiveSuffix;//数字后缀单位
    yAxis.labelPosition=YAxisLabelPositionOutsideChart;//label位置
    yAxis.labelTextColor=[UIColor blackColor];//文字颜色
    yAxis.labelFont=[UIFont systemFontOfSize:20.0f];//文字字体
    yAxis.gridColor=[UIColor blackColor];
    // X axis
    ChartXAxis *xAxis=self.chartView.xAxis;
    xAxis.axisLineWidth=1.0/[UIScreen mainScreen].scale;//设置X轴线宽
    xAxis.labelPosition=XAxisLabelPositionBottom;//X轴的显示位置，默认是显示在上面的
    xAxis.drawGridLinesEnabled=NO;//不绘制网格线
    xAxis.labelRotationAngle=-30.0;
    xAxis.labelTextColor=[UIColor blackColor];//label文字颜色
    xAxis.labelFont=[UIFont systemFontOfSize:20.0f];
    //ChartIndexAxisValueFormatter
    AxisDateFormatter *adf=[[AxisDateFormatter alloc]initWithDateFormat:@"MM-dd HH:mm"];
    xAxis.valueFormatter=adf;
    NSDateFormatter *ndfD=[[NSDateFormatter alloc]init];
    [ndfD setDateFormat:@"yyyy-MM-dd HH:mm:ss"];// 資料庫日期格式
    
    if (viewData!=nil&&[viewData count]>0){
        NSLog(@"viewData is not nil");
        double yMax=0;
        double yMin=[[[viewData objectAtIndex:0] objectForKey:objKey] doubleValue];
        for(int i=0;i<[viewData count];i++){
            //NSLog(@"%@",[[viewData objectAtIndex:i] objectForKey:@"_date"]);
            double value=[[[viewData objectAtIndex:i] objectForKey:objKey] doubleValue];
            if (value > yMax){
                yMax=value;
            }
            if (value < yMin){
                yMin=value;
            }
            NSString *dString=[[viewData objectAtIndex:i] objectForKey:@"_date"];
            //NSLog(@"string %@", dString);
            NSDate *date=[ndfD dateFromString:dString];
            NSTimeInterval seconds=[date timeIntervalSince1970];// date秒數
            ChartDataEntry *entry=[[ChartDataEntry alloc]initWithX:seconds y:value];
            [yData addObject:entry];
            //ChartDataEntry *entry=[[ChartDataEntry alloc]initWithValue:value xIndex:i];
            //NSString *dString=[[viewData objectAtIndex:i] objectForKey:@"_date"];
            //NSDate *date=[ndfD dateFromString:dString];
            //[xData addObject:[ndf stringFromDate:date]];//將資料庫日期格式轉為label日期格式
            //[xData addObject:[[viewData objectAtIndex:i] objectForKey:@"_date"]];
        }
        yAxis.axisMaxValue=yMax+10;
        yAxis.axisMinValue=yMin-10;
    }
    else {
        return;
    }
    LineChartDataSet *dataset=nil;
    if (self.chartView.data.dataSets.count>0){
        //LineChartData *data=(LineChartData *)_chartView.data;
        //LineChartDataSet *dataset=data.dataSets[0];
    }
    else {
        //NSLog(@"dataset initwithyvals");
        dataset=[[LineChartDataSet alloc]initWithValues:yData label:chartTitle];
        dataset.lineWidth=2.0/[UIScreen mainScreen].scale;
        //dataset.drawValuesEnabled=YES;//是否在拐点处显示数据
        dataset.valueColors=@[[UIColor brownColor]];//折线拐点处显示数据的颜色
        [dataset setColor:[UIColor orangeColor]];//折线颜色
        dataset.drawSteppedEnabled=NO;//是否开启绘制阶梯样式的折线图
        //折线拐点样式
        dataset.drawCirclesEnabled=YES;//是否绘制拐点
        dataset.circleRadius=3.0f;//拐点半径
        dataset.circleColors=@[[UIColor redColor]];//拐点颜色
        //拐点中间的空心样式
        dataset.drawCircleHoleEnabled=YES;//是否绘制中间的空心
        dataset.circleHoleRadius=2.0f;//空心的半径
        dataset.circleHoleColor=[UIColor whiteColor];//空心的颜色
        //dataset.drawFilledEnabled=YES;
        
        NSMutableArray *datasets=[[NSMutableArray alloc]init];
        [datasets addObject:dataset];
        //NSLog(@"data initwithxvals");
        LineChartData *data=[[LineChartData alloc]initWithDataSets:datasets];
        //LineChartData *data=[[LineChartData alloc]initWithXVals:xData dataSets:datasets];
        [data setValueTextColor:[UIColor whiteColor]];
        self.chartView.data=data;
        [self updateData];
        //dispatch_async(dispatch_get_main_queue(),^{[_chartView animateWithXAxisDuration:1.0f];});
    }
}

-(void)updateData{
    [self.chartView animateWithXAxisDuration:1.0f];
}

@end
