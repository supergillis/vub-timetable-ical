require "json"
require "nokogiri"
require "open-uri"
require "rubygems"
require "sinatra/base"

require "./exporter_factory"
require "./parser"
require "./schedule_collection"

class Provider < Sinatra::Application
	set :port, 8081
	set :sessions, false
	
	get '/' do
		redirect '/usage'
	end
	
	get '/usage' do
		"usage http://wilma.vub.ac.be:8081/ics/?identifier={identifier}&weeks={weeks}<br />" +
		"identifier is the name of the course (e.g. 1+M+Computerwetenschappen/Software+Engineering) and the weeks are of the form 1 or 1-14 or 1,3,5-14"
	end
	
	get '/ics' do
		if params.has_key?("identifier") and params.has_key?("weeks") then
			# Create the URI
			uri = "http://locus.vub.ac.be:8080/reporting/individual?idtype=name&template=Student+Set+Individual&objectclass=Student+Set&identifier=%s&weeks=%s" % [params["identifier"], params["weeks"]]
			uri.gsub!(' ', '+') # Replace spaces with +

			# Parse the URI and print the iCal
			parser = Parser.new
			schedule = parser.parse(uri)
			exporter_type = params.has_key?("exporter") ? params["exporter"] : ExporterFactory::TYPE_ICAL
			exporter = ExporterFactory.make exporter_type
			exporter.export(schedule)
		elsif params.has_key?("id") then
			id = params["id"]
			file = File.read("%s.json" % id)

			schedule_collection = ScheduleCollection.new
			entries = JSON.parse(file)
			entries.each do |entry|
				uri = "http://locus.vub.ac.be:8080/reporting/individual?idtype=name&template=Student+Set+Individual&objectclass=Student+Set&identifier=%s&weeks=%s" % [entry["identifier"], entry["weeks"]]
				uri.gsub!(' ', '+') # Replace spaces with +
								
				# Parse the URI and print the iCal
				parser = Parser.new
				schedule = parser.parse(uri)
				schedule_collection.schedule(schedule, entry["courses"])
			end

			exporter_type = params.has_key?("exporter") ? params["exporter"] : ExporterFactory::TYPE_ICAL
			exporter = ExporterFactory.make exporter_type
			exporter.export(schedule_collection)
		else
			redirect '/usage'
		end
	end
	
	run!
end

Provider.new
