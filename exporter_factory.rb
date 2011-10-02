require "./exporter_ical"
require "./exporter_html"

class ExporterFactory
	TYPE_ICAL = "ical"
	TYPE_HTML = "html"

	def self.make(exporter_type)
		case exporter_type
			when TYPE_ICAL
				return ICalExporter.new
			when TYPE_HTML
				return HTMLExporter.new
		end
		return ICalExporter.new
	end
end
