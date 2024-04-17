// Send one message for syncing

// HID input and HID message
Hid hi;
HidMsg msg;
0 => int device;

if( !hi.openKeyboard( device ) ) me.exit();

100 => int pulse;

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

// infinite event loop
while( true )
{
    // wait on event
    hi => now;

    // get one or more messages
    while( hi.recv( msg ) )
    {
        // check for action type
        if( msg.isButtonDown() )
        {
          for ( int i; i < xmit.size(); i++ )
          {
            xmit[i].start( "/sync" );
            if ( 29 < msg.which && msg.which < 40 )
            {
              100 * (msg.which - 29) => xmit[i].add;
            } 
            xmit[i].send();
          }
        }
    }
}