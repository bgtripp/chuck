// ORCHESTRATE dendrop

"224.0.0.1" => string hostname;
if ( me.args() )
{
  if ( me.arg(0) == "l" )
  {
    "localhost" => hostname;
  }

  if ( me.arg(1) == "k" )
  {
    spork ~ keeb();
  } 
  else
  {
    spork ~ gametrak();
  }
}


7777 => int port;

// Multiples for each instrument's polyrhythm
[2, 3, 5, 7, 9, 11, 13, 17] @=> int d[];
0 => int foot_switch;
1000 => int pulse;
1000 => int MAX_TEMPO;
25 => int MIN_TEMPO;

OscOut xmit;
xmit.dest( hostname, port );

fun sendCommand( int receiver, int instrument )
{
  xmit.start( "/orchestrate" );
  receiver => xmit.add;
  instrument => xmit.add;
  xmit.send();
}
 
fun void droop() 
{
  0 => int count;

  while ( true )
  {
    for (int i; i < d.size(); i++)
    {
      if ( foot_switch > i && count % d[i] == 0)
      {
        <<< "Sending command: ", 0, i >>>;
        sendCommand( 0, i );
      }
    }

    pulse::ms => now;
    count + 1 => count;
  }
}

fun void keeb()
{
  Hid hi;
  HidMsg msg;
  0 => int device;
  if( !hi.openKeyboard( device ) ) me.exit();
  <<< "keyboard '" + hi.name() + "' ready", "" >>>;

  while ( true )
  {
    // wait on event
    hi => now;

    // get one or more messages
    while ( hi.recv( msg ) )
    {
        if( msg.isButtonDown() )
        {
          if ( msg.which == 40 )
          {
            ( foot_switch + 1 ) % d.size() => foot_switch;
          }
          else if ( msg.which == 44 )
          {
            sendCommand( 0, 100 );
          }
          else if ( msg.which == 82 )
          {
            Math.max( pulse - 100, 10) => pulse;
          }
          else if ( msg.which == 81 )
          {
            pulse + 100 => pulse;
          }
        }
    }
  }
}

class GameTrak
{
    time lastTime;
    time currTime;
    
    float lastAxis[6];
    float axis[6];
}

fun void gametrak()
{
  Hid trak;
  HidMsg msg;
  0 => int device;
  if( !trak.openJoystick( device ) ) me.exit();
  <<< "joystick '" + trak.name() + "' ready", "" >>>;

  GameTrak gt;
  while( true )
  {
    // wait on HidIn as event
    trak => now;
    
    // messages received
    while( trak.recv( msg ) )
    {
      // joystick axis motion
      if( msg.isAxisMotion() )
      {            
        // check which
        if( msg.which >= 0 && msg.which < 6 )
        {
          // check if fresh
          if( now > gt.currTime )
          {
              gt.currTime => gt.lastTime;
              now => gt.currTime;
          }
          // save last
          gt.axis[msg.which] => gt.lastAxis[msg.which];
          // the z axes map to [0,1], others map to [-1,1]
          if( msg.which != 2 && msg.which != 5 )
          { msg.axisPosition => gt.axis[msg.which]; }
          else
          {
              1 - ((msg.axisPosition + 1) / 2) => gt.axis[msg.which];
              if( gt.axis[msg.which] < 0 ) 0 => gt.axis[msg.which];
          }
        }
      }
      
      // joystick button down
      else if( msg.isButtonDown() )
      {
          ( foot_switch + 1 ) % d.size() => foot_switch;   
      }

      
      // gametrak left horrizontal will handle tempo
      // Read the Gametrak axis value (0 to 1)
      gt.axis[2] => float left_pull;
      
      // Map the left_pull value to the tempo range
      Std.ftoi( left_pull * 1.5 * (MAX_TEMPO - MIN_TEMPO) + MIN_TEMPO ) => int intpull;
      setPulse( intpull );
    }
  }
}

fun void setPulse(int bpm)
{
  60000 / bpm => pulse;
}

spork ~ droop();

while ( true )
  1::second => now;