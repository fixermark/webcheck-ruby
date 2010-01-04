$: << ".."

require 'start_server'
require 'test/unit/ui/console/testrunner'
require 'test/unit/testsuite'
require 'test_webcheck'
require 'test_environ'

#spin off WEBrick server on its own
server,serverthread = launchServer

#execute tests
suite = Test::Unit::TestSuite.new
suite << TC_Environ.suite
suite << TC_Webcheck.suite
Test::Unit::UI::Console::TestRunner.run(suite)

# Finished testing
server.shutdown
serverthread.join