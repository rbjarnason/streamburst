require 'date'
require 'parsedate'


#A log file entry, consisting of time, url, and referer.
class LogItem

	@time
	@url
	@ref
	
	attr_reader :time
	attr_reader :url
	attr_reader :ref
	
	def initialize(time, url, ref)
		@time=time
		@url = url
		@ref = ref
	end
	
	def to_s
		@time.asctime + " , " + @url.to_s + " , " + @ref.to_s
	end
	
    #Represent the log item as a string, with time counted in seconds.  This is
    #easier to parse than a human-readable representation so it's used in cache files.
	def toFileString
		@time.to_i.to_s + " , " + @url.to_s + " , " + @ref.to_s
	end
	
end

#The specification of a line (not the appearance of a line -- that's specified by a style in
#TimeGraph.sty[]) 
class LineSpec
	
	@name
	@regex
	@isRegexNegative
	@isURLReferer
	
    #The lable of this line
	attr_reader :name
    #Log items matching this regular expression will be included in the line
	attr_reader :regex
    #Whether or not to negate the regular expression
	attr_reader :isRegexNegative
    #If this is set true, the regex is applied to the 'referer' field of the log item,
    #rather than to the 'url' field
	attr_reader :isURLReferer

	def initialize(name, regex, neg=false, ref=false)
		@name=name
		@regex=regex
		@isRegexNegative=neg
		@isURLReferer=ref
	end
	
	#true if a given item should be included in data for this line
	def matchesItem(i)
		url = if @isURLReferer then i.ref else i.url end
		
		if @isRegexNegative then
			return !(url =~ @regex)
		else
			return url =~ @regex
		end
	end

end


#A class that reads in either an Apache log file or a rubywebstat cache file,
#resulting in a collection of LogItem objects.
class LogReader
	
	@items
	
    #An array of LogItem objects representing all relevant records in the input file
	attr_reader :items
	
	def initialize
		@items = []
	end
	
	#Read from an Apache logfile.
    #file:: Name of file to open
    #from:: Records that are more recent than this Date...
    #to:: ...and less recent than this Date...
    #ignorepat:: ...and do not match this regular expression...
    #ignoreurl:: ...and have targets that do not match this regular expression, will be processed.
	def readApacheLog(file, from, to, ignorepat, ignoreurl)
	
		f = File.open(file, "r")
        f.each_line{|l|
        
        #extract date, url, and ref
        
        if l =~ ignorepat then
          # ignore it
        else

          if l =~ /.*\[(.*)\] "GET (.*) .*" [0-9-]+ [0-9-]+ "(.*)" "/ then
            newApacheRecord($1, $2, $3, from, to, ignoreurl)
          else
              #fail silently on an invalid record.
          end

        end

        }
        
        p "LogReader read " + @items.length.to_s + " items."
	end
	
	#Read data from a rubywebstat cache file.
	def readRWSData(file)
	
		f = File.open(file, "r")
        f.each_line{|l|
        
        if l =~ /(.*) , (.*) , (.*)/ then
			newRWSRecord($1, $2, $3)
		else
          #fail silently if record can't be created
		end
        
        }
        
        p "LogReader read " + @items.length.to_s + " items."
	end
	
	#Write out the LogItems in this LogReader to a rubywebstat cache file, so that
    #they can be read faster in future
	def writeRWSData(file)
		f = File.open(file, "w")
		
		@items.each{|i|
			f.write(i.toFileString + "\n")
		}
		
		f.close
	end
	
	
	#Given various relevant bits of information from an Apache logfile,
    #add a LogItem
    #date:: The date of the item, as a string in Apache log format
    #url:: The URL of the item
    #ref:: The referer of the item
    #from:: A Date.  If the item is older than this date it will be discarded
    #to:: A Date.  If the item is newer than this date it will be discarded
    #ignorepat:: A regular expression.  If the item matches this, it will be discarded

	def newApacheRecord(date, url, ref, from=nil, to=nil, ignorepat=nil)
	
		if (nil != ignorepat) then
			if ((url =~ ignorepat) != nil) then
				#item matches the 'ignore' pattern, so discard it
				return
			end
		end
	
		date.gsub! "/", "-"
		date.gsub! "2002:", "02 "
        date.gsub! "2003:", "03 "
		ary = ParseDate.parsedate(date)

        begin
            t = Time::local *ary[0..5]
        rescue
            p *ary[0..5]
            return
        end
		
		if (nil != from) then
			if (t < from || t > to) then
				#item is outside date range, so discard it
				return
			end
		end
		
		@items << (LogItem.new (t, url, ref))
	end
	
	#Given a record from a RWS file, add a LogItem to @items
    #date:: The date of the item, as a string holding an integer value in seconds
    #url:: The URL of the item
    #ref:: The referer of the item
	def newRWSRecord(date, url, ref)
	
		t = Time.at(date.to_i)
		
		@items << (LogItem.new (t, url, ref))

	end

