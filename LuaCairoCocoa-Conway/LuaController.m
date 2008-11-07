//
//  LuaController.m
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LuaController.h"

#import "CairoGridView.h"

static NSMutableString *resultString;

@implementation LuaController

@synthesize grid;

static int l_print(lua_State *L) {
	const char *msg = luaL_checkstring(L, 1);
	[resultString appendString:[NSString stringWithFormat:@"%s", msg]];
	return 0;
}

static int l_fillCell(lua_State *L) {
	// args are self, x, y
	CairoGridView *grid = (CairoGridView *)lua_topointer(L, 1);
	int x = lua_tointeger(L, 2);
	int y = lua_tointeger(L, 3);
	
	[grid fillCellAtX:x y:y];
	
	return 0;
}

static int l_clearGrid(lua_State *L) {
	CairoGridView *grid = (CairoGridView *)lua_topointer(L, 1);
	[grid clear];
	return 0;
}

//- (id)initWithLuaSourceNamed:(NSString *)luaSource;
- (id)initWithLuaSourceNamed:(NSString *)luaSource grid:(CairoGridView *)gridView;
{
	if (!(self = [super init]))
		return nil;
	
	L = lua_open();
	luaL_openlibs(L);
	
	lua_pushcfunction(L, l_print);
    lua_setglobal(L, "print");
	
	lua_pushlightuserdata(L, self);
	lua_setglobal(L, "self");
	
	// grid controller stuff
	
	self.grid = gridView;
	
	lua_pushcfunction(L, l_fillCell);
	lua_setglobal(L, "fillCell");
	
	lua_pushcfunction(L, l_clearGrid);
	lua_setglobal(L, "clearGrid");

	lua_pushlightuserdata(L, grid);
	lua_setglobal(L, "grid");	
	
	// load Lua file
	NSString *path = [[NSBundle mainBundle] pathForResource:luaSource ofType:@"lua"];
	NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:path];
	NSData *data = [f readDataToEndOfFile];
	
	int error = luaL_loadbuffer(L, (const char *)[data bytes], [data length], [luaSource cStringUsingEncoding:NSASCIIStringEncoding])
				|| lua_pcall(L, 0, 0, 0);
	[self reportErrors:error];
	
	return self;
}

- (void)dealloc;
{
	lua_close(L);
	
	[super dealloc];
}

#pragma mark -

- (void)execute:(NSString *)command;
{
	[self clearResult];
	const char *line = [command cStringUsingEncoding:NSASCIIStringEncoding];
	int error = luaL_loadbuffer(L, line, strlen(line), "line") ||
				lua_pcall(L, 0, 0, 0);
	[self reportErrors:error];
}

- (void)clearResult;
{
	[resultString release];
	resultString = [[NSMutableString stringWithCapacity:80] retain];
}

- (NSString *)result;
{
	return resultString;
}

- (void)reportErrors:(NSInteger)status;
{
	if ( status!=0 ) {
		[resultString appendString:[NSString stringWithCString:lua_tostring(L, -1)]];
		NSLog(@"-- %s", lua_tostring(L, -1));
		lua_pop(L, 1); // remove error message
	}
}

- (void)stackTrace;
{
	int i;
	int top = lua_gettop(L);
	for (i = 1; i <= top; i++) {  /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {
				
			case LUA_TSTRING:  /* strings */
				printf("`%s'", lua_tostring(L, i));
				break;
				
			case LUA_TBOOLEAN:  /* booleans */
				printf(lua_toboolean(L, i) ? "true" : "false");
				break;
				
			case LUA_TNUMBER:  /* numbers */
				printf("%g", lua_tonumber(L, i));
				break;
				
			default:  /* other values */
				printf("%s", lua_typename(L, t));
				break;
				
        }
        printf("  ");  /* put a separator */
	}
	printf("\n");  /* end the listing */	
}

@end
