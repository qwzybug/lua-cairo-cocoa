//
//  CairoView.m
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CairoView.h"


@implementation CairoView

@synthesize cairoSurface;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib;
{
	cairoSurface = cairo_quartz_surface_create(CAIRO_FORMAT_ARGB32, self.frame.size.width, self.frame.size.height);
}

- (void)clear;
{
	cairo_t *cr = cairo_create(cairoSurface);
	cairo_set_source_rgb(cr, 1, 1, 1);
	cairo_paint(cr);
	cairo_destroy(cr);
}

- (void)drawRect:(NSRect)rect {
	NSLog(@"Drawing a rect...");
    CGContextRef cairoContext = cairo_quartz_surface_get_cg_context(cairoSurface);
	CGImageRef image = CGBitmapContextCreateImage(cairoContext);
	CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextDrawImage(currentContext, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height), image);
	CGImageRelease(image);
}

- (void)dealloc;
{
	cairo_surface_destroy(cairoSurface);
	
	[super dealloc];
}

@end
