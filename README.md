rbtab: A Ruby Output Tabulator
==

Uses memoization for faster output

# Examples

create a table:

	`t = Table.new [ ["i", 'i**2'] ]`

add more rows:

	`4.times do |i|
		t.row [i, i*i]
	end`

print the results:

	`print t.to_s`

clear the table:

	`t.clear`
	
add another row:

	`t.row ["i", "sqrt(i)"]`

add one cell at a time:
	
	`4.times do |i|
		t.row
		t.cell i
		t.cell( (Math.sqrt(i) * 1000.0).round / 1000.0 )
	end`

print the results:
	`print t.to_s`

supports newlines within a cell:
	`print Table.new [
		[1,"ab\nc",3],
		[4,5,6],
		[7,8]
	]`



