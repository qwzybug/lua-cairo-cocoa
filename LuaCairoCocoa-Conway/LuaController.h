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

@class CairoGridView;

@interface LuaController : NSObject {
	lua_State *L;
	CairoGridView *grid;
}

@property (readwrite, retain) CairoGridView *grid;

//- (id)initWithLuaSourceNamed:(NSString *)luaSource;
- (id)initWithLuaSourceNamed:(NSString *)luaSource grid:(CairoGridView *)gridView;
- (void)execute:(NSString *)command;
- (void)clearResult;
- (void)reportErrors:(NSInteger)status;
- (void)stackTrace;
- (NSString *)result;

@end
