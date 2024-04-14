// Test sender for syncing time

// patch
SinOsc s => JCRev r => dac;
.0 => s.gain;
.1 => r.mix;
220 => s.sfreq;
// ms between pulses
10 => int pulse;


// destination host name
"localhost" => string hostname;
// destination port number
int ports[2];
6449 => ports[0];
6459 => ports[1];

// sender object
OscOut xmit[2];

// aim the transmitter at destination
for ( int i; i < xmit.size(); i++ )
{
  xmit[i].dest( hostname, ports[i] );
}

// infinite time loop
while( true )
{
  for ( int i; i < xmit.size(); i++ )
  {
    xmit[i].start( "/pulse" );
    pulse => xmit[i].add;
    xmit[i].send();
    pulse::ms => now;
  }
}