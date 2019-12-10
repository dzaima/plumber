abstract class Cell {
  World w;
  int x, y;
  String s;
  ArrayList<Packet> curr;
  Cell(World w, int x, int y, String s) {
    this.w = w;
    this.x = x;
    this.y = y;
    this.s = s;
    curr = new ArrayList();
  }
  abstract void step();
}

class OOBCell extends Cell {
  OOBCell(World w) {
    super(w, -1, -1, "..");
  }
  void step() { throw new IllegalStateException(); }
}

class EmptyCell extends Cell {
  EmptyCell(World w, int x, int y, String s) {
    super(w, x, y, s);
  }
  void step() {
    //if (curr.size() > 1) throw new PosError(">1 packet in cell ",this);
    //if (curr.size() == 0) return;
    //Packet p = curr.get(0);
    for (Packet p : curr) {
      if (p.d==0 | p.d==2) p.move(p.d);
      if (p.d==1 | p.d==3) p.remove(); // deviates from specification
    }
  }
}
class VertCell extends Cell {
  int d, rd;
  VertCell(World w, int x, int y, String s) {
    super(w, x, y, s);
    d = s.charAt(0)==']'? 0 : 2;
    rd = 2-d;
  }
  void step() {
    if (curr.size() == 1) {
      Packet p = curr.get(0);
      if (p.d == rd) { // incoming splits
        p.move(1);
        p.move(3);
      } else { // else, move away
        p.move(d);
      }
    } else if (curr.size()==2) {
      //Packet p0 = curr.get(0);
      //Packet p1 = curr.get(1);
      //if (p0.d==rd  &&  p1.d==rd  &&  p0.sd+p1.sd == 4) {
      //  p0.moveS(p0.sd, -1);
      //  p1.moveS(p1.sd, -1);
      //} else if (p0.d+p1.d == 4 && (p0.d&1)==1 && p0.sd+p1.sd==-2) {
      //  p0.moveS(d, 4-p0.d);
      //  p1.moveS(d, 4-p1.d);
      //} else if (p0.d==d && p1.d==d) {
      //  p0.move(d);
      //  p1.move(d);
      //} else throw new PosError("incoming from "+dn(p0.d)+" and "+dn(p1.d)+" can't be combined at ",this);
      
      Packet li=null, ri=null;
      ArrayList<Packet> in = new ArrayList();
      ArrayList<Packet> out = new ArrayList();
      for (Packet p : curr) {
        if (p.d ==  1) { if (li!=null) throw new PosError("multiple packets from the left at " , this); li=p; }
        if (p.d ==  3) { if (ri!=null) throw new PosError("multiple packets from the right at ", this); ri=p; }
        if (p.d ==  d) {  in.add(p); }
        if (p.d == rd) { out.add(p); }
      }
      boolean dUsed = (li!=null) ^ (ri!=null);
      if (li!=null && ri!=null) {
        li.moveS(d, 4-li.d);
        ri.moveS(d, 4-ri.d);
      } else {
        if (li!=null) li.move(d);
        if (ri!=null) ri.move(d);
      }
      if (in.size()==1 && dUsed) throw new PosError("packets coming from "+dn(d)+" and "+(li==null?"left":"right")+" at ", this);
      for (Packet p : in) {
        p.move(d);
      }
      if (out.size()==1) {
        Packet p = out.get(0);
        p.move(1);
        p.move(3);
      } else {
        for (Packet p : out) {
          p.moveS(p.sd, -1);
        }
      }
      
    } else if (curr.size()!=0) throw new PosError(">2 packets incoming to "+s+" at ",this);
  }
}
class ModfCell extends Cell {
  int dv;
  ModfCell(World w, int x, int y, String s) {
    super(w, x, y, s);
    dv = s.charAt(0)=='[' || s.charAt(1)==']'? -1 : 1;
  }
  void step() {
    if (curr.size() == 1) {
      Packet p = curr.get(0);
      if (p.d == 0) { // up remains up
        p.move(0  , p.v+dv);
      } else { // else, drop
        p.move(2, p.v+dv);
      }
    } else if (curr.size() != 0) throw new PosError(">1 packet in cell ",this);
  }
}
class StorCell extends Cell {
  StorCell(World w, int x, int y, String s) {
    super(w, x, y, s);
  }
  void step() {
    boolean newPacket = false;
    for (Packet p : curr) {
      if (p.d==1 || p.d==3) { 
        if (newPacket) throw new PosError(">1 new packet in storage cell ",this);
        else newPacket = true;
      } else if (p.d==0 || p.d==2) p.move(p.d);
    }
    if (newPacket) {
      for (Packet p : curr) {
        if (p.d == 4) p.remove();
        else if (p.d==1 || p.d==3) p.stay();
      }
    }
  }
}
class PushCell extends Cell {
  final int ed, bd; // to-equals-sign-dir, to-bracket-dir (dir is the one facing it, i.e. packet with bd dir outputs)
  final int ox; // storage x
  PushCell(World w, int x, int y, String s) {
    super(w, x, y, s);
    char c0 = s.charAt(0);
    ed = c0=='='? 1 : 3;
    bd = c0=='['? 1 : 3;
    ox = c0=='='? x-1 : x+1;
  }
  void step() {
    if (curr.size() == 1) {
      Packet p = curr.get(0);
      if (p.d == 2) { // input
        ArrayList<Packet> pull = w.get(ox, y).curr;
        long nv;
        //println(w.get(ox,y).x,w.get(ox,y).y);
        if (pull.size() == 0) {
          nv = w.i.read();
        } else {
          Packet tp = null;
          for (Packet pp : pull) {
            if (pp.d==1 || pp.d==3) {
              if (tp != null) throw new PosError("pulling >1 items at ",this);
              tp = pp;
            }
          }
          if (tp == null) {
            for (Packet pp : pull) {
              if (pp.d == 4) {
                if (tp != null) throw new PosError("pulling >1 items at ",this);
                tp = pp;
              }
            }
            tp = pull.get(0);
          }
          tp.remove();
          nv = tp.v;
        }
        p.move(ed, nv);
      } else if (p.d == bd) { // output
        w.o.write(p.v);
        p.remove();
      } else { // pusher pushes, or doesn't touch elevating
        p.move(p.d);
      }
    } else if (curr.size() != 0) throw new PosError(">1 packet in cell ",this);
  }
}
class CondCell extends Cell {
  final int ed; // to-equals-sign-dir
  CondCell(World w, int x, int y, String s) {
    super(w, x, y, s);
    ed = s.charAt(0)=='='? 1 : 3;
  }
  void step() {
    //if (curr.size() == 1) {
    //  Packet p = curr.get(0);
    for (Packet p : curr) {
      if (p.d==ed && p.v==0) p.remove();
      else p.move(p.d); // everything keeps moving the way it was
    }
    //} else if (curr.size() != 0) throw new PosError(">1 packet in cell ",this);
  }
}
class BrchCell extends Cell {
  final int nd; // new dir
  BrchCell(World w, int x, int y, String s) {
    super(w, x, y, s);
    nd = s.charAt(0)=='['? 1 : 3;
  }
  void step() {
    if (curr.size() == 1) {
      Packet p = curr.get(0);
      if (p.d==0) p.move(0);
      else {
        p.move(nd);
        p.move(2);
      }
    } else if (curr.size() != 0) throw new PosError(">1 packet in cell ",this);
  }
}
