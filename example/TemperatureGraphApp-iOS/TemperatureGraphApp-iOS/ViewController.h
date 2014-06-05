//
//  ViewController.h
//  TemperatureGraphApp-iOS
//
//  Created by Ming Chow on 6/4/14.
//  Copyright (c) 2014 Ming Chow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface ViewController : UIViewController <CPTPlotDataSource>
{
    CPTGraphHostingView *hostView;
    CPTGraph *graph;
    CPTTheme *selectedTheme; // theme for graph
    NSMutableArray *temperatures;
}

@end
