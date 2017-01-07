function run()
	print("\nExecution 'run.lua' now\n")
	dofile('run.lua')
end

function stop()
	tmr.stop(0)
	print("Automatic execution of 'run.lua' stopped")
end

print("\n\nFLN Loader V0.1\nLoading 'run.lua' in 10 seconds. Type 'stop()' to cancel")
tmr.alarm(0,10000,tmr.ALARM_SINGLE,run)
