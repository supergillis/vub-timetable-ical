require "rubygems"
require "open-uri"
require "nokogiri"
require "sinatra/base"

require "./parser"
require "./exporter_factory"

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
			parameters = {
				:idtype => "name",
				:template => "Student Set Individual",
				:objectclass => "Student Set",
				:identifier => params["identifier"],
				:weeks => params["weeks"]
			}
			uri = "http://locus.vub.ac.be/reporting/individual?idtype=%{idtype}&template=%{template}&objectclass=%{objectclass}&identifier=%{identifier}&weeks=%{weeks}" % parameters
			uri.gsub!(' ', '+') # Replace spaces with +

			# Parse the URI and print the iCal
			parser = Parser.new
			schedule = parser.parse(uri)
			exporter_type = params.has_key?("exporter") ? params["exporter"] : ExporterFactory::TYPE_ICAL
			exporter = ExporterFactory.make exporter_type
			exporter.export(schedule)
		else
			redirect '/usage'
		end
	end
	
	run!
end

Provider.new
