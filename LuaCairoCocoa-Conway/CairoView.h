//
//  CairoView.h
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <cairo.h>
#import <cairo-quartz.h>

@interface CairoView : NSView {
	cairo_surface_t *cairoSurface;
}

@property (readonly) cairo_surface_t *cairoSurface;

- (void)clear;

@end
