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
            	img:set(x, y, _clr.set(-1, r, r, r) )
        end
    end 
end

--fills an image with random colors
function random_img(img)
    local min = _clr.set(0, 0, 0, 0)
    local max = _clr.set(-1, 255, 255, 255)
    math.randomseed(rb.current_tick())
    for x = 1, img:width() do
        for y = 1, img:height() do
            img:set(x, y, math.random(min, max))
        end
    end
end -- random_img

--[[ Drawn an X on the screen
rb.lcd_clear_display()
rb.lcd_drawline(0, 0, rb.LCD_WIDTH, rb.LCD_HEIGHT)
rb.lcd_drawline(rb.LCD_WIDTH, 0, 0, rb.LCD_HEIGHT)
rb.lcd_update() 
]]--

-- random_img(_lcd()); _lcd:update();

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
	local fullpic = "/bamedia/tiny_120x90/image-" .. string.format("%07d", i) .. ".bmp"
	drawimage(fullpic); 
	_lcd:update();

	newsec = os.date("%S")
	if currentsec == newsec then
		-- second has not changed, keep counting pics
		frames = frames + 1
	else
		currentsec = newsec
  		local message = string.format("fps: %d", frames )
  		rb.splash(seconds, message)
		frames = 0
	end

	rb.sleep(1) -- sleeps 1/100 sec, needed to keep sound playing
end

