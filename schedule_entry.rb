class ScheduleEntry
	attr_accessor :course
	attr_accessor :start_date
	attr_accessor :end_date
	
	def initialize(course, start_date, end_date)
		@course = course
		@start_date = start_date
		@end_date = end_date
	end
end
