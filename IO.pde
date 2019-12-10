abstract class Input {
  abstract long read();
  abstract void reset();
}

class StringInput extends Input {
  String s;
  int i;
  StringInput(String s) {
    this.s = s;
  }
  long read() {
    if (i == s.length()) return -1;
    return s.charAt(i++);
  }
  void reset() { i = 0; }
}

class ArrayInput extends Input {
  int[] a;
  int i;
  ArrayInput(int[] a) {
    this.a = a;
  }
  long read() {
    if (i == a.length) return -1;
    return a[i++];
  }
  void reset() { i = 0; }
}

class StdinInput extends Input {
  Scanner s;
  StdinInput() {
    s = new Scanner(System.in);
  }
  long read() {
    return s.nextLong();
  }
  void reset() { }
}

abstract class Output {
  abstract void write(long l);
}

class StdoutNOut extends Output {
  void write(long l) {
    print(l);
    print(' ');
  }
}
class StdoutCOut extends Output {
  void write(long l) {
    print((char) l);
  }
}
