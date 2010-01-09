$: << ".."

require 'start_server'
require 'test/unit/ui/console/testrunner'
require 'test/unit/testsuite'
require 'test_linkfinder'
require 'test_webcrawler'
require 'test_environ'

#spin off WEBrick server on its own
server,serverthread = launchServer

#execute tests
suite = Test::Unit::TestSuite.new("Total suite")
suite << TC_Environ.suite
suite << TC_Linkfinder.suite
suite << TC_Webcrawler.suite
Test::Unit::UI::Console::TestRunner.run(suite)

# Finished testing
server.shutdown
serverthread.join