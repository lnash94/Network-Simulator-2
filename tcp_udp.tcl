set ns  [ new Simulator ]

$ns color 1 Blue
$ns color 2 Red

set NamFile [ open tcp_udp.nam w ]
$ns namtrace-all $NamFile

set TraceFile [ open tcp_udp.tr w ]
$ns trace-all $TraceFile

#proc finish {} {
#	global ns nf tf
#	$ns flush-trace
#	close $nf
#	close $tf
#	exec xdg-open [file normalize  tcp_udp.nam] &
#	exit 0
#}
set n0 [ $ns node ]
set n1 [ $ns node ]
set n2 [ $ns node ]
set n3 [ $ns node ]
set n4 [ $ns node ]
set n5 [ $ns node ]

$ns duplex-link $n0 $n2 5Mb 10ms DropTail
$ns duplex-link $n1 $n2 5Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.25Mb 20ms DropTail #bottelneck link
$ns duplex-link $n3 $n4 5Mb 10ms DropTail
$ns duplex-link $n3 $n5 5Mb 10ms DropTail

$ns queue-limit $n2 $n3 10

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

#$ns duplex-link-op $n2 $n3 queuePos 0.5

#TCP
set tcp [ new Agent/TCP ]
$tcp set class_ 2
$tcp set packetSize_ 960
$ns attach-agent $n0 $tcp

# Let's trace some variables
$tcp attach $TraceFile
$tcp tracevar cwnd_
$tcp tracevar ssthresh_
$tcp tracevar ack_
$tcp tracevar maxseq_


set sink [ new Agent/TCPSink ]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink 
$tcp set fid_ 1

#FTP
set ftp [ new Application/FTP ]
$ftp attach-agent $tcp
$ftp set type_ FTP

#UDP
#Create a Null agent (a traffic sink) and attach it to node n(5)
set udp [ new Agent/UDP ]
$udp set packet_size_ 960
$ns attach-agent $n1 $udp

# Let's trace some variables
$udp attach $TraceFile
$udp tracevar cwnd_
$udp tracevar ssthresh_
$udp tracevar ack_
$udp tracevar maxseq_


set null [ new Agent/Null]
$ns attach-agent $n5 $null
$ns connect $udp $null
$udp set fid_ 2

#CBR
set cbr [ new Application/Traffic/CBR ]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 500
$cbr set interval_ 0.005
#$cbr set packet_size_ 1000
#$cbr set rate_ 1mb
$cbr set random_ false

#Monitor the queues for links
$ns duplex-link-op $n2 $n3 queuePos 0.5

$ns at 0.1 "$ftp start"
$ns at 2.0 "$cbr start"
$ns at 10.0 "$cbr stop"
$ns at 10.0 "$ftp stop"

proc finish {} {
        global ns TraceFile NamFile 
        $ns flush-trace
        close $TraceFile
        close $NamFile
        exec nam tcp_udp.nam &
        exit 0
}


$ns at 10.5 "finish"
$ns run















































