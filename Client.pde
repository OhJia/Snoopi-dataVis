class Client {
  String macAddr;
  int unixTime;
  int power;
  String router;
  String matchedVendor;

  // time stuff
  String time;
  int H, M, S;
  int hrDiff, minDiff, secDiff;
  String calTime;
  int timestamp;
  int secSinceLastSniffed; // seconds
  int minSinceLastSniffed;
  int hrSinceLastSniffed;
  String timeSinceLastSniffed;

  ArrayList<String> routers;
  int routerCount;
  float t; // generate random location on ellipse path
  float t2;
  float tSpeed;
  float tLimit;
  float tRand;
  float newPower;
  float newPower2;
  float pSpeed;
  float pLimit;
  PVector pos = new PVector();
  PVector goal = new PVector();
  float dotSize;

  boolean thisBroadcast = false; // check the new incoming router
  boolean broadcast = true; // check arraylist of routers

  Client(String macAddr_, int time_, int power_, String router_) {
    t = random(-180, 0);
    t2 = t;
    tLimit = random(2, 5);
    tSpeed = random(-0.05, 0.05);
    tRand = random(20, 40);
    pLimit = random(4, 8);
    pSpeed = random(-0.05, 0.05);
    macAddr = macAddr_;
    unixTime = time_;
    power = power_;
    router = router_;
    routerCount = 0;
    matchVendor();
    time = new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date (unixTime*1000L));
    secSinceLastSniffed = 0; // seconds
    minSinceLastSniffed = 0;
    hrSinceLastSniffed = 0;
    //calTime();
    //println(time);
  }

  void matchVendor() {
    String[] macNum = splitTokens(macAddr, ":");
    String[] macNum2 = {
      macNum[0].toUpperCase(), macNum[1].toUpperCase(), macNum[2].toUpperCase()
      };
      String mac = join(macNum2, ":"); 
    matchedVendor = vList.get(mac);
    //println(matchedVendor);
    if (matchedVendor == null) {
      matchedVendor = "Unknown";
      //println(matchedVendor + "unknown");
    }
    //println(matchedVendor);
  }

  // void calTime() {
  //   String[] t = splitTokens(time, ":");
  //   H = int(t[0]);
  //   M = int(t[1]);
  //   if (h > H) {
  //     hrDiff = h - H;
  //     if (hrDiff == 1) calTime = hrDiff + "hr ago";
  //     else calTime = hrDiff + "hrs ago";
  //   } else if (h == H && m > M) {
  //     minDiff = m - M;
  //     if (minDiff == 1) calTime = minDiff + "min ago";
  //     else calTime = minDiff + "mins ago";
  //   } else if (h == H && m == M) {
  //     secDiff = s - S;
  //     if (minDiff == 1) calTime = secDiff + "sec ago";
  //     else calTime = secDiff + "secs ago";
  //   } else {
  //     calTime = "over 24hrs ago...";
  //   }
  // }

  void calTime() {
    secSinceLastSniffed = (millis() - timestamp)/1000;
    minSinceLastSniffed = secSinceLastSniffed/60;
    hrSinceLastSniffed = minSinceLastSniffed/60;

    if (hrSinceLastSniffed == 0 && minSinceLastSniffed == 0) {
      if (secSinceLastSniffed > 1) {
        timeSinceLastSniffed = secSinceLastSniffed + " secs ago";
      } else {
        timeSinceLastSniffed = secSinceLastSniffed + " sec ago";
      }
    } else if (hrSinceLastSniffed == 0) {
       if (minSinceLastSniffed > 1) {
        timeSinceLastSniffed = minSinceLastSniffed + " mins ago";
      } else {
        timeSinceLastSniffed = minSinceLastSniffed + " min ago";
      }
    } else {
      if (hrSinceLastSniffed > 1) {
        timeSinceLastSniffed = hrSinceLastSniffed + " hrs ago";
      } else {
        timeSinceLastSniffed = hrSinceLastSniffed + " hr ago";
      }
    }

    println(timeSinceLastSniffed);
  }

  // create a new arraylist for routers
  void newRouter() {
    routers = new ArrayList<String>(); 
    if (!router.equals("BROADCAST")) {
      routers.add(router);
      routerCount++;
      routerData.increment(router);
    }
  }

  // add a router name to arraylist
  void addRouter(String router_) {
    if (!router_.equals("BROADCAST") && !routers.contains(router_)) {
      routers.add(router_);
      routerCount++;
      routerData.increment(router_);
    }
  }

  // update power and time variables for the client
  void update(int power_, int time_) {
    power = power_;
    unixTime = time_;
    timestamp = millis();
    time = new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date (unixTime*1000L));
  }

  void displayDot() {
    //secSinceLastSniffed = (millis() - timestamp)/1000;
    float newPower = map(power, 150, 230, unit * 4 -20, 115);
    pos.x = doggiePos.x + newPower * cos(radians(t));
    pos.y = doggiePos.y + newPower * sin(radians(t));

    for (String router : routers) {
      if (!router.equals("BROADCAST")) broadcast = false;
    }
    if (broadcast == true) {
      fill(200, 60);
      stroke(200, 60);
    } else {
      fill(200, 100 + routerCount * 10);
      stroke(200, 100 + routerCount * 10);
    }
    noStroke();
    ellipse(pos.x, pos.y, 10, 10);
    strokeWeight(1);
    line(doggiePos.x, doggiePos.y, pos.x - 5, pos.y - 5);
  }

  void moveDot() {
    // lerp() linear extrapolation
    //PVector lastPos = new PVector(pos.x, pos.y);
    //secSinceLastSniffed = (millis() - timestamp)/1000;
    PVector lastPos = new PVector();
    lastPos.x = pos.x;
    lastPos.y = pos.y;
    newPower = map(power, 150, 230, unit * 4 - 20, 90);
    newPower2 = newPower;
    goal.x = doggiePos.x + newPower * cos(radians(t));
    goal.y = doggiePos.y + newPower * sin(radians(t));
    strokeWeight(1);
    stroke(30);
    line(doggiePos.x, doggiePos.y+40, pos.x, pos.y);
    noStroke();
    for (String router : routers) {
      if (!router.equals("BROADCAST")) broadcast = false;
    }
    if (broadcast == true) {
      fill(100, 200);
      //stroke(100);
    } else {
      fill(250, 200);
      //stroke(250);
    }

    connectTheDots();

    if (selected()) {
      fill(220, 60, 65);
    }

    pos.x = lerp(lastPos.x, goal.x, 0.1);
    pos.y = lerp(lastPos.y, goal.y, 0.1);

    dotSize = 10 + routerCount*2;
    //noStroke();
    ellipse(pos.x, pos.y, dotSize, dotSize);
    floatDot();
  }

  void floatDot() {
    t += tSpeed;
    // newPower += pSpeed;
    if (abs(t - t2) > tLimit) {
      tSpeed = -tSpeed;
      newPower += pSpeed;
    } 
    if (abs(newPower - newPower2) > pLimit) {
      pSpeed = -pSpeed;
    }
    //
  }


  boolean selected() {
    if (dist(mouseX, mouseY, pos.x, pos.y) < 10) {
      return true;
    } else {
      return false;
    }
  }


  void displayInfo() {
    // draw GUI bg
    fill(100);
    rectMode(CORNER);
    noStroke();
    rect(unit * 8, 0, width, height - groundHeight);

    // draw black highlight
    fill(0);
    rectMode(CORNER);
    noStroke();
    rect(unit * 8 + 30, 50, unit*4-40, 30);
    rect(unit * 8 + 30, 85, unit*4-40, 30);

    // display info
    fill(255);
    if (matchedVendor != null) {
      textFont(din, 16);
      //textSize(16);
      fill(200);
      text("Device from: ", unit * 8 + 40, 105);
      fill(255);
      text(matchedVendor, unit * 8 + 40 + textWidth("Device from: ") + 3, 105);
    }
    calTime();
    textFont(din, 16);
    fill(200);
    text("Sniffed: ", unit * 8 + 40, 70);
    fill(255);
    //text(calTime, unit * 8 + 40 + textWidth("Sniffed: ") + 3, 70);
    //text(power, unit * 8 + 40, 120);
    text(timeSinceLastSniffed, unit * 8 + 40 + textWidth("Sniffed: ") + 3, 70);

    int y = 15;
    textFont(din, 14);   
    for (String router : routers) {

      if (!router.equals("BROADCAST")) {
        fill(255);
        text(router, unit * 8 + 50, 140 + y);
        fill(200);
        ellipseMode(CENTER);
        noStroke();
        if (router.equals(routers.get(0))) {
          ellipse(unit * 8 + 40, 140 + y - 5, 9, 9);
        } else {
          ellipse(unit * 8 + 40, 140 + y - 5, 9, 9);
          stroke(200);
          strokeWeight(2);
          line(unit * 8 + 40, 140 + y - 5, unit * 8 + 40, 140 + y - 20);
        }
        y += 18;
        //println(router);
      }
    }
  }

  void connectTheDots() {
    if (allKeys.size() > 1) {
      for (String s : allKeys) {
        ArrayList<String> r = new ArrayList<String>();
        r = hm.get(s).routers;
        if (!hm.get(s).macAddr.equals(macAddr)) {
          for (String i : r) {
            if (routers.contains(i)) {
              stroke(80, 200, 165, 100);
              strokeWeight(0.5);
              line(pos.x, pos.y, hm.get(s).pos.x, hm.get(s).pos.y);
              if (abs(t-hm.get(s).t) > tRand)
                t = lerp(t, hm.get(s).t, 0.01); // trying
              noFill();
              //curve(hm.get(s).pos.x-100, hm.get(s).pos.y-100, pos.x, pos.y, hm.get(s).pos.x, hm.get(s).pos.y, pos.x-150, pos.y-150);
              fill(80, 200, 165, 100);
              ellipse(pos.x, pos.y, dotSize, dotSize);
            }
            //floatDot();
          }
        }
        //floatDot();
      }
    }
  }
}
