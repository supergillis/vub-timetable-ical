class Course
	attr_accessor :title
	attr_accessor :teacher
	attr_accessor :location

	def initialize(title, teacher, location)
		@title = title
		@teacher = teacher
		@location = location
	end
end
