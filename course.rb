class Course
	attr_accessor :name
	attr_accessor :teacher
	attr_accessor :location

	def initialize(name, teacher, location)
		@name = name
		@teacher = teacher
		@location = location
	end
end
