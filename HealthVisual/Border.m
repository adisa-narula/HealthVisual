//
//  Border.m
//  HealthVisual
//
//  Created by Adisa Narula on 4/12/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "Border.h"

@implementation Border

-(id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat centerX = self.superview.center.x/2;
    CGFloat centerY = self.superview.center.y;

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, centerX, centerY); //start at this point
    
    CGContextAddLineToPoint(context, 100, 100); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

@end
