require "rubygems"
require "open-uri"
require "nokogiri"
require "sinatra/base"

require "./parser"
require "./exporter_ical"

class Provider < Sinatra::Application
	set :port, 9494
	set :sessions, false
	
	get '/ics/' do
		# Load all URI parameters
		idtype = "name"
		template = "Student Set Individual"
		objectclass = "Student Set"
		identifier = params[:identifier]
		weeks = params[:weeks]
		# Create the URI
		uri = "http://locus.vub.ac.be/reporting/individual?idtype=#{idtype}&template=#{template}&objectclass=#{objectclass}&identifier=#{identifier}&weeks=#{weeks}".gsub(' ', '+')
		# Parse the URI and print the iCal
		parser = Parser.new
		schedule = parser.parse(uri)
		exporter = ICalExporter.new
		exporter.export(schedule)
	end
	
	run!
end

Provider.new
