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

@protocol CairoEventDelegate
- (void)mouseDownAt:(NSPoint)location;
- (void)mouseUpAt:(NSPoint)location;
- (void)mouseDraggedAt:(NSPoint)location;
@end

@interface CairoView : NSView {
	CGContextRef cairoContext;
	id<CairoEventDelegate> delegate;
}

@property (readwrite, assign) CGContextRef cairoContext;
@property (readwrite, assign) id delegate;

@end
