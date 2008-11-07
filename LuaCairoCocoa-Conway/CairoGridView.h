//
//  CairoGridView.h
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CairoView.h"

@interface CairoGridView : CairoView {
	int rows;
	int cols;
}

@property (readwrite) int rows;
@property (readwrite) int cols;

- (void)fillCellAtX:(int)x y:(int)y;

@end
