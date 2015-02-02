import java.util.*; 

// data, hashmap stuff
BufferedReader reader;
String line;
HashMap<String, Client> hm = new HashMap<String, Client>();
ArrayList<String> allKeys = new ArrayList<String>();
boolean containsKey = false;
String thisKey;

// vendor data
StringDict vList;
Table table;
String macNum;
String vendor;

// for time stuff
int s;
int m;
int h;

// static stuff
float unit; // width/12
PVector doggiePos = new PVector(); // position of doggie
float groundHeight = 120;
PShape dog; 
PShape dogHouse;
float l;
float t;
PFont din;
PFont din2;

//int i = 0;

// main data vis area stuff
boolean clicked = false;

// accumulated data stuff
IntDict routerData;
//ArrayList<RouterData> rData = new ArrayList<RouterData>();
float rDataX, rDataY;
ArrayList<String> keys = new ArrayList<String>();
int i;

void setup() {

  size(displayWidth, displayHeight);
  thread("loadVendors");
  reader = createReader("NSHeyy_pi/itp_show_5.csv");

  unit = displayWidth/12;
  // center point of doggie
  doggiePos.x = unit * 4;
  doggiePos.y = height - (groundHeight + 110);
  dog = loadShape("dog.svg");
  dog.scale(0.85);

  thisKey = " ";

  routerData = new IntDict();
  rDataX = unit * 8 + 10;
  rDataY = groundHeight + unit * 4 + 10;
  i = 0;
  l = 5;
  t = 0;
  
  din = loadFont("NewsGothicMT-Bold-48.vlw");
    //din = loadFont("PTSans-Regular-48.vlw");
  din2 = loadFont("Seravek-Bold-48.vlw");
  //din = createFont("PTMono-Bold-48.vlw", 32);

  smooth();
}

