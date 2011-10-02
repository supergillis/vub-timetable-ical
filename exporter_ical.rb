require "rubygems"
require "ri_cal"

class ICalExporter
	def export(schedule)
		calendar = RiCal.Calendar
		schedule.each do |entry|
			event = RiCal.Event
			event.summary = entry.course.title
			event.description = entry.course.teacher
			event.location = entry.course.location
			event.dtstart = Time.parse("%04d-%02d-%02dT%02d:%02d:00+02:00" % [entry.start_date.year, entry.start_date.month, entry.start_date.day, entry.start_date.hour, entry.start_date.min]).getutc
			event.dtend = Time.parse("%04d-%02d-%02dT%02d:%02d:00+02:00" % [entry.end_date.year, entry.end_date.month, entry.end_date.day, entry.end_date.hour, entry.end_date.min]).getutc
			calendar.add_subcomponent(event)
		end
		calendar.to_s
	end
end
