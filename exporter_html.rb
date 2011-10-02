class HTMLExporter
	def export(schedule)
		result = "<table><tr><th>Title</th><th>Teacher</th><th>Location</th><th>Start</th><th>End</th></tr>"
		schedule.sort!
		schedule.each do |entry|
			result += "<tr>"
			result += "<td>" + entry.course.title + "</td>"
			result += "<td>" + entry.course.teacher + "</td>"
			result += "<td>" + entry.course.location + "</td>"
			result += "<td>" + entry.start_date.to_s + "</td>"
			result += "<td>" + entry.end_date.to_s + "</td>"
			result += "</tr>"
		end
		result + "</table>"
	end
end