void draw() {
  s = second();  // Values from 0 - 59
  m = minute();  // Values from 0 - 59
  h = hour();    // Values from 0 - 23

  background(0);
  drawBg();

  try {
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  //println(line);
  if (line == null) {
    //noLoop();
  } else {
    String[] pieces = split(line, ",");

    if (pieces.length > 1) {
      String macAddr = pieces[6];
      String packetType = pieces[5];
      int dataTime = int(pieces[0]);
      int power = int(pieces[2]);
      //int power = (int)random(150, 230);
      String router = pieces[7];

      if (packetType.equals("Probe")) {

        if (hm.containsKey(macAddr)) {  
          hm.get(macAddr).addRouter(router);
          hm.get(macAddr).update(power, dataTime);
          containsKey = true;
        } else {
          Client client = new Client(macAddr, dataTime, power, router);
          client.newRouter();
          hm.put(macAddr, client);
          allKeys.add(macAddr);
          containsKey = false;
          hm.get(macAddr).update(power, dataTime);
        }
      }
    }
  }

  // draw main data vis
  if (allKeys.size() > 0) {
    displayAll();
  }

  clickToDisplayInfo();
  drawStatic();

  //println(routerData);
  displayOverview();
}

void showHashMap() {  
  for (String s : allKeys) {
    //println(s, hm.get(s).routers);
  }
}

void displayAll() {
  for (String s : allKeys) {
    if (containsKey = false) {
      hm.get(s).displayDot();
    } else {
      hm.get(s).moveDot();
    }
  }
}

void mouseReleased() {
  clicked = true;
}

void clickToDisplayInfo() {
  if (clicked) {
    for (String s : allKeys) {
      if (hm.get(s).selected()) {
        thisKey = s;
      }
    }
  } 
  clicked = false;
  if (thisKey != " ") {
    hm.get(thisKey).displayInfo();
    // make the selected dot pink
    stroke(255);
    strokeWeight(1);
    fill(220, 60, 65); 
    ellipse(hm.get(thisKey).pos.x, hm.get(thisKey).pos.y, hm.get(thisKey).dotSize, hm.get(thisKey).dotSize);
  }
}
void drawBg() {
  // draw bg
  fill(20);
  noStroke();
  ellipseMode(CENTER);
  ellipse(doggiePos.x, doggiePos.y +40, unit*8.5, unit*8.5);
  strokeWeight(15);
  stroke(30);
  fill(25);

  ellipse(doggiePos.x, doggiePos.y+40, unit*2, unit*2);
  noFill();
  ellipse(doggiePos.x, doggiePos.y+40, unit*4, unit*4);
  ellipse(doggiePos.x, doggiePos.y+40, unit*6, unit*6);
  
  // draw measure
  noStroke();
  fill(100);
  for (int i = 0; i < doggiePos.x; i += 5){
    rect(i, doggiePos.y+80, 3, 1.5);
  }
  textSize(10.5);
  fill(180);
  text("20ft", unit*3, doggiePos.y+98);
  text("50ft", unit*2, doggiePos.y+98);
  text("est. 80ft", unit*1-10, doggiePos.y+98);

  // draw right column  
  rectMode(CORNER);
  fill(100);
  noStroke();
  rect(unit*8, 0, unit*6, height - groundHeight);
}
void drawStatic() {
  
  // draw header
  fill(255);
  textFont(din2, 36);
  //textSize(24);
  text("Snoopi", unit-30, 80);
  textFont(din, 20);
  fill(200);
  text("The data sniffing dog", unit + textWidth("Snoopi") + 30, 80);

  // draw ground
  rectMode(CORNER);
  noStroke();
  fill(50);
  rect(0, displayHeight-groundHeight, displayWidth, groundHeight);

  // draw dog
  rectMode(CENTER);
  //rect(doggiePos.x, doggiePos.y, unit * 2 - 40, unit - 20);
  shapeMode(CENTER);
  shape(dog, doggiePos.x-110, doggiePos.y);
  // draw blinky light
  fill(255, 0, 0);
  noStroke();
  ellipseMode(CENTER);
  ellipse(doggiePos.x, doggiePos.y+40, l, l);
  if (l >= 0) l--;
  if (l <= 0){
    if (millis() - t >= 900){
    l = 6;
    t = millis();
    }
  }
  fill(80, 200, 165);
  rect(doggiePos.x-10, doggiePos.y+40, 10, 5);


  // draw dog house shape
  beginShape();
  fill(0);
  noStroke();
  vertex(unit * 8, groundHeight + unit * 3.5);
  vertex(unit * 8+35, groundHeight + unit * 3.5-45);
  vertex(width-55, groundHeight + unit * 3.5-45);
  vertex(width-20, groundHeight + unit * 3.5);
  vertex(width-20, height - groundHeight + 25);
  vertex(unit * 8 + 70, height - groundHeight + 35);
  vertex(unit * 8, height - groundHeight);  
  //dogHouse.vertex(90, 75);
  endShape(CLOSE);

  // draw dog house roof
  beginShape();
  fill(30);
  noStroke();
  vertex(unit * 8 -15, groundHeight + unit * 3.5);
  vertex(unit * 8, groundHeight + unit * 3.5);
  vertex(unit * 8+36, groundHeight + unit * 3.5-45);
  vertex(unit * 8+65, groundHeight + unit * 3.5);
  vertex(width-15, groundHeight + unit * 3.5);
  vertex(width-55, groundHeight + unit * 3.5-60);
  vertex(unit * 8+25, groundHeight + unit * 3.5-60);
  endShape(CLOSE);

  // draw dog house door
  fill(30);
  noStroke();
  //ellipseMode(CORNER);
  ellipse(unit*8+25, height - groundHeight - 110, 20, 20);
  beginShape();
  vertex(unit*8+15, height - groundHeight + 8);
  vertex(unit*8+15, height - groundHeight - 110);
  vertex(unit*8+35, height - groundHeight - 110);
  vertex(unit*8+35, height - groundHeight + 19);
  endShape();
}

void loadVendors() {
  vList = new StringDict();
  table = loadTable("vendors.csv");

  for (int i = 0; i < table.getRowCount (); i++) {
    TableRow row = table.getRow(i);
    macNum = trim(row.getString(0));
    vendor = row.getString(1);
    vList.set(macNum, vendor);
    //println(macNum + ": " + vList.get(macNum));
  }
}


void displayOverview() {
  String[] kks = routerData.keyArray();
  if (kks.length > i ) {
    keys.add(kks[i]);
    i++;
  }
  rDataX = unit * 8 + 80;
  rDataY = groundHeight + unit * 4 - 10;
  //float w = unit * 8 + 10;

  for (String k : keys) {
    int count = routerData.get(k);
    textFont(din, 12 + count * 2);
    //textSize(12 + count * 2);
    if (rDataX + textWidth(k) >= width - 60) { 
      rDataX = unit * 8 + 80;
      rDataY = rDataY + 20;
    }

    if (count > 1) fill(80, 200, 165);
    else fill(150);
    text(k, rDataX, rDataY);
    rDataX += textWidth(k) + 15;
  }
  if (keys.size() > 20) {
    //keys.remove(0);
    for(int i = 0; i < keys.size(); i++){
       if(routerData.get(keys.get(i)) == 1){
          keys.remove(i);
          break;
       }
    }
  }
}
