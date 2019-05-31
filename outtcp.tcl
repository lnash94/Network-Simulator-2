# Create a ns object
set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

# Open the Trace files
set TraceFile [open outtcp.tr w]
$ns trace-all $TraceFile

# Open the NAM trace file
set NamFile [open outtcp.nam w]
$ns namtrace-all $NamFile

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n2 5Mb 10ms DropTail
$ns duplex-link $n1 $n2 5Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.25Mb 20ms DropTail # bottleneck link
$ns duplex-link $n3 $n4 5Mb 10ms DropTail
$ns duplex-link $n3 $n5 5Mb 10ms DropTail

$ns queue-limit $n2 $n3 20

#Define the layout of the topology
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

#TCP N0 and N4
#Create a TCP agent and attach it to node n0
set tcp0 [new Agent/TCP/Newreno]
$ns attach-agent $n0 $tcp0
$tcp0 set fid_ 1

#Create a TCP agent and attach it to node n0
set tcp1 [new Agent/TCP/Newreno]
$ns attach-agent $n1 $tcp1
$tcp1 set fid_ 2


#Create TCP sink agents and attach them to node n4,n5
set sink0 [new Agent/TCPSink/DelAck]
set sink1 [new Agent/TCPSink/DelAck]
$ns attach-agent $n4 $sink0
$ns attach-agent $n5 $sink1

#Connect the traffic sources with the traffic sinks
$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1

#FTP TCP N0 and N4
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP

#FTP TCP N1 and N5
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

#Monitor the queues for links
$ns duplex-link-op $n2 $n3 queuePos 0.5

$ns at 0.1 "$ftp0 start"
$ns at 2.0 "$ftp1 start"
$ns at 10.0 "$ftp0 stop"
$ns at 12.0 "$ftp1 stop"

proc finish {} {
        global ns TraceFile NamFile 
        $ns flush-trace
        close $TraceFile
        close $NamFile
        exec nam outtcp.nam &
        exit 0
}

$ns at 12.5 "finish"
$ns run
