// SOUNDCRAFT dendrop

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
500 => int pulse;
// Attribute for gain, LPF, 
float attributes[2];
1 => int MAX_DROP_GAIN;
0 => int MIN_DROP_GAIN;
1 => int MAX_RAIN_GAIN;
0 => int MIN_RAIN_GAIN;

OscOut xmit;
xmit.dest( hostname, port );

fun void sendCommand( int receiver, int attribute, float value )
{
  <<< "Sending /soundcraft ", receiver, attribute, value >>>;
  xmit.start( "/soundcraft" );
  receiver => xmit.add;
  attribute => xmit.add;
  value => xmit.add;
  xmit.send();
}

fun void commandLoop()
{
  while ( true )
  {
    for ( int i; i < attributes.size(); i++ )
    {
      sendCommand( 0, i, attributes[i]);
    }

    pulse::ms => now;
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
            Math.min(Math.max(attributes[0] + 0.1, MIN_DROP_GAIN), MAX_DROP_GAIN) => attributes[0];
          }
          else if ( msg.which == 44 )
          {
            Math.min(Math.max(attributes[0] - 0.1, MIN_DROP_GAIN), MAX_DROP_GAIN) => attributes[0];
          }
          else if ( msg.which == 82 )
          {
            Math.min(Math.max(attributes[1] + 0.1, MIN_RAIN_GAIN), MAX_RAIN_GAIN) => attributes[1];
          }
          else if ( msg.which == 81 )
          {
            Math.min(Math.max(attributes[1] - 0.1, MIN_DROP_GAIN), MAX_DROP_GAIN) => attributes[1];
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
    trak => now;
    
    while( trak.recv( msg ) )
    {
      if( msg.isAxisMotion() )
      {            
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
      
      // gametrak left horrizontal will handle drop gain
      gt.axis[2] => float left_pull;
      
      // Map the left_pull value to the gain range
      Std.ftoi( left_pull * 1.5 * (MAX_DROP_GAIN - MIN_DROP_GAIN) + MIN_DROP_GAIN ) => attributes[0];

      // gametrak right horizontal will handle rain gain
      gt.axis[5] => float right_pull;
      Std.ftoi( left_pull * 1.5 * (MAX_DROP_GAIN - MIN_DROP_GAIN) + MIN_DROP_GAIN ) => attributes[1];
    }
  }
}

spork ~ commandLoop();

while ( true )
  1::second => now;