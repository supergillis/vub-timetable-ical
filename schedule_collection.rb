class ScheduleCollection < Array
	def schedule(schedule, courses)
		puts courses
		schedule.each do |schedule_entry|
			puts schedule_entry.course.title
			self.push(schedule_entry) if courses.include?(schedule_entry.course.title)
		end
	end
end
