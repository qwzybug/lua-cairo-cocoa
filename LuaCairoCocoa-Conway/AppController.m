//
//  AppController.m
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

#import "LuaGridController.h"
#import "CairoGridView.h"

@implementation AppController

- (void)awakeFromNib;
{
	cairoView.rows = 10;
	cairoView.cols = 10;
	lua = [[LuaController alloc] initWithLuaSourceNamed:@"conway" grid:cairoView];
//	lua = [[LuaController alloc] initWithLuaSourceNamed:@"grid"];
	
//	[lua setGlobal:@"cs" lightUserData:cairoView.cairoSurface];
}

- (void)dealloc;
{
	[lua release];
	
	[super dealloc];
}

#pragma mark -

- (IBAction)actionExecute:(id)sender;
{
	NSString *command = [inputField stringValue];
	
	[outputField setEditable:YES];
	[outputField insertText:[NSString stringWithFormat:@"> %@\n", command]];
	[outputField setEditable:NO];
	
	[lua execute:command];
	
	[inputField setStringValue:@""];
	
	if ([[lua result] length] > 0) {
		[outputField setEditable:YES];
		[outputField insertText:[NSString stringWithFormat:@"%@\n", [lua result]]];
		[outputField setEditable:NO];
	}
	
	[cairoView setNeedsDisplay:YES];
}

@end
