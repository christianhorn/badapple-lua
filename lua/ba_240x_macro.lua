-- require("actions")   -- Contains rb.actions & rb.contexts
-- require("buttons") -- Contains rb.buttons
-- require("rbsettings")
-- require("settings")

-- local _math  = require("math_ex") -- missing math sine cosine, sqrt, clamp functions
-- local _timer = require("timer")
local _clr   = require("color") -- clrset, clrinc provides device independent colors
local _lcd   = require("lcd")   -- lcd helper functions
-- local _print = require("print") -- advanced text printing
local _img      = require("image") -- image manipulation save, rotate, resize, tile, new, load
-- local _img_save = require("image_save")
-- local _blit     = require("blit") -- handy list of blit operations
local _draw           = require("draw") -- draw all the things (primitives)
-- local _draw_floodfill = require("draw_floodfill")
-- local _draw_text      = require("draw_text")

local open = io.open
local img = _lcd()

function draw_char(char,x,y)
        if      char == 1 then
                rb.lcd_drawline(x+3, y, x+3, y+6)
        elseif  char == 2 then
                rb.lcd_drawline(x, y, x+5, y)
                rb.lcd_drawline(x+5, y, x+5, y+3)
                rb.lcd_drawline(x+5, y+3, x, y+3)
                rb.lcd_drawline(x, y+3, x, y+6)
                rb.lcd_drawline(x, y+6, x+5, y+6)
        elseif  char == 3 then
                rb.lcd_drawline(x, y, x+5, y)
                rb.lcd_drawline(x, y+3, x+5, y+3)
                rb.lcd_drawline(x, y+6, x+5, y+6)
                rb.lcd_drawline(x+5, y, x+5, y+6)
        elseif  char == 4 then
                rb.lcd_drawline(x, y+4, x+4, y)
                rb.lcd_drawline(x, y+4, x+5, y+4)
                rb.lcd_drawline(x+4, y, x+4, y+6)
        elseif  char == 5 then
                rb.lcd_drawline(x, y, x+5, y)
                rb.lcd_drawline(x, y, x, y+3)
                rb.lcd_drawline(x, y+3, x+5, y+3)
                rb.lcd_drawline(x+5, y+3, x+5, y+6)
                rb.lcd_drawline(x+5, y+6, x, y+6)
        elseif  char == 6 then
                rb.lcd_drawline(x, y+3, x+5, y)
                rb.lcd_drawline(x, y+3, x+5, y+3)
                rb.lcd_drawline(x, y+6, x+5, y+6)
                rb.lcd_drawline(x, y+3, x, y+6)
                rb.lcd_drawline(x+5, y+3, x+5, y+6)
        elseif  char == 7 then
                rb.lcd_drawline(x, y, x+5, y)
                rb.lcd_drawline(x, y+6, x+5, y)
        elseif  char == 8 then
                rb.lcd_drawline(x, y, x+5, y)
                rb.lcd_drawline(x, y+3, x+5, y+3)
                rb.lcd_drawline(x, y+6, x+5, y+6)
                rb.lcd_drawline(x, y, x, y+6)
                rb.lcd_drawline(x+5, y, x+5, y+6)
        elseif  char == 9 then
                rb.lcd_drawline(x, y, x+5, y)
                rb.lcd_drawline(x, y+3, x+5, y+3)
                rb.lcd_drawline(x, y, x, y+3)
                rb.lcd_drawline(x+5, y, x+5, y+6)
                rb.lcd_drawline(x, y+6, x+5, y+6)
        elseif  char == 0 then
                rb.lcd_drawline(x, y, x+5, y)
                rb.lcd_drawline(x, y+6, x+5, y+6)
                rb.lcd_drawline(x, y, x, y+6)
                rb.lcd_drawline(x+5, y, x+5, y+6)
        end
end -- draw_char

function draw_blackbox(x,y)
        local myx, myy
        for myy=y, y+8 do
                for myx=x, x+25 do
                        img:set(myx, myy, 0, 0, 0, 0) -- black
                        -- img:set(myx, myy, -1, 255, 255, 255) -- white
                end
        end
end

function printmessage(seconds)
  local message = string.format("real: %d", rb.HZ ) -- 320x240
  rb.splash(seconds, message)
end

local bmpwidth = 240
local bmpheight = 180
local content

function readimage(imagepath)
	local file = open(imagepath, "rb")
	if not file then
        	rb.splash(rb.HZ, "Error opening " .. imagepath)
        	return
  	end
  	content = file:read("*a")
  	file:close()
end

function drawframe(frame)
    	local counter
	counter = frame * 43200
    	local r
    	for y = bmpheight, 1, -1 do
        	for x = 1, bmpwidth do
			r = string.byte(content,counter)
			counter = counter + 1
            		img:set(x, y+70, _clr.set(-1, r, r, r) )
        	end
    	end
end

local seconds = 5

-- rb.sleep(5 * rb.HZ)

rb.lcd_clear_display()
rb.audio("stop")
rb.playlist("create", "/", "playback.m3u8")
rb.playlist("insert_track", "/bamedia/badapple.mp3")
rb.playlist("start", 0, 0, 0)

local newsec
local frames = 0
local fps = 0
local currentsec = os.date("%S")

for i=0, 205, 1 do
	local fullpic = "/bamedia/tiny_240x180-macropic/pic-" .. string.format("%07d", i)
	readimage(fullpic); 

	for frame=0, 3, 1 do

		drawframe(frame);

                frames = frames + 1

        	newsec = os.date("%S")
        	if currentsec ~= newsec then
			-- new second started, compute fps and reset counter
                	currentsec = newsec
			fps = frames
                	frames = 0
        	end
	        draw_blackbox(10,10)
		draw_char(fps/10, 10, 10);
	        draw_char(fps % 10, 20, 10);

	        _lcd:update();
		rb.sleep(10) -- sleeps 1/100 sec, needed to keep sound playing
	end
	
end

