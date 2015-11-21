import processing.serial.*;

Serial myPort; 

final int segments = 1;
final int xmax = 512;
final int ymax = 512;

float x0;
float x1;
float y0;
float y1;

byte[] bytes = new byte[3+3*2*segments];
int byte_count = 0;

// first 2 brightness, next 11 X-coord, last 11 Y-coord;
// 3 x 8 bit bytes

Mover m;
PVector center;
PVector gravity;

void setup() {
  // finding the right port requires picking it from the list
  // seems to change sometimes?
  String portName = Serial.list()[0]; 
  for(String port : Serial.list())
  {
    println(port);
  }

  myPort = new Serial(this, portName, 9600); 
  size(xmax, ymax);
  
  stroke(0);
  strokeWeight(1);
  
  //
  
  center = new PVector(xmax / 2, ymax / 2);
  gravity = new PVector(0,0.1);
  m = new Mover(center); 
}

void draw() {
  background(255);
  
  m.applyForce(gravity);
  m.update();
  
  x0 = m.location.x;
  y0 = m.location.y;
  x1 = m.middle.x;
  y1 = m.middle.y;
  
  line(x0, y0, x1, y1);
  
  add_point(2, x0, y0);
  add_point(2, x1, y1);
  
  send_points();
  
  //
  
  m.checkEdges();
}

void add_point(int bright, float xf, float yf)
{
  int x = (int)(xf * 2048 / xmax);
  int y = (int)(yf * 2048 / ymax);
  int cmd = (bright & 3) << 22 | (x & 2047) << 11 | (y & 2047) << 0;
  bytes[byte_count++] = (byte)((cmd >> 16) & 0xFF);
  bytes[byte_count++] = (byte)((cmd >>  8) & 0xFF);
  bytes[byte_count++] = (byte)((cmd >>  0) & 0xFF);
}

void send_points()
{
  bytes[byte_count++] = 1;
  bytes[byte_count++] = 1;
  bytes[byte_count++] = 1;
  myPort.write(bytes);
  byte_count = 0;
}
