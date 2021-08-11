require("actions")   -- Contains rb.actions & rb.contexts
-- require("buttons") -- Contains rb.buttons -- not needed for this example
require("rbsettings")
require("settings")

local _math  = require("math_ex") -- missing math sine cosine, sqrt, clamp functions
local _timer = require("timer")
local _clr   = require("color") -- clrset, clrinc provides device independent colors
local _lcd   = require("lcd")   -- lcd helper functions
local _print = require("print") -- advanced text printing
local _img      = require("image") -- image manipulation save, rotate, resize, tile, new, load
local _img_save = require("image_save")
local _blit     = require("blit") -- handy list of blit operations
local _draw           = require("draw") -- draw all the things (primitives)
local _draw_floodfill = require("draw_floodfill")
local _draw_text      = require("draw_text")

local open = io.open

function draw_char(char,x,y)
	if 	char == 1 then
		rb.lcd_drawline(x+3, y, x+3, y+6)
	elseif 	char == 2 then
		rb.lcd_drawline(x, y, x+5, y)
		rb.lcd_drawline(x+5, y, x+5, y+3)
		rb.lcd_drawline(x+5, y+3, x, y+3)
		rb.lcd_drawline(x, y+3, x, y+6)
		rb.lcd_drawline(x, y+6, x+5, y+6)
	elseif 	char == 3 then
		rb.lcd_drawline(x, y, x+5, y)
		rb.lcd_drawline(x, y+3, x+5, y+3)
		rb.lcd_drawline(x, y+6, x+5, y+6)
		rb.lcd_drawline(x+5, y, x+5, y+6)
	elseif 	char == 4 then
		rb.lcd_drawline(x, y+4, x+4, y)
		rb.lcd_drawline(x, y+4, x+5, y+4)
		rb.lcd_drawline(x+4, y, x+4, y+6)
	elseif 	char == 5 then
		rb.lcd_drawline(x, y, x+5, y)
		rb.lcd_drawline(x, y, x, y+3)
		rb.lcd_drawline(x, y+3, x+5, y+3)
		rb.lcd_drawline(x+5, y+3, x+5, y+6)
		rb.lcd_drawline(x+5, y+6, x, y+6)
	elseif 	char == 6 then
		rb.lcd_drawline(x, y+3, x+5, y)
		rb.lcd_drawline(x, y+3, x+5, y+3)
		rb.lcd_drawline(x, y+6, x+5, y+6)
		rb.lcd_drawline(x, y+3, x, y+6)
		rb.lcd_drawline(x+5, y+3, x+5, y+6)
	elseif 	char == 7 then
		rb.lcd_drawline(x, y, x+5, y)
		rb.lcd_drawline(x, y+6, x+5, y)
	elseif 	char == 8 then
		rb.lcd_drawline(x, y, x+5, y)
		rb.lcd_drawline(x, y+3, x+5, y+3)
		rb.lcd_drawline(x, y+6, x+5, y+6)
		rb.lcd_drawline(x, y, x, y+6)
		rb.lcd_drawline(x+5, y, x+5, y+6)
	elseif 	char == 9 then
		rb.lcd_drawline(x, y, x+5, y)
		rb.lcd_drawline(x, y+3, x+5, y+3)
		rb.lcd_drawline(x, y, x, y+3)
		rb.lcd_drawline(x+5, y, x+5, y+6)
		rb.lcd_drawline(x, y+6, x+5, y+6)
	elseif 	char == 0 then
		rb.lcd_drawline(x, y, x+5, y)
		rb.lcd_drawline(x, y+6, x+5, y+6)
		rb.lcd_drawline(x, y, x, y+6)
		rb.lcd_drawline(x+5, y, x+5, y+6)
	end
end -- draw_char

function draw_blackbox(x,y)
  	local img = _lcd()
        local myx, myy
	for myy=y, y+8 do
               	for myx=x, x+25 do
               		img:set(myx, myy, 0, 0, 0, 0) -- black
            		-- img:set(myx, myy, -1, 255, 255, 255)	-- white
		end
	end
end

function printmessage(seconds)
  local message = string.format("real: %d", rb.HZ ) -- 320x240
  rb.splash(seconds, message)
end

function drawimage(imagepath)
  	local img = _lcd()

        local file = assert(io.open(imagepath, "rb"))
        local data = file:read("*all")
        local fsz = file:seek("end")    -- get file size
        file:close()

	if fsz ~= 0 then
	        local counter = 1
	        local x, y, r, hlp
		repeat
	                x = string.byte(data,counter)
	                counter = counter + 1
	                y = string.byte(data,counter)
	                counter = counter + 1
	                r = string.byte(data,counter)
	                counter = counter + 1

			if y < 90 then
				y = 90 + ( 90 - y )
			else
				y = 90 - ( y - 90 )
			end
			y = y + 70
	                img:set( x, y, _clr.set(0, r, r, r) )
	
	        until ( counter > fsz )
	end
end

--fills an image with random colors
function random_img(img)
    local min = _clr.set(0, 0, 0, 0)
    local max = _clr.set(-1, 255, 255, 255)
    math.randomseed(rb.current_tick())
    for x = 1, img:width() do
        for y = 1, img:height() do
            -- img:set(x, y, math.random(min, max))
            img:set(x, y, -1, 255, 255, 255)	-- white
            -- img:set(x, y, 0, 0, 0, 0)	-- black
        end
    end
end -- random_img

-- random_img(_lcd()); _lcd:update();
rb.lcd_clear_display()
rb.audio("stop")
rb.playlist("create", "/", "playback.m3u8")
rb.playlist("insert_track", "/bamedia/badapple.mp3")
rb.playlist("start", 0, 0, 0)	

local currentsec = os.date("%S")
local newsec
local frames = 0

-- for i=1, 6572 do
for i=2, 6570, 2 do
	local picpath = "/bamedia/tiny_240x180_differ_half/image-" .. string.format("%07d", i)
	drawimage(picpath);

        newsec = os.date("%S")
        if currentsec == newsec then
                -- second has not changed, keep counting pics
                frames = frames + 1
        else
                currentsec = newsec
                -- local message = string.format("fps: %d", frames )
		draw_blackbox(10,10)

                if frames > 9 then
			draw_char(frames/10, 10, 10);
			draw_char(frames % 10, 20, 10);
		else
			draw_char(frames, 20, 10);
		end
                frames = 0
        end
	_lcd:update();

	rb.sleep(4) -- sleeps 1/100 sec, needed to keep sound playing
end

rb.sleep(5 * rb.HZ)
