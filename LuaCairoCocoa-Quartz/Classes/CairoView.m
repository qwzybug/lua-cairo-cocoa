//
//  CairoView.m
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CairoView.h"


@implementation CairoView

@synthesize cairoContext, delegate;

// - (void)awakeFromNib;
// {
//   [[self window] setAcceptsMouseMovedEvents:YES];
// }

- (void)drawRect:(NSRect)rect {
	if (!cairoContext) return;
	CGImageRef image = CGBitmapContextCreateImage(cairoContext);
	CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextDrawImage(currentContext, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height), image);
	CGImageRelease(image);
}

- (BOOL)acceptsFirstResponder;
{
	return YES;
}

// - (BOOL)acceptsMouseMoved;
// {
//   return YES;
// }

- (void)mouseDown:(NSEvent *)theEvent;
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:[[self window] contentView]];
	[self.delegate mouseDownAt:location];
}

- (void)mouseUp:(NSEvent *)theEvent;
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:[[self window] contentView]];
	[self.delegate mouseUpAt:location];
}

- (void)mouseDragged:(NSEvent *)theEvent;
{
  NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:[[self window] contentView]];
  [self.delegate mouseDraggedAt:location];
}


@end
