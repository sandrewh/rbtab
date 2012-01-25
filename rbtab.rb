#!/usr/bin/ruby

class String
	def lpad_block(pad)
		pad + self.split("\n").join("\n"+pad) + "\n"		
	end
end

class Array
	def ljust(w, pad)
		need = w - self.dup.length
		need = 0 if need < 0
		self + ([pad] * need)
	end
	
    def map_with_index!
       each_with_index do |e, idx| self[idx] = yield(e, idx); end
    end

    def map_with_index(&block)
        dup.map_with_index!(&block)
    end	
end

class Memoizer
	attr_reader :values
	
	def initialize(&block)
		invalidate
		@block = block
	end
	
	def invalidate
		@values = {}
	end
	
	def [](v)
		@values[v] = @block.call(v) if !@values.has_key? v
		@values[v]
	end
end

class Table
	WPADDING = 1
	
	class Cell
		attr_reader :width, :height, :value, :lines
		
		def initialize (value=nil)
			value = "" if value.nil?
			@lines = value.to_s.lines.to_a.map{ |l| l.strip}
			@width = @lines.map{|l| l.length}.max
			@height = @lines.count
			@value = value
			
			@width = 0 if @height == 0	
		end
		
		def to_s
			@value.to_s
		end
	end
	
	def initialize (rows = [])
		@rows = []
		@has_heading = true
		
		rows.each do |r|
			self.row(r)
		end
		
		@column_width_memoizer = Memoizer.new{|ci|
			@rows.map{|r| (r[ci] || Cell.new).width}.max
		}
		
		@row_height_memoizer = Memoizer.new{|ri|
			@rows[ri].map{|c| (c || Cell.new).height}.max
		}
	end
	
	def row (items = [])
		@rows << items.map{|item| Cell.new(item)}
	end
	
	def cell (item)
		@rows << [] if @rows.length < 1
		@rows[-1] << Cell.new(item)
	end
	
	def width
		@rows.map{|row| row.length}.max
	end
	
	def height
		@rows.length
	end
	
	def clear
		@rows.clear
		@column_width_memoizer.invalidate
	end
		
	def to_s
		if self.height > 0			
			table_w = self.width
			
			row_partition() + 
			@rows.map_with_index{ |r,ri|
				row_height(ri).times.map{ |li|
					r.ljust(table_w, Cell.new).map_with_index{ |c,ci|
						"|" + (" "*WPADDING) + (c.lines[li] || "").ljust(column_width(ci)) + (" "*WPADDING)
					}.join + "|"
				}.join("\n")
			}.join("\n" + row_partition()) + "\n" + row_partition()
		else
			""
		end
	end
	
	private
	
	def column_width (ci)
		@column_width_memoizer[ci]
	end
	
	def row_height (ri)
		@row_height_memoizer[ri]
	end
	
	def row_partition # (c_widths)
		self.width.times.to_a.map{ |c|
			"+" + ("-" * (column_width(c) + WPADDING*2))
		}.join + "+\n"
	end
end

if __FILE__ == $0
	t = Table.new [ ["i", 'i**2'] ]
	4.times do |i|
		t.row [i, i*i]
	end
	print t.to_s.lpad_block(" ")
	
	t.clear
	t.row ["i", "sqrt(i)"]
	4.times do |i|
		t.row
		t.cell i
		t.cell( (Math.sqrt(i) * 1000.0).round / 1000.0 )
	end
	print t.to_s.lpad_block(" ")
	
	print Table.new [
		[1,"ab\nc",3],
		[4,5,6],
		[7,8]
	]
end