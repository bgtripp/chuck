// Send one message for syncing

// Number of receiving programs
4 => int N_RECEIVERS;
// destination host name
"localhost" => string hostname;
// destination port number
int ports[N_RECEIVERS];
for ( int i; i < N_RECEIVERS; i++ )
{
  (i + 1) * 1111 => ports[i];
}

// sender object
OscOut xmit[N_RECEIVERS];

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