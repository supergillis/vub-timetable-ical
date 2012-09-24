require "rubygems"
require "nokogiri"
require "open-uri"

require "./schedule"
require "./schedule_entry"
require "./course"

WEEKDAY_MONDAY = "ma"
WEEKDAY_TUESDAY = "di"
WEEKDAY_WEDNESDAY = "wo"
WEEKDAY_THURSDAY = "do"
WEEKDAY_FRIDAY = "vr"
WEEKDAY_SATURDAY = "za"
WEEYDAY_MAP = {
	WEEKDAY_MONDAY => 0,
	WEEKDAY_TUESDAY => 1,
	WEEKDAY_WEDNESDAY => 2,
	WEEKDAY_THURSDAY => 3,
	WEEKDAY_FRIDAY => 4,
	WEEKDAY_SATURDAY => 5
}

MONTH_JANUARY = "jan"
MONTH_FEBRUARY = "feb"
MONTH_MARCH = "mar"
MONTH_APRIL = "apr"
MONTH_MAY = "may"
MONTH_JUNE = "jun"
MONTH_JULY = "jul"
MONTH_AUGUST = "aug"
MONTH_SEPTEMBER = "sep"
MONTH_OCTOBER = "okt"
MONTH_NOVEMBER = "nov"
MONTH_DECEMBER = "dec"
MONTH_MAP = {
	MONTH_JANUARY => 1,
	MONTH_FEBRUARY => 2,
	MONTH_MARCH => 3,
	MONTH_APRIL => 4,
	MONTH_MAY => 5,
	MONTH_JUNE => 6,
	MONTH_JULY => 7,
	MONTH_AUGUST => 8,
	MONTH_SEPTEMBER => 9,
	MONTH_OCTOBER => 10,
	MONTH_NOVEMBER => 11,
	MONTH_DECEMBER => 12
}

ARGUMENT_INDEX_TITLE = 0
ARGUMENT_INDEX_LOCATION = 1
ARGUMENT_INDEX_WEEKS = 2
ARGUMENT_INDEX_TEACHER = 3
ARGUMENT_INDEX_UNKNOWN = 4

class Parser
	def parse(uri)
		@document = Nokogiri::HTML(open(uri))
		@table_header = @document.xpath("/html/body/table[@class='header-border-args']")
		@table_grid = @document.xpath("/html/body/table[@class='grid-border-args']")
		@schedule = Schedule.new
		parse_reference_date
		parse_blocks
		parse_schedule
		return @schedule
	end
	
	def parse_reference_date
		@day, @month, @year = @table_header.xpath("tr/td/table[@class='header-6-args']/tr/td/span[@class='header-6-0-3']").first.inner_html.split(" ")
		@day = @day.to_i
		@month = MONTH_MAP[@month]
		@year = @year.to_i
	end
	
	def parse_blocks
		@blocks = []
		@table_grid.xpath("tr/td[@class='col-label-one']").each do |column|
			hour, minute = column.inner_html.split(":")
			@blocks.push([hour.to_i, minute.to_i])
		end
	end
	
	def parse_schedule
		rows = @table_grid.xpath("tr")
		while row = rows.shift() do
			weekday_column = row.xpath("td[@class='row-label-one']").first
			if weekday_column then
				weekday = WEEYDAY_MAP[weekday_column.inner_html]
				height = weekday_column.attribute("rowspan").value.to_i
				while true do
					position = 0
					row.xpath("td[@class='cell-border'] | td[@class='object-cell-border']").each do |column|
						size = 1
						if column.attribute("class").value.eql?("object-cell-border") then
							arguments = column.xpath("table[@class='object-cell-args']/tr/td").map { |item| item.inner_html }
							course = Course.new(arguments[ARGUMENT_INDEX_TITLE], arguments[ARGUMENT_INDEX_TEACHER], arguments[ARGUMENT_INDEX_LOCATION])
							size = column.attribute("colspan").value.to_i
							start_time = @blocks[position]
							end_time = @blocks[position + size]
							weeks = Parser.week_string_to_array(arguments[ARGUMENT_INDEX_WEEKS])
							weeks.each do |week|
								offset = weekday * 24 * 60 * 60 + (week - 1) * 7 * 24 * 60 * 60
								start_date = Time::utc(@year, @month, @day, start_time[0], start_time[1]) + offset
								end_date = Time::utc(@year, @month, @day, end_time[0], end_time[1]) + offset
								entry = ScheduleEntry.new(course, start_date, end_date)
								@schedule.push(entry)
							end
						end
						position = position + size
					end
					# Shift to the next row
					if height > 1 then
						row = rows.shift()
						height = height - 1
						next
					end
					break
				end
			end
		end
	end
	
	def self.week_string_to_array(weeks)
		array = []
		weeks.split(",").each do |item|
			first, last = item.split("-").map { |item| item.to_i }
			size = last.nil? ? 1 : last - first + 1
			array = array | Array.new(size) { |index| index + first }
		end
		return array
	end
end