end



#Class to prepare data series for a chart.
class TimeData

	@lr
	@points
	@lines
	@interval
	@from
	@to
	
	
    #An array of time values (integers, time in seconds)
	attr_reader :points
    #A hash of lines, keyed by the name of the line.
	attr_reader :lines
    #The theoretical interval, in seconds, between time points
	attr_reader :interval
    #The lowest time value (left edge of the chart)
	attr_reader :from
    #The highest time value (right edge of the chart)
	attr_reader :to
	
	def initialize()
		@lr = nil
		@points = []
		@lines = {}
	end


	#Create array of X axis points
    #logreader:: A LogReader object that contains LogItems
    #seconds:: The interval between time points.  The smaller this value, the more points there are on the chart.
    #from:: Start time
    #to:: End time
	def generateTimePoints (logreader, seconds = 1, from = nil, to = nil)
	
		@lr = logreader
		
		@interval = seconds
		
		#get start and end times
		
		if (nil == from) then
			@from = @lr.items[0].time
		else
			@from = from
		end
		
		if (nil == to) then
			@to = @lr.items[-1].time
		else
			@to = to
		end
		
		#move start time back till it's on an interval point
		@from -= (from.to_i % @interval)
		
		#((@from.to_i)..(@to.to_i)).step(@interval) {|secs|
		#	@points << Time.at(secs)
		#}
		
		#curse this early ruby version!
		i = @from.to_i
		while (i <= @to.to_i) 
			@points << Time.at(i)
			i += @interval
		end	

	end
	
	
	#Given an array of LineSpecs, total up hits within time bands for items that match
	#a linespec, thus producing a series of points for the chart
	def makeGraph (linespecs)
	
		@lines.clear
		linespecs.each{|linespec|
		
			@lines[linespec.name]=Array.new(@points.length-1, 0)
			
			@lr.items.each{|i|
			
				if (linespec.matchesItem(i))
					
					band = getTimeBandForTime(i.time)
					
					if (band != -1) then
						@lines[linespec.name][band] += 1
					end
				end
			}
		}
		
	end
	
	
	
	#Given a time, return the index into the time points array that it fits.
    #This helps us decide what point on the chart a given item should be contributing to.
	def getTimeBandForTime(time)
	
		if (time < @from  ) then return -1 end
		
		if (time > @to ) then return -1 end
		
		@points.each_with_index{|p,i|
			if (time < p) then return i-1 end
		}
	
		-1
	end
	
	#Find the highest point on the chart, so we can work out the scales.
	def maxValue
	
		n=0
		@lines.each_value{|line|
			line.each{|value|
				if (value > n) then n = value end
			}
		}
		
		n
	end

end


#This class represents an actual displayed chart.  It has many properties associated with display, and a single
#TimeData property which contains all the actual data series to be displayed.
class TimeGraph

	@td
	
	#map of styles for chart elements
	@sty
	
	#other chart data
	@prolog
	@usercaption
	@linegraph
	
	@dx
	@dy
	@topmargin
	@bottommargin
	@leftmargin
	@rightmargin
	@xsize
	@ysize
	@captionoffset
	@xscaleoffset
	@yscaleoffset
	@niceKey
	
    #A map which stores various named style strings -- see the source for details :)
	attr_accessor :sty
	attr_accessor :prolog
	attr_accessor :usercaption
	attr_accessor :dx
	attr_accessor :dy
	attr_accessor :topmargin
	attr_accessor :bottommargin
	attr_accessor :leftmargin
	attr_accessor :rightmargin
	attr_accessor :xsize
	attr_accessor :ysize
	attr_accessor :captionoffset
	attr_accessor :xscaleoffset
	attr_accessor :yscaleoffset
	attr_accessor :usercaption
	attr_accessor :linegraph
	attr_accessor :nicekey
	
    #This initializer sets a lot of default styles and display values.
	def initialize
		@td = nil
		
		@prolog = <<EOF
		<filter id="closeDropShadow">
    		<feGaussianBlur in="SourceAlpha" stdDeviation="8" result="blur"/>
    		<feOffset in="blur" dx="14" dy="14" result="offsetBlur"/>
   			<feMerge>
				<feMergeNode in="offsetBlur"/>
   				<feMergeNode in="SourceGraphic"/>
			</feMerge>
		</filter>
