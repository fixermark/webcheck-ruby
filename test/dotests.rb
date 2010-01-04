$: << ".."

require 'start_server'
require 'test_environ'
require 'test/unit/ui/console/testrunner'


#spin off WEBrick server on its own
server,serverthread = launchServer

#execute tests
Test::Unit::UI::Console::TestRunner.run(TC_Environ)

# Finished testing
server.shutdown
serverthread.join