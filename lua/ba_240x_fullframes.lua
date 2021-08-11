require("actions")   -- Contains rb.actions & rb.contexts
-- require("buttons") -- Contains rb.buttons -- not needed for this example
require("rbsettings")
require("settings")

local _clr   = require("color") -- clrset, clrinc provides device independent colors
local _lcd   = require("lcd")   -- lcd helper functions
local _img   = require("image") -- image manipulation save, rotate, resize, tile, new, load

local open = io.open

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
        local img = _lcd()
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

function drawimage(imagepath)
  local img = _lcd()
  local file = open(imagepath, "rb")
  if not file then
        rb.splash(rb.HZ, "Error opening " .. imagepath)
        return
  end
  local content = file:read("*a")
  file:close()

  local pixarray = string.byte(content,11,14) -- offset of the actual pixel array
  local bmpwidth = string.byte(content,19,22) -- bitmap width
  local bmpheight = string.byte(content,23,26) -- bitmap height

    local counter = pixarray
    local r
    for y = bmpheight, 1, -1 do
        for x = 1, bmpwidth do
		r = string.byte(content,counter)
		counter = counter + 3
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

local currentsec = os.date("%S")
local newsec
local frames = 0

for i=1, 6572, 1 do
	local fullpic = "/bamedia/tiny_240x180/image-" .. string.format("%07d", i) .. ".bmp"
	drawimage(fullpic); 

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

	rb.sleep(1) -- sleeps 1/100 sec, needed to keep sound playing
end