EOF

		@sty={}
		@sty['xAxis']="stroke:blue;stroke-width:12;"
		@sty['yAxis']="stroke:green;stroke-width:12;"
		@sty['xAxisLbl']="font-size:60px;"
		@sty['yAxisLbl']="font-size:60px;"
		@sty['caption']="font-size:160px;"
		@sty['xAxisLine']="stroke:blue;stroke-width:4;"
		@sty['yAxisLine']="stroke:green;stroke-width:4;"
		@sty['keyLbl']="font-size:50px;"
		@sty['line1']="filter:url(#closeDropShadow);stroke-width:10;fill:none;stroke:red;"
		@sty['line2']="filter:url(#closeDropShadow);stroke-width:10;fill:none;stroke:orange;"
		@sty['line3']="filter:url(#closeDropShadow);stroke-width:10;fill:none;stroke:green;"
		@sty['line4']="filter:url(#closeDropShadow);stroke-width:10;fill:none;stroke:cyan;"
		@sty['line5']="filter:url(#closeDropShadow);stroke-width:10;fill:none;stroke:blue;"
		@sty['line6']="filter:url(#closeDropShadow);stroke-width:10;fill:none;stroke:purple;"
		@sty['line7']="filter:url(#closeDropShadow);stroke-width:10;fill:none;stroke:black;"
		@sty['line8']="filter:url(#closeDropShadow);stroke-width:10;fill:none;stroke:silver;"
		
		@dx=5000.0
		@dy=4000.0
		@topmargin=500.0
		@bottommargin=500.0
		@leftmargin=500.0
		@rightmargin=500.0
		
		@captionoffset=300.0
		@xscaleoffset=40.0
		@yscaleoffset=220.0
		
		@xsize="5in"
		@ysize="4in"
		
		@usercaption = ""
		
		@linegraph = false
		@nicekey = true
		
	end
	
	def bottomEdge
		@dy - @bottommargin
	end
	
	def rightEdge
		@dx - @rightmargin
	end
	
	def chartWidth
		@dx - (@rightmargin + @leftmargin)
	end
	
	def chartHeight
		@dy - (@topmargin + @bottommargin)
	end
	
	
    #This is the very heart of rubywebstat -- a function that returns a string, which contains an SVG chart.
	def emitSVG(timedata, usercaption = "")
	
		@td = timedata
        @usercaption = usercaption
		out=""
		
		out += emitHeader
		
		out += emitKey
		
		out += emitScales
		
		out += emitCaption
		
		out += emitLines
		
		out += emitFooter
	
	end
	
    #Emits a standard header for the chart.  The prolog property is included in this header.  Filters and stuff
    #can thus be defined in the prolog property.
	def emitHeader
		out = ""
		out += "<!DOCTYPE svg>"
		out += %Q(<svg width="#{@xsize}" height="#{@ysize}" viewBox="0 0 #{@dx} #{@dy}">)
		out += @prolog
		
		framemargin = @dx / 100.0
		
		out += <<EOF
		<rect x="0" y="0" width="#{@dx}" height="#{@dy}" style="fill:white; stroke-width:12; stroke:black" />
		<g style="fill:#FFFFFF; stroke-width:15; stroke:black">
			<rect x="#{framemargin}" y="#{framemargin}" width="#{@dx-framemargin*2}" height="#{@dy-framemargin*2}"  />
		</g>
