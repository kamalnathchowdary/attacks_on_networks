# Define options
set val(chan)           Channel/WirelessChannel                  ;#Channel Type
set val(prop)           Propagation/TwoRayGround                 ;# radio-propagation model
set val(netif)          Phy/WirelessPhy                          ;# network interface type
set val(mac)            Mac/802_11                               ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue                  ;# interface queue type
set val(ll)             LL                                       ;# link layer type
set val(ant)            Antenna/OmniAntenna                      ;# antenna model
set val(ifqlen)         150                                      ;# max packet in ifq
set val(nn)             8                                       ;# total number of mobilenodes
set val(rp)             AODV                                     ;# routing protocol
set val(x)              700                                      ;# X dimension of topography
set val(y)              700                                      ;# Y dimension of topography
set val(cstop)          10                                      ;# time of connections end
set val(stop)           10                                     ;# time of simulation end


set ns_ [new Simulator]

$ns_ use-newtrace
set tracefd [open AODV.tr w]
$ns_ trace-all $tracefd

set namtrace [open AODV.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

$ns_ node-config        -adhocRouting $val(rp) \
                        -llType $val(ll) \
                        -macType $val(mac) \
                        -ifqType $val(ifq) \
                        -ifqLen $val(ifqlen) \
                        -antType $val(ant) \
                        -propType $val(prop) \
                        -phyType $val(netif) \
                        -topoInstance $topo \
                        -agentTrace ON \
                        -routerTrace ON \
                        -macTrace ON \
                        -movementTrace ON \
                        -channel $chan_1_
						
set node_(0) [$ns_ node]
set node_(1) [$ns_ node]
set node_(2) [$ns_ node]
set node_(3) [$ns_ node]
set node_(4) [$ns_ node]
set node_(5) [$ns_ node]
set node_(6) [$ns_ node]
set node_(7) [$ns_ node]

$node_(0) set X_ 50.0
$node_(0) set Y_ 150.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 150.0
$node_(1) set Y_ 250.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 200.0
$node_(2) set Y_ 450.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 300.0
$node_(3) set Y_ 250.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 350.0
$node_(4) set Y_ 225.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 150.0
$node_(5) set Y_ 50.0
$node_(5) set Z_ 0.0

$node_(6) set X_ 300.0
$node_(6) set Y_ 50.0
$node_(6) set Z_ 0.0

$node_(7) set X_ 350.0
$node_(7) set Y_ 75.0
$node_(7) set Z_ 0.0

set god_ [God instance]

set udp [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp
set null [new Agent/Null]
$ns_ attach-agent $node_(4) $null

set cbr [new Application/Traffic/CBR]
$cbr set packet_size_ 512
$cbr set interval_ 1
$cbr set rate_ 10kb
$cbr set random_ false
$cbr attach-agent $udp
$ns_ connect $udp $null

$ns_ at 0.01 "$cbr start"
$ns_ at 0.01 "$node_(0) label \"Source\""
$ns_ at 0.01 "$node_(4) label \"Destination1\""

set udp1 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp1
set null1 [new Agent/Null]
$ns_ attach-agent $node_(7) $null1

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packet_size_ 512
$cbr1 set interval_ 1
$cbr1 set rate_ 10kb
$cbr1 set random_ false
$cbr1 attach-agent $udp1
$ns_ connect $udp1 $null1

$ns_ at 5.0 "$cbr1 start"
$ns_ at 5.0 "$node_(7) label \"Destination2\""

$ns_ initial_node_pos $node_(0) 10
$ns_ initial_node_pos $node_(1) 10
$ns_ initial_node_pos $node_(2) 10
$ns_ initial_node_pos $node_(3) 10
$ns_ initial_node_pos $node_(4) 10
$ns_ initial_node_pos $node_(5) 10
$ns_ initial_node_pos $node_(6) 10
$ns_ initial_node_pos $node_(7) 10

$ns_ at 3.0 "[$node_(2) set ragent_] malicious"
$ns_ at 3.0 "$node_(2) label \"Grayhole\""

$ns_ at $val(cstop) "$cbr stop"
$ns_ at $val(cstop) "$cbr1 stop"

$ns_ at $val(stop).000000001 "$node_(0) reset";
$ns_ at $val(stop).000000001 "$node_(1) reset";
$ns_ at $val(stop).000000001 "$node_(2) reset";
$ns_ at $val(stop).000000001 "$node_(3) reset";
$ns_ at $val(stop).000000001 "$node_(4) reset";
$ns_ at $val(stop).000000001 "$node_(5) reset";
$ns_ at $val(stop).000000001 "$node_(6) reset";
$ns_ at $val(stop).000000001 "$node_(7) reset";

$ns_ at $val(stop) "finish"

proc finish {} {
global ns_ tracefd namtrace
$ns_ flush-trace
close $tracefd
close $namtrace
exec nam AODV.nam &
exit 0
}

puts "Starting Simulation..."
$ns_ run