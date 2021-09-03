class Box {
  float x, y, w, h;
  String txt;
  Box(float _x, float _y, float _w, float _h) {
    this.x = _x;
    this.y = _y;
    this.w = _w;
    this.h = _h;
    this.txt = "";
  }
  void show() {
    stroke(255);
    fill(0, 222);
    rect(this.x, this.y, this.w, this.h, 10);
    fill(255);
    text(this.txt, this.x+10, this.y+10);
  }
}
