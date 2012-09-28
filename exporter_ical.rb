require "rubygems"
require "ri_cal"

class ICalExporter
	def export(schedule)
		calendar = RiCal.Calendar
		schedule.sort {|a, b| a.start_date <=> b.start_date }
		schedule.each do |entry|
			event = RiCal.Event
			event.summary = entry.course.name
			event.description = entry.course.teacher
			event.location = entry.course.location
			event.dtstart = Time.local(entry.start_date.year, entry.start_date.month, entry.start_date.day, entry.start_date.hour, entry.start_date.min).getutc
			event.dtend = Time.local(entry.end_date.year, entry.end_date.month, entry.end_date.day, entry.end_date.hour, entry.end_date.min).getutc
			calendar.add_subcomponent(event)
		end
		calendar.to_s
	end
end
