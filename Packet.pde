/*
dir:
 0 - up
 1 - right
 2 - down
 3 - left
 4 - stored
*/
final int[] dx = { 0, 1, 0, -1, 0};
final int[] dy = {-1, 0, 1,  0, 0};
class Packet {
  final ArrayList<Integer> reqMoves = new ArrayList();
  final ArrayList<Long   > reqVals  = new ArrayList();
  final ArrayList<Integer> reqSDirs = new ArrayList();
  boolean remove;
  final World w;
  final int x, y;
  int d; // not final for overriding with 4
  final int sd; // stored dir
  final long v;
  Packet(World w, int x, int y, int d, int sd, long v) {
    this.w = w;
    this.x = x;
    this.y = y;
    this.d = d;
    this.v = v;
    this.sd = sd;
  }
  void move(int nd) {
    if (dbg) println("("+x+";"+y+"="+v+") moves "+dn(nd));
    if (paths) addPath(nd);
    reqMoves.add(nd);
    reqVals .add(v );
    reqSDirs.add(sd);
  }
  void moveS(int nd, int nsd) {
    if (dbg) println("("+x+";"+y+"="+v+") moves "+dn(nd)+" storing "+nsd);
    if (paths) addPath(nd);
    reqMoves.add( nd);
    reqVals .add( v );
    reqSDirs.add(nsd);
  }
  void move(int nd, long nv) {
    if (dbg) println("("+x+";"+y+"="+v+") moves "+dn(nd)+" as "+nv);
    if (paths) addPath(nd);
    reqMoves.add(nd);
    reqVals .add(nv);
    reqSDirs.add(sd);
  }
  void addPath(int nd) {
    pathSet.add(new Path(x, y, x+dx[nd], y+dy[nd]));
  }
  void remove() {
    remove = true;
  }
  void stay() {
    d = 4;
  }
  void step() {
    if (reqMoves.size() > 0) {
      for (int i = 0; i < reqMoves.size(); i++) {
        int nd = reqMoves.get(i);
        w.add(new Packet(w, x+dx[nd], y+dy[nd], nd, reqSDirs.get(i), reqVals.get(i)));
      }
    } else if (!remove) {
      w.add(this);
    }
  }
}



String dn(int d) {
  switch(d) {
    case 0: return "up";
    case 1: return "right";
    case 2: return "down";
    case 3: return "left";
    case 4: return "nowhere";
    default: new Error().printStackTrace(); throw new IllegalStateException("bad dir "+d);
  }
}