EOF
		out
	end
	
    #Emits a key, showing what lines are associated with what colors.  If the 'nicekey' property is true,
    #the key is integrated with the chart lines, so this method does nothing.
	def emitKey
		out = ""
		
		return out if @nicekey
		
		interval = (chartHeight / 10)
		
		@td.lines.keys.each_with_index{|name, i|
			x = rightEdge + 40
			y = i * interval + @topmargin
			
			out += %Q(<text x="#{x}" y="#{y + interval*0.3}" style="#{@sty['keyLbl']}">#{name}</text>\n)
			out += %Q(<path d=" M #{x} #{y} L #{x+50} #{y-40} L #{x+150} #{y+40} L #{x+200} #{y}" style="#{@sty['line'+(i+1).to_s]}"/>)
		}
		
		out
	end
	
	def emitFooter
		"</svg>"
	end
	
	def emitCaption
		caption = ""
		if @usercaption != "" then
			caption = @usercaption
		else
			caption = "Hits per " + getIntervalText(@td.interval)
		end
		
		%Q(<text x="#{@leftmargin}" y="#{@captionoffset}" style="#{@sty['caption']}">#{caption}</text>)

	end
	
    #Emits the chart's axes, labels, and grid lines.
	def emitScales
		out=""
		
		#x scale has one line per point -- easy
		@td.points.each_with_index{|pt, i|
			x = getXPoint(i)
			out += %Q(<line x1="#{x}" y1="#{@topmargin}" x2="#{x}" y2="#{bottomEdge}" style="#{@sty['xAxisLine']}"/>\n )
			
			out += %Q(<g transform="translate(#{x}, #{bottomEdge + @xscaleoffset})"><text x="0" y="0" style="#{@sty['xAxisLbl']}" transform="rotate(45)">#{pt.strftime("%m/%d/%Y %I:%M%p")}</text></g>\n)	
		}
		
		#y scale is tougher...
		max = @td.maxValue
		
		interval = 5
		interval = 10 if max > 50
		interval = 20 if max > 200
		interval = 50 if max > 400
		interval = 200 if max > 1000
		interval = 500 if max > 5000
		interval = 2000 if max > 20000
		
		#(0..max).step(interval){|n|
		n = 0
		while (n <= max)
			y = getYPoint(n, max)
			out += %Q(<line x1="#{@leftmargin}" y1="#{y}" x2="#{rightEdge}" y2="#{y}" style="#{@sty['yAxisLine']}"/>\n )
		
			out += %Q(<text x="#{@yscaleoffset}" y="#{y}" style="#{@sty['xAxisLbl']}">#{n}</text>\n)
			n += interval
		end	
		
		#major axis lines
		out += %Q(<line x1="#{@leftmargin}" y1="#{bottomEdge}" x2="#{@leftmargin}" y2="#{@topmargin}" style="#{@sty['yAxis']}"/>\n )
		out += %Q(<line x1="#{@leftmargin}" y1="#{bottomEdge}" x2="#{rightEdge}" y2="#{bottomEdge}" style="#{@sty['xAxis']}"/>\n )
		
		out
	end
	
    #Emits lines that represent the actual data series
	def emitLines
		out=""
		max = @td.maxValue 
		
		coloridx = 0
		x=0
		y=0
		style = "line0"
		barwidth = getXPoint(1) - getXPoint(0)
		
		
		@td.lines.each_pair{|name, line|
			style.succ!
			out += %Q(<path stroke-width="12" style="#{@sty[style]}" d=")
			
			line.each_with_index{|count, i|
				x = getXPoint(i)
				y = getYPoint(count, max)
		
				if (i==0) then
					out += "M"
				else
					out += "L"
				end
				
				if (@linegraph) then
					#fudge for readability -- a single point in the middle
					out += " #{x + barwidth/2} #{y} "
				else
					#correct output -- left and right corners of bar top
					out += " #{x} #{y} "
					out += " #{x + barwidth} #{y} "
				end		
			}
			
			out += " #{rightEdge + 200} #{y} " if @nicekey
			
			out += %Q(" />\n)
			
			out += %Q(<text x="#{rightEdge+30}" y="#{y-30}" style="#{@sty['keyLbl']}">#{name}</text>) if @nicekey
		}
		
		
		
		out
	end
	
	def getXPoint (i)
		return i * (chartWidth / (@td.points.length-1)) + @topmargin
	end
	
	def getYPoint (y, max)
	    return 0 if max == 0
		return chartHeight - (y * (chartHeight / max)) + @topmargin
	end

	def getIntervalText(seconds)
	
		if seconds < 3600 then return (seconds / 60.0).to_s + " Minutes" end
		
		if seconds < 86400 then return (seconds / 3600.0).to_s + " Hours" end
		
		if seconds == 86400 then return "Day" end
		
		if seconds == 86400 * 7 then return "Week" end
		
		if seconds == 86400 * 14 then return "Fortnight" end
		
		if seconds < (86400 * 2) then return (seconds / 3600.0).to_s + " Hours" end
		
		return (seconds / 86400.0).to_s + " Days"
		
	end
end

#!/usr/bin/ruby
require 'rubywebstat.rb'

# This script just uses LogReader to read an apache log and 
# output a shorter version that contains only time, url and 'referer'.

infile=ARGV.shift
outfile=ARGV.shift

fromyear=ARGV.shift
fromyear||=2002
frommon=ARGV.shift
frommon||="jan"
fromday=ARGV.shift
fromday||=1
fromhour=ARGV.shift
fromhour||=12
frommin=ARGV.shift
frommin||=0
fromsec=ARGV.shift
fromsec||=0

lr = LogReader.new()

lr.readApacheLog infile, Time.gm(fromyear, frommon,fromday,fromhour,frommin,fromsec), Time.now, /^crawl/, /(png$|gif$|xml$|css$|jpeg$|robots)/

lr.writeRWSData outfile 
