require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'ri_cal'

WEEKDAY_MONDAY = 'ma'
WEEKDAY_TUESDAY = 'di'
WEEKDAY_WEDNESDAY = 'wo'
WEEKDAY_THURSDAY = 'do'
WEEKDAY_FRIDAY = 'vr'
WEEKDAY_SATURDAY = 'za'
WEEYDAY_MAP = {
	WEEKDAY_MONDAY => 0,
	WEEKDAY_TUESDAY => 1,
	WEEKDAY_WEDNESDAY => 2,
	WEEKDAY_THURSDAY => 3,
	WEEKDAY_FRIDAY => 4,
	WEEKDAY_SATURDAY => 5
}

MONTH_JANUARY = 'jan'
MONTH_FEBRUARY = 'feb'
MONTH_MARCH = 'mar'
MONTH_APRIL = 'apr'
MONTH_MAY = 'may'
MONTH_JUNE = 'jun'
MONTH_JULY = 'jul'
MONTH_AUGUST = 'aug'
MONTH_SEPTEMBER = 'sep'
MONTH_OCTOBER = 'okt'
MONTH_NOVEMBER = 'nov'
MONTH_DECEMBER = 'dec'
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

class Entry
	attr_accessor :start_time
	attr_accessor :end_time
	attr_accessor :weekday
	attr_accessor :weeks
	attr_accessor :title
	attr_accessor :teacher
	attr_accessor :location

	def initialize(weekday, start_time, end_time, title, teacher, location, weeks)
		@weekday = weekday
		@start_time = start_time
		@end_time = end_time
		@title = title
		@teacher = teacher
		@location = location
		@weeks = self.parse_weeks(weeks)
	end

	# Possible formats:
	# * 5
	# * 5, 10
	# * 5-7
	# * 5-7, 10
	def parse_weeks(weeks)
		array = []
		weeks.split(',').each do |item|
			first, last = item.split('-').map { |item| item.to_i }
			size = last.nil? ? 1 : last - first + 1
			array = array | Array.new(size) { |index| index + first }
		end
		return array
	end
end

entries = []

# Parse HTML file
uri = 'example.html'
document = Nokogiri::HTML(open(uri))
table_header = document.xpath('/html/body/table[@class="header-border-args"]/tbody')
table_grid = document.xpath('/html/body/table[@class="grid-border-args"]/tbody')

# Load reference date
day, month, year = table_header.xpath('tr/td/table[@class="header-6-args"]/tbody/tr/td/span[@class="header-6-0-3"]').first.inner_html.split(' ')
day = day.to_i
month = MONTH_MAP[month]
year = year.to_i

# Load times
times = []
table_grid.xpath('tr/td[@class="col-label-one"]').each do |column|
	time = column.inner_html
	times.push(time.split(':'))
end

# Load entries
rows = table_grid.xpath('tr')
while row = rows.shift() do
	weekday_column = row.xpath('td[@class="row-label-one"]').first
	if weekday_column then
		weekday = WEEYDAY_MAP[weekday_column.inner_html]
		height = weekday_column.attribute('rowspan').value.to_i
		while true do
			position = 0
			row.xpath('td[@class="cell-border"] | td[@class="object-cell-border"]').each do |column|
				size = 1
				if column.attribute('class').value.eql?('object-cell-border') then
					arguments = column.xpath('table[@class="object-cell-args"]/tbody/tr/td').map { |item| item.inner_html }
					size = column.attribute('colspan').value.to_i
					start_time = times[position]
					end_time = times[position + size]
					entry = Entry.new(weekday, start_time, end_time, arguments[ARGUMENT_INDEX_TITLE], arguments[ARGUMENT_INDEX_TEACHER], arguments[ARGUMENT_INDEX_LOCATION], arguments[ARGUMENT_INDEX_WEEKS])
					entries.push(entry)
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

calendar = RiCal.Calendar
entries.each do |entry|
	entry.weeks.each do |week|
		date = Date::civil(year, month, day) + (week - 1) * 7 + entry.weekday
		event = RiCal.Event
		event.summary = entry.title
		event.description = entry.teacher
		event.location = entry.location
		event.dtstart = Time.parse("%04d-%02d-%02dT%02d:%02d:00+02:00" % [date.year, date.month, date.day, entry.start_time[0], entry.start_time[1]]).getutc
		event.dtend = Time.parse("%04d-%02d-%02dT%02d:%02d:00+02:00"  % [date.year, date.month, date.day, entry.end_time[0], entry.end_time[1]]).getutc
		calendar.add_subcomponent(event)
	end
end

puts calendar.to_s
