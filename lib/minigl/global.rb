require 'gosu'

module AGL
	Vector = Struct.new :x, :y
	
	class Rectangle
		attr_accessor :x, :y, :w, :h
		
		def initialize x, y, w, h
			@x = x; @y = y; @w = w; @h = h
		end
		
		def intersects r
			@x < r.x + r.w && @x + @w > r.x && @y < r.y + r.h && @y + @h > r.y
		end
	end
	
	class Game
		def self.initialize window, gravity = Vector.new(0, 1),
		                    kb_held_delay = 40, kb_held_interval = 5,
		                    double_click_delay = 8
			@@window = window
			@@gravity = gravity
			@@kb_held_delay = kb_held_delay
			@@kb_held_interval = kb_held_interval
			@@double_click_delay = double_click_delay
			
			KB.initialize
			Mouse.initialize
			Res.initialize
		end
		
		def self.window; @@window; end
		def self.gravity; @@gravity; end
		def self.kb_held_delay; @@kb_held_delay; end
		def self.kb_held_interval; @@kb_held_interval; end
		def self.double_click_delay; @@double_click_delay; end
	end
	
	#class JSHelper
	
	class KB
		def self.initialize
			@@keys = [
				Gosu::KbUp, Gosu::KbDown,
				Gosu::KbReturn, Gosu::KbEscape,
				Gosu::KbLeftControl, Gosu::KbRightControl,
				Gosu::KbA, Gosu::KbB, Gosu::KbC, Gosu::KbD, Gosu::KbE, Gosu::KbF,
				Gosu::KbG, Gosu::KbH, Gosu::KbI, Gosu::KbJ, Gosu::KbK, Gosu::KbL,
				Gosu::KbM, Gosu::KbN, Gosu::KbO, Gosu::KbP, Gosu::KbQ, Gosu::KbR,
				Gosu::KbS, Gosu::KbT, Gosu::KbU, Gosu::KbV, Gosu::KbW, Gosu::KbX,
				Gosu::KbY, Gosu::KbZ, Gosu::Kb1, Gosu::Kb2, Gosu::Kb3, Gosu::Kb4,
				Gosu::Kb5, Gosu::Kb6, Gosu::Kb7, Gosu::Kb8, Gosu::Kb9, Gosu::Kb0,
				Gosu::KbNumpad1, Gosu::KbNumpad2, Gosu::KbNumpad3, Gosu::KbNumpad4,
				Gosu::KbNumpad5, Gosu::KbNumpad6, Gosu::KbNumpad7, Gosu::KbNumpad8,
				Gosu::KbNumpad9, Gosu::KbNumpad0, Gosu::KbSpace, Gosu::KbBackspace,
				Gosu::KbDelete, Gosu::KbLeft, Gosu::KbRight, Gosu::KbHome,
				Gosu::KbEnd, Gosu::KbLeftShift, Gosu::KbRightShift,
				Gosu::KbBacktick, Gosu::KbMinus, Gosu::KbEqual, Gosu::KbBracketLeft,
				Gosu::KbBracketRight, Gosu::KbBackslash, Gosu::KbApostrophe,
				Gosu::KbComma, Gosu::KbPeriod, Gosu::KbSlash
			]
			@@down = []
			@@prev_down = []
			@@held_timer = {}
			@@held_interval = {}
		end
		
		def self.update
			@@held_timer.each do |k, v|
				if v < Game.kb_held_delay; @@held_timer[k] += 1
				else
					@@held_interval[k] = 0
					@@held_timer.delete k
				end
			end
			
			@@held_interval.each do |k, v|
				if v < Game.kb_held_interval; @@held_interval[k] += 1
				else; @@held_interval[k] = 0; end
			end
			
			@@prev_down = @@down.clone
			@@down.clear
			@@keys.each do |k|
				if Game.window.button_down? k
					@@down << k
					@@held_timer[k] = 0 if @@prev_down.index(k).nil?
				elsif @@prev_down.index(k)
					@@held_timer.delete k
					@@held_interval.delete k
				end
			end
		end
		
		def self.key_pressed? key
			@@prev_down.index(key).nil? and @@down.index(key)
		end
		
		def self.key_down? key
			@@down.index(key)
		end
		
		def self.key_released? key
			@@prev_down.index(key) and @@down.index(key).nil?
		end
		
		def self.key_held? key
			@@held_interval[key] == Game.kb_held_interval
		end
	end
	
	class Mouse
		def self.initialize
			@@down = {}
			@@prev_down = {}
			@@dbl_click = {}
			@@dbl_click_timer = {}
		end
		
		def self.update
			@@prev_down = @@down.clone
			@@down.clear
			@@dbl_click.clear
			
			@@dbl_click_timer.each do |k, v|
				if v < Game.double_click_delay; @@dbl_click_timer[k] += 1
				else; @@dbl_click_timer.delete k; end
			end
			
			k1 = [Gosu::MsLeft, Gosu::MsMiddle, Gosu::MsRight]
			k2 = [:left, :middle, :right]
			for i in 0..2
				if Game.window.button_down? k1[i]
					@@down[k2[i]] = true
					@@dbl_click[k2[i]] = true if @@dbl_click_timer[k2[i]]
					@@dbl_click_timer.delete k2[i]
				elsif @@prev_down[k2[i]]
					@@dbl_click_timer[k2[i]] = 0
				end
			end
			
			@@x = Game.window.mouse_x.round
			@@y = Game.window.mouse_y.round
		end
		
		def self.x; @@x; end
		def self.y; @@y; end
		
		def self.button_pressed? btn
			@@down[btn] and not @@prev_down[btn]
		end
		
		def self.button_down? btn
			@@down[btn]
		end
		
		def self.button_released? btn
			@@prev_down[btn] and not @@down[btn]
		end
		
		def self.double_click? btn
			@@dbl_click[btn]
		end
		
		def self.over? x, y, w, h
			@@x >= x and @@x < x + w and @@y >= y and @@y < y + h
		end
	end
	
	class Res
		def self.initialize
			@@imgs = Hash.new
			@@global_imgs = Hash.new
			@@tilesets = Hash.new
			@@global_tilesets = Hash.new
			@@sounds = Hash.new
			@@global_sounds = Hash.new
			@@fonts = Hash.new
			@@global_fonts = Hash.new
		end
		
		def self.img id, global = false, tileable = false, ext = ".png"
			if global; a = @@global_imgs; else; a = @@imgs; end
			return a[id] if a[id]
			s = "data/img/" + id.to_s.split('_').join('/') + ext
			img = Gosu::Image.new Game.window, s, tileable
			a[id] = img
		end
		
		def self.imgs id, sprite_cols, sprite_rows, global = false, ext = ".png"
			if global; a = @@global_imgs; else; a = @@imgs; end
			return a[id] if a[id]
			s = "data/img/" + id.to_s.split('_').join('/') + ext
			imgs = Gosu::Image.load_tiles Game.window, s, -sprite_cols, -sprite_rows, false
			a[id] = imgs
		end
		
		def self.tileset id, tile_width = 32, tile_height = 32, global = false, ext = ".png"
			if global; a = @@global_tilesets; else; a = @@tilesets; end
			return a[id] if a[id]
			s = "data/tileset/" + id.to_s.split('_').join('/') + ext
			tileset = Gosu::Image.load_tiles Game.window, s, tile_width, tile_height, true
			a[id] = tileset
		end
		
		def self.sound id, global = false, ext = ".wav"
			if global; a = @@global_sounds; else; a = @@sounds; end
			return a[id] if a[id]
			s = "data/sound/" + id.to_s.split('_').join('/') + ext
			sound = Gosu::Sample.new Game.window, s
			a[id] = sound
		end
		
		def self.song id, global = false, ext = ".ogg"
			if global; a = @@global_sounds; else; a = @@sounds; end
			return a[id] if a[id]
			s = "data/song/" + id.to_s.split('_').join('/') + ext
			song = Gosu::Song.new Game.window, s
			a[id] = song
		end
		
		def self.font id, size, global = true, ext = ".ttf"
			if global; a = @@global_fonts; else; a = @@fonts; end
			id_size = "#{id}_#{size}"
			return a[id_size] if a[id_size]
			s = "data/font/" + id.to_s.split('_').join('/') + ext
			font = Gosu::Font.new Game.window, s, size
			a[id_size] = font
		end
		
#		def self.text id
#			G.texts[G.lang][id.to_sym]
#		end
		
		def self.clear
			@@imgs.clear
			@@tilesets.clear
			@@sounds.clear
			@@fonts.clear
		end
	end
end
