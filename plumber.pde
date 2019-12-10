import java.util.*;
boolean dbg = false;
boolean paths = true;
boolean drawPaths = false;
World w;
ArrayList<Long> outs = new ArrayList();
Set<Path> pathSet = new HashSet(); 
void settings() {
  size(1200, 700);
  //noSmooth();
}
void setup() {
  //hint(DISABLE_TEXTURE_MIPMAPS);
  
  //String s = prepare("[] .. .. []\n.. .. .. ].\n.. [] [= ][\n][ == .. ..\n.. ][ [= ..");
  //String s = prepare(".. [] ..\n[] ][ []\n[. .. .[\n.. .. ..");
  
  
  
  //String s = prepare("[] .. [] .. []\n.↓ .. ↓[ .. ↓.\n][ [] ↓[ [] ][\n.. ↓. ↓[ .↓ ..\n=] [= == =] [=\n");
  //String s = prepare("[] [] []\n[= == =]\n");
  //String s = prepare("....[]......[]..........[]..[]\n............[][]..[][]..=][]..\n......[]=][]=][[=]][..........\n........[][===][..[][===[]....\n[][].....[........[]....][][..\n].[===[=][=]][.....]..........\n][[==[[=[=[=[=]=[]][=[[[][....\n......][[=[=[=[==[[=[=][..[[]]\n..[[]]......[]]=][=][]....[=].\n....][=]=]===]=]][[=[===[=[=][\n");
  //String s = prepare(".. .. [] .. .. .. [] .. .. .. .. [] .. [] ..\n.. .. .. .. .. .. [] [] .. [] [] =] [] .. ..\n.. .. .. [] =] [] =] [[ =] ][ .. [] ][ .. ..\n.. .. .. .. [] [= == ][ .. [] [= == [] .. ..\n[] [] .. .. .[ .. .. .. .. [] .. ][ ][ .. ..\n]. [= == [= ][ =] ][ .. .. .] .. .. .. .. ..\n][ [= =[ [= [= [= [= ]= [] ][ =[ [[ ][ .. ..\n.. .. .. ][ [= [= [= [= =[ [= [= ][ .. [[ ]]\n.. [[ ]] .. .. .. [] ]= ][ =] [] .. .. ]. ..\n.. .. ][ =] =] == =] =] ][ [= [= == [= ][ ..\n");
  //String s = prepare("[] [] .. .. []\n]. ]. [] [= ][\n]. .. .. .. ..\n][ == =] .. ..\n");
  //String s = prepare("[] .. [] .. .. []\n]. .. ]. [] [= ][\n]. .. .. .. .. ..\n][ =] == =] .. ..\n");
  //String s = prepare("[] .. [] .. .. .. []\n]. .. ]. [] [= [= ][\n]. .. .. .. .. .. ..\n][ =] == =] .. .. ..\n");
  String s = repeat(repeat("..", 15)+"\n", 200);
  //String s = prepare("....[]....[]....[]..........\n............................\n....==]=[]]===..]...........\n..[[]][]]=][[][[]]..........\n..][===]][[=[===][..........\n............................\n............................\n............................\n............................\n............................\n");
  
  Output o = new Output() { public void write(long l) { outs.add(l); } };
  //w = new World(s, new ArrayInput(new int[]{3,5}), o);
  w = new World(loadStrings("prog"), new ArrayInput(new int[]{}), o);
  //w = new World(prepare(join(loadStrings("work"), '\n')), new ArrayInput(new int[]{}), o);
  //w = new World(prepare("[] =[ []\n.[ [[ [=\n][ ][ .."), new StringInput("Hello"), o);
}
int ox, oy;
int sfr = -1000;
void draw() {
  background(30);
  float sc = 1;
  int sz = (int)(sc*60);
  int ew = (int)(33*sc);
  int eh = (int)(15*sc);
  
  
  pushMatrix();
  translate(ox, oy);
  
  textSize(15*sc);
  textAlign(CENTER, CENTER);
  int sx = (mouseX-ox)/sz;
  int sy = (mouseY-oy)/sz;
  strokeWeight(1);
  if (wr.length()==2 && mousePressed) {
    if (sx>=0 && sy>=0 && sx<w.w && sy<w.h) {
      w.set(sx, sy, wr);
      reset();
    }
  }
  rectMode(CENTER);
  for (Cell[] ln : w.c) for (Cell c : ln) {
    int rx = c.x*sz + sz/2;
    int ry = c.y*sz + sz/2;
    fill(c.x==sx && c.y==sy? #334433 : 33);
    stroke(25);
    rect(rx, ry, sz, sz);
    fill(210);
    text(c.s, rx, ry+eh);
  }
  
  
  
  if (drawPaths) {
    stroke(#994444);
    //strokeWeight(2);
    for (Path p : pathSet) {
      int rsx = p.sx*sz + sz/2;
      int rsy = p.sy*sz + sz/2;
      int rex = p.ex*sz + sz/2;
      int rey = p.ey*sz + sz/2;
      line(rsx, rsy, rex, rey);
      int mx = (rex-rsx)*8/10 + rsx;
      int my = (rey-rsy)*8/10 + rsy;
      int cx = (rex-rsx)*7/10 + rsx;
      int cy = (rey-rsy)*7/10 + rsy;
      int dx = rsx==rex? 4 : 0;
      int dy = rsx==rex? 0 : 4;
      line(mx, my, cx+dx, cy+dy);
      line(mx, my, cx-dx, cy-dy);
    }
    strokeWeight(1);
  }
  
  noStroke();
  float pc = constrain((frameCount-sfr)/10f, 0, 1)*sz;
  for (Packet p : w.ps) {
    int rx = p.x*sz + sz/2;
    int ry = p.y*sz + sz/2;
    if (!p.remove && p.reqMoves.size() == 0) {
      fill(p.remove? 0x77000000 : 0);
      rect(rx, ry, ew, eh);
      fill(210);
      text(""+p.v, rx, ry);
    }
    for (int i = 0; i < p.reqMoves.size(); i++) {
      int dir = p.reqMoves.get(i);
      int  sd = p.reqSDirs.get(i);
      long nv = p.reqVals.get(i);
      float crx = rx+dx[dir]*pc;
      float cry = ry+dy[dir]*pc;
      if (sd!=-1) crx+= sz*.2*(sd==1?1:-1);
      fill(0);
      rect(crx, cry, ew, eh);
      fill(210);
      text(""+nv, crx, cry);
    }
  }
  
  popMatrix();
  
  
  rectMode(CORNERS);
  textAlign(CENTER, CENTER);
  //textSize(20);
  fill(#333355);
  rect(0, 0, 40, 40);
  fill(210);
  text(w.ctr, 20, 20);
  textSize(15*sc);
  rectMode(CENTER);
  
  fill(210);
  int tx = sz*w.w+10;
  textAlign(LEFT,TOP);
  String b = "Output:\n";
  for (long l : outs) b+= l+(l>31&&l<128?" "+(char)l:"")+"\n";
  text(wr, tx, 0);
  text(b, tx, 30);
  
  
  
  
  int bsz = 40;
  int cx = tx+sz;
  String[] btns = {"..",".=","=.","].",    "==","[=","=]",".[",    "[]","]=","=[","[.",    "][","]]","[[",".]"};
  int bsx = (mouseX-cx)/bsz;
  int bsy =  mouseY    /bsz;
  if (bsx>=0 && bsy>=0 && bsx<4 && bsy<4 && mousePressed) {
    wr = btns[bsx + bsy*4];
  }
  textAlign(CENTER, CENTER);
  for (int y = 0; y < 4; y++) {
    for (int x = 0; x < 4; x++) {
      int rx = cx+x*bsz+bsz/2;
      int ry =    y*bsz+bsz/2;
      String str = btns[x+y*4];
      
      fill(x==bsx && y==bsy? #334433 : str.equals(wr)? #333344 : 33);
      stroke(25);
      rect(rx, ry, bsz, bsz);
      fill(210);
      text(str, rx, ry);
    }
  }
  if (auto && frameCount-sfr == 40) step();
  //if (frameCount%4==0)saveFrame("data/img"+(frameCount/4)+".png");
}
boolean auto;
void mouseWheel(MouseEvent e) {
  oy-= e.getCount()*100;
}

String wr = "";
void keyPressed() {
  if (key == '`') step();
  if (key == '1') sfr=frameCount+20;
  if (key == 'r') reset();
  switch(key) {
    case'[':case']':case'.':case' ':case'=':
      if (wr.length()==2) wr = "";
      wr+= key==' '?'.':key;
      break;
    case '+': wr = "]."; break;
    case '-': wr = "[."; break;
    case 'a': auto^=true;break;
    case 'e': wr = "]["; break;
    case 'd': wr = "[]"; break;
    case 'p': wr = "=]"; break;
    case 'c': wr = "=["; break;
    case 'x': wr = ".."; break;
    case 'o':
      String r = "", rs = "";
      for (Cell[] ln : w.c) {
        for (Cell c : ln) {
          r += c.s+" ";
          rs+= c.s;
        }
        r = r.substring(0,r.length()-1)+"\n";
        rs+="\\n";
      }
      println(r);
      println(rs);
      saveStrings("work", new String[]{r});
      break;
      
    case 9:
      drawPaths^= true;
      break;
    case 65535:
      if (keyCode==37) revif("=]", "=[", "[[");
      if (keyCode==39) revif("[=", "]=", "]]");
      break;
    //default:println(+key,keyCode);
  }
}
void revif(String... a) {
  for (String s : a) {
    if (s.equals(wr)) {
      wr = wr.charAt(1)+""+wr.charAt(0);
      wr = wr.replace("[","t").replace("]","[").replace("t","]");
    }
  }
}
void step() {
  try {
    w.step();
  } catch (PosError e) {
    println(e.getMessage());
  }
  sfr = frameCount;
}
void reset() {
  w.reset();
  pathSet.clear();
}
String prepare(String s) {
  return s.replace(" ", "").replaceAll("[^\\[\\]=\n]", ".");
}

class World {
  Cell[][] c;
  OOBCell oob;
  int w, h;
  Input i;
  Output o;
  int ctr = 0;
  World(String s, Input i, Output o) {
    this(s.split("\n"), i, o);
  }
  World(String[] lns, Input i, Output o) {
    this.i = i;
    this.o = o;
    w = 0;
    for (String s : lns) w = Math.max(s.length(), w);
    w = (w+1)/2; // ceildiv
    h = lns.length;
    c = new Cell[h][w];
    oob = new OOBCell(this);
    for (int y = 0; y < h; y++) {
      String ln = lns[y];
      ln = ln.replaceAll("[^\\[\\]=]", ".");
      for (int x = 0; x < w; x++) {
        if (ln.length() <= 2*x) set(x, y, "..");
        else if (ln.length() <= 2*x+1) set(x, y, ln.charAt(2*x)+".");
        else set(x, y, ln.charAt(2*x)+""+ln.charAt(2*x+1));
      }
    }
    reset();
  }
  void set(int x, int y, String s) {
    c[y][x] = newCell(this, x, y, s);
  }
  void reset() {
    ctr = 0;
    i.reset();
    ps = new ArrayList();
    for (Cell[] ln : c) for (Cell c : ln) c.curr.clear();
    outs.clear();
    for (int x = 0; x < w; x++) {
      if (c[0][x] instanceof VertCell) add(new Packet(this, x, 0, 2, -1, 0)); 
    }
  }
  Cell get(int x, int y) {
    if (x<0 | y<0 | x>=w | y>=h) return oob;
    return c[y][x];
  }
  
  ArrayList<Packet> ps;
  void add(Packet p) {
    if (p.x<0 | p.y<0 | p.x>=w | p.y>=h) return;
    ps.add(p);
    c[p.y][p.x].curr.add(p);
  }
  
  void step() {
    step2();
    step1();
  }
  void step1() {
    ctr++;
    for (Cell[] ln : c) for (Cell c : ln) c.step();
  }
  void step2() {
    ArrayList<Packet> tps = ps;
    ps = new ArrayList();
    for (Packet p : tps) c[p.y][p.x].curr.clear(); // clear out previous where there is any
    for (Packet p : tps) {
      p.step();
    }
  }
}

Cell newCell(World w, int x, int y, String s) {
  switch(s) {
    case "..": case "=.": case ".=":
      return new EmptyCell(w, x, y, s);
    case "[]": case "][":
      return new VertCell(w, x, y, s);
    case "[.": case "].": case ".[": case ".]":
      return new ModfCell(w, x, y, s);
    case "==":
      return new StorCell(w, x, y, s);
    case "=]": case "[=":
      return new PushCell(w, x, y, s);
    case "=[": case "]=":
      return new CondCell(w, x, y, s);
    case "[[": case "]]":
      return new BrchCell(w, x, y, s);
    default: throw new Error("unknown cell type '"+s+"'");
  }
}


class PosError extends RuntimeException {
  PosError(String msg, Cell c) {
    super(msg+" ("+c.x+";"+c.y+")");
  }
}

class Path {
  int sx, sy, ex, ey;
  Path(int sx, int sy, int ex, int ey) {
    this.sx = sx;
    this.sy = sy;
    this.ex = ex;
    this.ey = ey;
  }
  int hashCode() {
    return sx + sy*7 + ex*31 + ey*211;
  }
  boolean equals(Object o) {
    Path p = (Path) o;
    return sx==p.sx && p.sy==sy && p.ex==ex && p.ey==ey;
  }
}

String repeat(String s, int n) {
  StringBuilder b = new StringBuilder(s.length()*n);
  for (int i = 0; i < n; i++) b.append(s);
  return b+"";
}
