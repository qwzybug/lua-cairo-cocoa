//
//  CairoGridView.m
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CairoGridView.h"


@implementation CairoGridView

@synthesize rows, cols;

- (void)fillCellAtX:(int)x y:(int)y;
{
	NSLog(@"Filling a cell at (%d, %d)", x, y);
	
	double cellw = self.bounds.size.width / self.cols;
	double cellh = self.bounds.size.height / self.rows;
	
	cairo_t *cr = cairo_create(cairoSurface);
	cairo_set_source_rgb(cr, 0, 0, 0);
	cairo_rectangle(cr, cellw * x, cellh * y, cellw, cellh);
	cairo_fill(cr);
	cairo_destroy(cr);
}

@end
