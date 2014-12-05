//
//  Graph.h
//  Patient Monitor
//
//  Created by Ron Lasser on 9/13/14.
//  Copyright (c) 2014 org.rl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Graph : UIView

@property (nonatomic, strong) NSMutableArray *graphXData;
@property (nonatomic, strong) NSMutableArray *graphYData;
@property (nonatomic, strong) UIColor *dataColor;

- (void) printArray;
- (void) resize;
- (void)setGraphColor:(UIColor*)myColor WithShapeColor:(UIColor*)shapeColor;

@end
