class ScheduleCollection < Array
	def schedule(schedule, courses)
		schedule.each do |schedule_entry|
			self.push(schedule_entry) if 
courses.include?(schedule_entry.course.name)
		end
	end
end
