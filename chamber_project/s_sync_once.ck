// Send one message for syncing

// destination host name
"localhost" => string hostname;
// destination port number
int ports[2];
4444 => ports[0];
5555 => ports[1];
400 => int pulse;

// sender object
OscOut xmit[2];

// aim the transmitter at destination
for ( int i; i < xmit.size(); i++ )
{
  xmit[i].dest( hostname, ports[i] );
}

for ( int i; i < xmit.size(); i++ )
{
  xmit[i].start( "/sync" );
  xmit[i].send();
}

