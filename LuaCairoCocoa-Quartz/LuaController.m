//
//  LuaController.m
//  LuaCairoCocoa
//
//  Created by Devin Chalmers on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LuaController.h"

static NSMutableString *resultString;

@implementation LuaController

@synthesize viewport;

static int l_print(lua_State *L) {
	const char *msg = luaL_checkstring(L, 1);
	[resultString appendString:[NSString stringWithFormat:@"%s", msg]];
	return 0;
}

static int l_setCairoContext(lua_State *L) {
	// lua signature: setCairoSurface(viewport, cs)
	CairoView *viewport = (CairoView *)lua_topointer(L, 1);
	// not totally sure why this is a **, but it works :)
	CGContextRef **cgc = (CGContextRef **)lua_topointer(L, 2);
	viewport.cairoContext = **cgc;
	[viewport setNeedsDisplay:YES];
	return 0;
}

static int l_setNeedsDisplay(lua_State *L) {
	CairoView *viewport = (CairoView *)lua_topointer(L, 1);
	[viewport setNeedsDisplay:YES];
	return 0;
}

- (id)initWithLuaSourceNamed:(NSString *)luaSource viewport:(CairoView *)theViewport;
{
	if (!(self = [super init]))
		return nil;
	
	L = lua_open();
	luaL_openlibs(L);
	
	lua_pushcfunction(L, l_print);
    lua_setglobal(L, "print");
	
	lua_pushlightuserdata(L, self);
	lua_setglobal(L, "self");
	
	NSString *directory = [[NSBundle mainBundle] resourcePath];
	const char *dir = [directory cStringUsingEncoding:NSASCIIStringEncoding];
	lua_pushstring(L, dir);
	lua_setglobal(L, "LUA_PATH");
	
	// let's tell lua about the viewport
	self.viewport = theViewport;
	
	lua_pushcfunction(L, l_setCairoContext);
	lua_setglobal(L, "SET_CAIRO_CONTEXT");
	
	lua_pushcfunction(L, l_setNeedsDisplay);
	lua_setglobal(L, "VIEWPORT_NEEDS_DISPLAY");
	
	lua_pushlightuserdata(L, viewport);
	lua_setglobal(L, "VIEWPORT");
	
	lua_pushinteger(L, viewport.bounds.size.width);
	lua_setglobal(L, "VIEWPORT_WIDTH");
	lua_pushinteger(L, viewport.bounds.size.height);
	lua_setglobal(L, "VIEWPORT_HEIGHT");
	
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
	self.viewport = nil;
	
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

#pragma mark Event handling

- (void)mouseDownAt:(NSPoint)location;
{
	lua_getglobal(L, "mouseDown");
	lua_pushnumber(L, location.x);
	double height = self.viewport.bounds.size.height;
	lua_pushnumber(L, height - location.y); // cocoa drawing is inverted compared to Cairo's
	if (lua_pcall(L, 2, 0, 0) != 0) {
		NSLog(@"Error calling mouseDown: %s", lua_tostring(L, -1));
	}
}

- (void)mouseUpAt:(NSPoint)location;
{
	lua_getglobal(L, "mouseUp");
	lua_pushnumber(L, location.x);
	double height = self.viewport.bounds.size.height;
	lua_pushnumber(L, height - location.y); // cocoa drawing is inverted compared to Cairo's
	if (lua_pcall(L, 2, 0, 0) != 0) {
		NSLog(@"Error calling mouseUp: %s", lua_tostring(L, -1));
	}
}

@end
