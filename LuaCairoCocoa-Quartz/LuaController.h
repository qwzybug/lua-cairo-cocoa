//
//  LuaController.h
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <lua.h>
#import <lauxlib.h>
#import <lualib.h>
#import <luaconf.h>

#import "CairoView.h"

@interface LuaController : NSObject <CairoEventDelegate> {
	lua_State *L;
	CairoView *viewport;
}

@property (readwrite, retain) CairoView *viewport;

//- (id)initWithLuaSourceNamed:(NSString *)luaSource;
- (id)initWithLuaSourceNamed:(NSString *)luaSource viewport:(CairoView *)theViewport;
- (void)execute:(NSString *)command;
- (void)clearResult;
- (void)reportErrors:(NSInteger)status;
- (void)stackTrace;
- (NSString *)result;

@end
