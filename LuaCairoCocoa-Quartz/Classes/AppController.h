//
//  AppController.h
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LuaGridController, CairoView;

@interface AppController : NSObject {
	IBOutlet CairoView *cairoView;
	
	IBOutlet NSTextView *inputField;
	IBOutlet NSTextView *outputField;
	
	LuaGridController *lua;
}

- (IBAction)actionExecute:(id)sender;

@end
