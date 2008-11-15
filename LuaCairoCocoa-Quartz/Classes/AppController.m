//
//  AppController.m
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

#import "LuaController.h"
#import "CairoView.h"

@implementation AppController

- (void)awakeFromNib;
{
	lua = [[LuaController alloc] initWithLuaSourceNamed:@"core" viewport:cairoView];
	cairoView.delegate = lua;
}

- (void)dealloc;
{
	[lua release];
	
	[super dealloc];
}

#pragma mark -

- (IBAction)actionExecute:(id)sender;
{
	NSString *command = [[inputField textStorage] string];
	
	[lua execute:command];
	
	if ([[lua result] length] > 0) {
		[outputField setEditable:YES];
		[outputField insertText:[NSString stringWithFormat:@"%@\n", [lua result]]];
		[outputField setEditable:NO];
	}
}

@end
