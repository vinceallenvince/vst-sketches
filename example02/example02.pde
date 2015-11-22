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

PVector center;
float r;
float theta;

void setup() {
  // finding the right port requires picking it from the list
  // seems to change sometimes?
  String portName = Serial.list()[5]; 
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
  r = height * 0.45;
  theta = 0;
}

void draw() {
  background(255);
  
  // Translate the origin point to the center of the screen
  //translate(center.x, center.y);
  
  // Convert polar to cartesian
  float x0 = (r * cos(theta)) + center.x;
  float y0 = (r * sin(theta)) + center.y;
  
  x1 = center.x;
  y1 = center.y;
  
  line(x0, y0, x1, y1);
  
  theta += 0.02;
  
  add_point(1, x1, x1);
  add_point(2, height - y0, width - x0);
  
  send_points();
  
  
}

void add_point(int bright, float xf, float yf)
{
  int x = (int)(xf * 2047 / xmax);
  int y = (int)(yf * 2047 / ymax);
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
