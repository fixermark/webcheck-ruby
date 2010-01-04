require 'webrick'

def launchServer
    s = WEBrick::HTTPServer.new(
	:Port => 3001,
	:Logger => WEBrick::Log.new("webrick.log",WEBrick::Log::INFO),
	:AccessLog => [[File.open("webrick_access.log",'w'),WEBrick::AccessLog::COMBINED_LOG_FORMAT]],
    	:DocumentRoot => File.join(Dir.pwd, "/site")
    )
    trap("INT") {s.shutdown}
    t = Thread.new do
        s.start
    end
    return s,t
end
