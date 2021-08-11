local _lcd   = require("lcd")   -- lcd helper functions
local _clr   = require("color") -- clrset, clrinc provides device independent colors

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
end -- draw_blackbox

function printmessage(seconds)
	local message = string.format("real: %d", rb.HZ ) -- 320x240
	rb.splash(seconds, message)
end -- printmessage

rb.lcd_clear_display()
rb.audio("stop")
rb.playlist("create", "/", "playback.m3u8")
rb.playlist("insert_track", "/bamedia/badapple.mp3")
rb.playlist("start", 0, 0, 0)

local currentsec = os.date("%S")
local newsec
local frames = 0

-- iterate over our ani files
for j=0, 821, 1 do

	local fullpath = "/bamedia/tiny_120x90-ani/part-" .. string.format("%07d", j)
	local file = open(fullpath, "rb")
	if not file then
	        rb.splash(rb.HZ, "Error opening " .. fullpath)
	        return
	end
	local content = file:read("*a")
	file:close()
	
	local counter = 1

	-- iterate over the 8 frames in each ani-file
	-- fixme: last file has less frames
	for i=1, 8, 1 do

	    	local framesz = string.byte(content,counter) + string.byte(content,counter+1)*256 + string.byte(content,counter+2)*256*256
		counter = counter + 4
	
		if framesz ~= 4 then
			local x,y,r,j
	
			for j=counter, counter + framesz - 5, 3 do
				x = string.byte(content,j)
				y = string.byte(content,j + 1)
				r = string.byte(content,j + 2)
				y = y + 20
	            		img:set(x*2,   y*2, _clr.set(-1, r, r, r) )
	            		img:set(x*2-1, y*2, _clr.set(-1, r, r, r) )
	            		img:set(x*2,   y*2-1, _clr.set(-1, r, r, r) )
	            		img:set(x*2-1, y*2-1, _clr.set(-1, r, r, r) )
			end
	
			counter = counter + framesz - 4
		end
	
	        newsec = os.date("%S")
	        if currentsec == newsec then
	                -- second has not changed, keep counting frames
	                frames = frames + 1
	        else
			-- second has changed, print out fps
	                currentsec = newsec
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
	
		-- sleeps 1/100 sec, to refill sound buffer
		-- fixme: make this dynamic, to keep 30fps so
		-- video/audio stay in sync
		rb.sleep(1) 
	end
end
