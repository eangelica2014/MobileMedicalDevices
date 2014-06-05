//
//  ViewController.m
//  TemperatureGraphApp-iOS
//
//  Created by Ming Chow on 6/4/14.
//  Copyright (c) 2014 Ming Chow. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Basic setup instructions found at http://www.mobdevel.com/?p=96; most of the following code taken from there

    // Initialize tweets array
    temperatures = [[NSMutableArray alloc] init];
    
    // Get temperatures from API
    NSURL *url = [NSURL URLWithString:@"http://67.23.79.113:5000/data.json"];
    
    // Set up a concurrent queue to get data
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(parseData:)
                               withObject:data
                            waitUntilDone:YES];
    });
    
    // Create host view for graph
    hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: hostView];
    
    // Allow for pinch scaling
    hostView.allowPinchScaling = NO;
    
    // Create a CPTGraph object and add to hostView
    graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    hostView.hostedGraph = graph;
    
    // Add title to graph
    graph.title = @"Temperatures from Sensor";
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
 
    // Set theme
    selectedTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:selectedTheme];
    
    // Set padding for plot area
    [graph.plotAreaFrame setPaddingTop:25.0f];
    [graph.plotAreaFrame setPaddingLeft:60.0f];
    [graph.plotAreaFrame setPaddingBottom:25.0f];
    
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
    // Doesn't seem like these can be dynamically set (after getting data from API)
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 100 )]];
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 50 ) length:CPTDecimalFromFloat( (100 - 50) )]]; // Temperatures 50 (min) to 100 (max) Fahrenheit

    // Configure the axes
    [self configureAxes];

    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    // Let's keep it simple and let this class act as datasource (therefore we implemtn <CPTPlotDataSource>)
    plot.dataSource = self;
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
}

- (void)configureAxes
{
    // Largely taken from http://www.raywenderlich.com/13271/how-to-draw-graphs-with-core-plot-part-2
    // Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 2.0f;

    // Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;

    // Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Temperature (Fahrenheit)";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = 40.0f;
    y.axisLineStyle = axisLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 1.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.tickDirection = CPTSignNegative;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)parseData:(NSData *)responseData
{
    NSError* error;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                    options:0
                                                      error:&error];
    
    // Iterate through the temperatures
    NSEnumerator *it = [json objectEnumerator];
    NSDictionary *temp;
    while (temp = [it nextObject]) {
        [temperatures addObject:temp];
    }
    
    // Reload the graph
    // See http://stackoverflow.com/questions/3624203/core-plot-refresh-graph-dynamically-ipad
    [graph reloadData];
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords
{
    return [temperatures count]; // return the number of temperatures
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if(fieldEnum == CPTScatterPlotFieldX) {
        // Return x value
        return [NSNumber numberWithInt: index];
    } else {
        // Return y value
        NSDictionary *temp = [temperatures objectAtIndex:index];
        return [NSNumber numberWithInteger:[[temp objectForKey:@"temperature"] integerValue]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
