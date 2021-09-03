class Country {
  String name;
  float lat, lon;
  int[] con, dea, rec;
  int total_confirmed, total_death, total_recovered;
  boolean persistent;

  int[][] all_total;

  Country(String n, float la, float lo, int c[], int d[], int r[]) {
    this.name = n;
    this.lat = la;
    this.lon = lo;
    this.con = c;
    this.dea = d;
    this.rec = r;
    this.persistent = false;
    total(c.length-1, c.length-1);
  }
  void total(int ini, int fin) {
    this.all_total = new int[3][ini-fin];
    for (int i = fin+1; i < ini+1; i++) {
      all_total[0][i-(fin+1)] = this.con[i];
      all_total[1][i-(fin+1)] = this.dea[i];
      all_total[2][i-(fin+1)] = this.rec[i];
    }
    this.total_confirmed = 0;
    this.total_death = 0;
    this.total_recovered = 0;
    this.total_confirmed += this.con[ini];
    this.total_death += this.dea[ini];
    this.total_recovered += this.rec[ini];
    if (ini != fin) {
      this.total_confirmed -= this.con[fin];
      this.total_death -= this.dea[fin];
      this.total_recovered -= this.rec[fin];
    }
  }
  void show() {
    float x = c_xaxis+mercatorX(radians(lon)) - mercatorX(0);
    float y = c_yaxis+mercatorY(radians(lat)) - mercatorY(0);
    float r, angle_1, angle_2;
    int t = abs(total_confirmed)+abs(total_death)+abs(total_recovered);
    r = (min_con != max_con)? map(total_confirmed, min_con, max_con, 7.25*zoom, 72.5*zoom): 72.5*zoom;

    if (x+r > -width/2 && x-r < width/2 && y+r > -height/2 && y-r < height/2) {
      pushMatrix();
      translate(width/2, height/2);
      noStroke();
      fill(0, 0, 255, 100);
      angle_1 = 0;
      angle_2 = total_confirmed*2*PI/float(t);
      arc(x, y, r, r, angle_1, angle_2, PIE);

      fill(255, 0, 0, 100);
      angle_1 = abs(total_confirmed)*2*PI/float(t);
      angle_2 = (abs(total_confirmed)+abs(total_death))*2*PI/float(t);
      arc(x, y, r, r, angle_1, angle_2, PIE);

      fill(0, 255, 0, 100);
      angle_1 = (abs(total_confirmed)+abs(total_death))*2*PI/float(t);
      angle_2 = 2*PI;
      arc(x, y, r, r, angle_1, angle_2, PIE);
      popMatrix();
    }
  }
  void mousePos() {
    float d = 5;
    float x = c_xaxis+mercatorX(radians(lon)) - mercatorX(0);
    float y = c_yaxis+mercatorY(radians(lat)) - mercatorY(0);
    if (x+d*.5 > -width/2 && x-d*.5 < width/2 && y+d*.5 > -height/2 && y-d*.5 < height/2) {
      pushMatrix();
      translate(width/2, height/2);
      fill(255, 100);
      stroke(0, 100);
      ellipse(x, y, d/2, d/2);
      if ((mouseX-width/2) < x+d && (mouseX-width/2) > x-d && (mouseY-height/2) < y+d && (mouseY-height/2) > y-d) {
        int total = total_confirmed+total_death+total_recovered;
        float per_con = float(String.format(java.util.Locale.US, "%.3f", 100.0*total_confirmed/float(total)));
        float per_dea = float(String.format(java.util.Locale.US, "%.3f", 100.0*total_death/float(total)));
        float per_rec = float(String.format(java.util.Locale.US, "%.3f", 100.0 - (per_con + per_dea)));
        String text = "";
        text += (this.persistent)? "✓ ": "";
        text += name+"\nC: "+total_confirmed+" ("+per_con+"%)"+"\nD: "+total_death+" ("+per_dea+"%)"+"\nR: "+total_recovered+" ("+per_rec+"%)";
        noStroke();
        fill(0, 175);
        rect(x - textWidth(text), y, textWidth(text), 8*7.2);
        fill(255);
        textAlign(RIGHT, TOP);
        text(text, x, y);
      }
      popMatrix();
    }
  }
}
