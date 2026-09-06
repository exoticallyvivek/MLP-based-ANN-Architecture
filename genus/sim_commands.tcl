# SimVision TCL commands for irun
database -open waves -shm
probe -create -database waves nn_core4_tb -all -depth all
run
