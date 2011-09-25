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

ARGUMENT_INDEX_TITLE = 0
ARGUMENT_INDEX_LOCATION = 1
ARGUMENT_INDEX_WEEKS = 2
ARGUMENT_INDEX_TEACHER = 3
ARGUMENT_INDEX_UNKNOWN = 4

class Entry
	attr_accessor :weekday
	attr_accessor :start_time
	attr_accessor :end_time
	attr_accessor :title
	attr_accessor :teacher
	attr_accessor :location
	attr_accessor :weeks

	def initialize(weekday, start_time, end_time, title, teacher, location, weeks)
		@weekday = weekday
		@start_time = start_time
		@end_time = end_time
		@title = title
		@teacher = teacher
		@location = location
		@weeks = self.parse_weeks(weeks)
	end

	def parse_weeks(weeks)
		# Possible formats:
		# * 5
		# * 5, 10
		# * 5-7
		# * 5-7, 10
		array = []
		weeks.split(',').each do |item|
			args = item.split('-')
			first = args[0].to_i
			last = args.size > 1 ? args[1].to_i : first
			array = array | Array.new(last - first + 1) { |index| index + first }
		end
		return array
	end
end

entries = []

# TODO load from HTML
year = 2011
month = 9
day = 19

# TODO load from HTML
times = [[8, 00],[8, 30],[9, 00],[9, 30],[10, 00],[10, 30],[11, 00],[11, 30],[12, 00],[12, 30],[13, 00],[13, 30],[14, 00],[15, 30],[15, 00],[15, 30],[16, 00],[16, 30],[17, 00],[17, 30],[18, 00],[18, 30],[19, 00],[19, 30],[20, 00]]

uri = 'example.html'
document = Nokogiri::HTML(open(uri))

rows = document.xpath('/html/body/table[@class="grid-border-args"]/tbody/tr')
while row = rows.shift() do
	first_column = row.xpath('td[@class="row-label-one"]').first
	if first_column then
		weekday = WEEYDAY_MAP[first_column.inner_html]
		height = first_column.attribute('rowspan').value.to_i
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
