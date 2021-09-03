import java.util.Collections;
import java.util.Comparator;

//https://www.youtube.com/watch?v=ZiYdOwOrGyc
//https://eoimages.gsfc.nasa.gov/images/imagerecords/74000/74493/world.topo.200411.3x5400x2700.jpg
//https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
static final String URL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/";
static final String CONFIRMED = URL + "time_series_covid19_confirmed_global.csv";
static final String DEATHS    = URL + "time_series_covid19_deaths_global.csv";
static final String RECOVERED = URL + "time_series_covid19_recovered_global.csv";

Table confirmed, deaths, recovered;
Country[] country;
PImage earth;
float h;
float zoom;
float c_xaxis, c_yaxis;
int max_con, min_con;
String date[];
int ini, fin;
boolean click, move;
int total_days;
boolean prom;
boolean[] show_data;

int save_cant, contries_names_s;
String find;
Box btn_show_date, btn_total_data, btn_show_find, btn_graf;
Box contries_names;

void setup() {
  save_cant = 0;
  contries_names_s = 0;
  find = "";
  btn_show_date = new Box(10, 10+0*(height-20)/7, 200, height/8);
  btn_total_data = new Box(10, 10+1*(height-20)/7, 200, height/8);
  btn_show_find = new Box(10, 10+2*(height-20)/7, 200, 36);
  btn_graf = new Box(10, 10+3*(height-20)/7 - 26, 200, height/8 + 36);

  contries_names = new Box(0, 0, 0, 0);

  size(1024, 512, P2D);
  earth = loadImage("earth.jpg");
  surface.setResizable(true);
  h = pow(2, 9);
  zoom = 1;
  c_xaxis = 0;
  c_yaxis = 0;
  data("data/offline/Confirmed.csv", "data/offline/Death.csv", "data/offline/Recovered.csv");
  ini = date.length-1;
  fin = date.length-1;
  click = false;
  move = true;
  show_data = new boolean[3];
  show_data[0] = true;
  show_data[1] = true;
  show_data[2] = true;
  max_con = -999999999;
  min_con = 999999999;
  for (Country c : country) {
    if (c.total_confirmed > max_con) max_con = c.total_confirmed;
    if (c.total_confirmed < min_con) min_con = c.total_confirmed;
  }
  total_days = 0;
  prom = false;
}
void draw() {
  background(0);
  image(earth, c_xaxis+width/2-(h*2)*zoom/2, c_yaxis+height/2-h*zoom/2, (h*2)*zoom, h*zoom);

  int total_con = 0;
  int total_dea = 0;
  int total_rec = 0;

  for (Country c : country) {
    if (c.name.toLowerCase().contains(find)  || c.persistent)
      c.show();
  }
  ArrayList<Country> total_data = new ArrayList<Country>();
  int total_contr = 0;
  for (Country c : country) {
    if (c.name.toLowerCase().contains(find)  || c.persistent) {
      total_con += c.total_confirmed;
      total_dea += c.total_death;
      total_rec += c.total_recovered;
      if (c.total_confirmed+c.total_death+c.total_recovered > 0) {
        c.mousePos();
        total_contr++;

        total_data.add(c);
      }
    }
  }
  Collections.sort(total_data, new SortData());
  if (total_con+total_dea+total_rec == 0 && find.length() > 0) {
    char t[] = find.toCharArray();
    find = "";
    for (int i = 0; i < t.length - 1; i++) {
      find += t[i];
    }
  }
  if (click) {
    if (mouseY > btn_show_date.y && mouseY < btn_show_date.y+btn_show_date.h/2) {
      ini += (mouseX-pmouseX)/2;
      //if (ini < fin) fin = ini;
      fin = ini - save_cant;
    } else if (mouseY < btn_show_date.y+btn_show_date.h) {
      fin -= (mouseX-pmouseX)/2;
      if (fin > ini) ini = fin;
    }
    ini = max(0, ini);
    ini = min(date.length-1, ini);
    fin = max(0, fin);
    fin = min(date.length-1, fin);
    for (Country c : country) {
      c.total(ini, fin);
    }
    max_con = -999999999;
    min_con = 999999999;
    for (Country c : country) {
      if (c.total_confirmed > max_con) max_con = c.total_confirmed;
      if (c.total_confirmed < min_con) min_con = c.total_confirmed;
    }
  }
  if (mouseButton == LEFT) {
    if (move) {
      c_xaxis += mouseX-pmouseX;
      c_yaxis += mouseY-pmouseY;
    }
  }

  int total = total_con+total_dea+total_rec;
  float per_con = float(String.format(java.util.Locale.US, "%.3f", 100.0*total_con/float(total)));
  float per_dea = float(String.format(java.util.Locale.US, "%.3f", 100.0*total_dea/float(total)));
  float per_rec = float(String.format(java.util.Locale.US, "%.3f", 100.0 - (per_con + per_dea)));
  if (ini-fin == 0) {
    btn_show_date.txt = date[ini]+" ("+nf(100*(ini+1)/float(date.length), 1, 2)+"%)\n\n"+"◄----►";
  } else {
    String d1 = nf(ini-fin, 4, 0);
    String d2 = "";
    boolean f = true;
    for (int i = 0; i < d1.length(); i++) {
      if (d1.charAt(i) == '0' && f)
        d2 += "-";
      else {
        d2 += d1.charAt(i)+"";
        f = false;
      }
    }
    btn_show_date.txt = date[fin]+"-"+date[ini]+" ("+nf(100*(ini+1)/float(date.length), 1, 2)+"%)\n\n◄"+d2+"►";
  }
  btn_total_data.txt = "";
  if (show_data[0])
    btn_total_data.txt += "✓ ";
  else
    btn_total_data.txt += "   ";
  btn_total_data.txt += "C: "+total_con+" ("+per_con+"%)\n";
  if (show_data[1])
    btn_total_data.txt += "✓ ";
  else
    btn_total_data.txt += "   ";
  btn_total_data.txt += "D: "+total_dea+" ("+per_dea+"%)\n";
  if (show_data[2])
    btn_total_data.txt += "✓ ";
  else
    btn_total_data.txt += "   ";
  btn_total_data.txt += "R: "+total_rec+" ("+per_rec+"%)";
  btn_show_find.txt = "("+total_contr+") "+find+"_";

  textAlign(LEFT, TOP);
  btn_show_date.show();
  line(btn_show_date.x, btn_show_date.y+btn_show_date.h/2, btn_show_date.x+btn_show_date.w, btn_show_date.y+btn_show_date.h/2);
  btn_total_data.show();
  btn_show_find.show();
  btn_graf.show();

  String prev_name = "";
  ArrayList<String> countries_name = new ArrayList<String>();
  int[] countries_confirmed;
  int[] countries_dead;
  int[] countries_recovered;
  if (total_data.size() > 0) {
    countries_confirmed = new int[total_data.get(0).con.length];
    countries_dead = new int[total_data.get(0).con.length];
    countries_recovered = new int[total_data.get(0).con.length];
  } else {
    countries_confirmed = new int[0];
    countries_dead = new int[0];
    countries_recovered = new int[0];
  }
  for (int i = 0; i < total_data.size(); i++) {
    if (!(total_data.get(i).name.equals(prev_name))) {
      countries_name.add(total_data.get(i).name);
      prev_name = total_data.get(i).name;
    }
    for (int j = 0; j < total_data.get(i).con.length; j++) {
      if (j >= ini-fin && j < ini) {
        countries_confirmed[j] += total_data.get(i).con[j];
        countries_dead[j] += total_data.get(i).dea[j];
        countries_recovered[j] += total_data.get(i).rec[j];
      }
    }
  }
  if (contries_names_s < 0) contries_names_s += countries_name.size();
  String txt = "";
  int n_lines = 0;
  for (int i = 0; i < min(countries_name.size(), height/(1.5*textAscent())); i++) {
    int j = (contries_names_s+i) % countries_name.size();
    if (j < 0) j += countries_name.size();
    txt += countries_name.get(j)+"\n";
    n_lines++;
    prev_name = countries_name.get(j);
  }
  contries_names.x = width-(textWidth(txt)+40);
  contries_names.y = 10;
  contries_names.w = textWidth(txt)+20;
  contries_names.h = min(n_lines*14+20, height-20);
  contries_names.txt = txt;
  contries_names.show();
  if (total_data.size() > 0) {
    float limit_top = Integer.MIN_VALUE;
    float limit_button = Integer.MAX_VALUE;
    for (int i = ini-1; i-(ini-fin+1) >= total_days; i -= ini-fin+1) {
      if (ini-fin == 0) {
        float temp_data = 0;
        if (show_data[0]) {
          temp_data += countries_confirmed[i];
        }
        if (show_data[1]) {
          temp_data += countries_dead[i];
        }
        if (show_data[2]) {
          temp_data += countries_recovered[i];
        }
        if (limit_top < temp_data) limit_top = temp_data;
        if (limit_button > temp_data) limit_button = temp_data;
      } else if (prom) {
        float n_prom = 0;
        for (int j = 0; j < ini-fin; j++) {
          float temp_data = 0;
          if (show_data[0]) {
            temp_data += countries_confirmed[i-j]-countries_confirmed[i-j-1];
          }
          if (show_data[1]) {
            temp_data += countries_dead[i-j]-countries_dead[i-j-1];
          }
          if (show_data[2]) {
            temp_data += countries_recovered[i-j]-countries_recovered[i-j-1];
          }
          n_prom += temp_data;
        }
        n_prom /= float(ini-fin);
        if (limit_top < n_prom) limit_top = n_prom;
        if (limit_button > n_prom) limit_button = n_prom;
      } else {
        float temp_data = 0;
        if (show_data[0]) {
          temp_data += countries_confirmed[i]-countries_confirmed[i-(ini-fin+1)];
        }
        if (show_data[1]) {
          temp_data += countries_dead[i]-countries_dead[i-(ini-fin+1)];
        }
        if (show_data[2]) {
          temp_data += countries_recovered[i]-countries_recovered[i-(ini-fin+1)];
        }
        if (limit_top < temp_data) limit_top = temp_data;
        if (limit_button > temp_data) limit_button = temp_data;
      }
    }
    limit_button = max(0, limit_button);
    if (limit_top != limit_button) {
      noStroke();
      fill(0, 255, 0);
      if (show_data[2]) {
        beginShape();
        vertex(btn_graf.x+btn_graf.w-10, map(0, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10));
        for (int j = ini-1; j-(ini-fin+1) >= total_days; j -= ini-fin+1) {
          float x1, y1, temp_data;
          x1 = map(j, total_days, ini-1, btn_graf.x+10, btn_graf.x+btn_graf.w-10);
          if (ini-fin == 0) {
            temp_data = 0;
            if (show_data[0]) {
              temp_data += countries_confirmed[j];
            }
            if (show_data[1]) {
              temp_data += countries_dead[j];
            }
            if (show_data[2]) {
              temp_data += countries_recovered[j];
            }
            y1 = map(temp_data, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          } else if (prom) {
            float n_prom = 0;
            for (int i = 0; i < ini-fin; i++) {
              temp_data = 0;
              if (show_data[0]) {
                temp_data += countries_confirmed[j-i]-countries_confirmed[j-i-1];
              }
              if (show_data[1]) {
                temp_data += countries_dead[j-i]-countries_dead[j-i-1];
              }
              if (show_data[2]) {
                temp_data += countries_recovered[j-i]-countries_recovered[j-i-1];
              }
              n_prom += temp_data;
            }
            y1 = map(n_prom/float(ini-fin), limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          } else {
            temp_data = 0;
            if (show_data[0]) {
              temp_data += countries_confirmed[j]-countries_confirmed[j-(ini-fin+1)];
            }
            if (show_data[1]) {
              temp_data += countries_dead[j]-countries_dead[j-(ini-fin+1)];
            }
            if (show_data[2]) {
              temp_data += countries_recovered[j]-countries_recovered[j-(ini-fin+1)];
            }
            y1 = map(temp_data, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          }
          vertex(x1, y1);
        }
        vertex(btn_graf.x+10, map(0, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10));
        endShape();
      }
      fill(0, 0, 255);
      if (show_data[0]) {
        beginShape();
        vertex(btn_graf.x+btn_graf.w-10, map(0, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10));
        for (int j = ini-1; j-(ini-fin+1) >= total_days; j -= ini-fin+1) {
          float x1, y1, temp_data;
          x1 = map(j, total_days, ini-1, btn_graf.x+10, btn_graf.x+btn_graf.w-10);
          if (ini-fin == 0) {
            temp_data = 0;
            if (show_data[0]) {
              temp_data += countries_confirmed[j];
            }
            if (show_data[1]) {
              temp_data += countries_dead[j];
            }
            y1 = map(temp_data, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          } else if (prom) {
            float n_prom = 0;
            for (int i = 0; i < ini-fin; i++) {
              temp_data = 0;
              if (show_data[0]) {
                temp_data += countries_confirmed[j-i]-countries_confirmed[j-i-1];
              }
              if (show_data[1]) {
                temp_data += countries_dead[j-i]-countries_dead[j-i-1];
              }
              n_prom += temp_data;
            }
            y1 = map(n_prom/float(ini-fin), limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          } else {
            temp_data = 0;
            if (show_data[0]) {
              temp_data += countries_confirmed[j]-countries_confirmed[j-(ini-fin+1)];
            }
            if (show_data[1]) {
              temp_data += countries_dead[j]-countries_dead[j-(ini-fin+1)];
            }
            y1 = map(temp_data, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          }
          vertex(x1, y1);
        }
        vertex(btn_graf.x+10, map(0, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10));
        endShape();
      }
      fill(255, 0, 0);
      if (show_data[1]) {
        beginShape();
        vertex(btn_graf.x+btn_graf.w-10, map(0, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10));
        for (int j = ini-1; j-(ini-fin+1) >= total_days; j -= ini-fin+1) {
          float x1, y1, temp_data;
          x1 = map(j, total_days, ini-1, btn_graf.x+10, btn_graf.x+btn_graf.w-10);
          if (ini-fin == 0) {
            temp_data = 0;
            if (show_data[1]) {
              temp_data += countries_dead[j];
            }
            y1 = map(temp_data, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          } else if (prom) {
            float n_prom = 0;
            for (int i = 0; i < ini-fin; i++) {
              temp_data = 0;
              if (show_data[1]) {
                temp_data += countries_dead[j-i]-countries_dead[j-i-1];
              }
              n_prom += temp_data;
            }
            y1 = map(n_prom/float(ini-fin), limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          } else {
            temp_data = 0;
            if (show_data[1]) {
              temp_data += countries_dead[j]-countries_dead[j-(ini-fin+1)];
            }
            y1 = map(temp_data, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10);
          }
          vertex(x1, y1);
        }
        vertex(btn_graf.x+10, map(0, limit_button, limit_top, btn_graf.y+btn_graf.h-10, btn_graf.y+10));
        endShape();
      }
      if (ini-fin == 0)
        btn_graf.txt = (ini+1-total_days)+" days";
      else if (prom)
        if (ini-fin == 1)
          btn_graf.txt = "Average of each day of "+(ini+1-total_days);
        else
          btn_graf.txt = "Average of every "+(ini-fin)+" days of "+(ini+1-total_days);
      else
        if (ini-fin == 1)
          btn_graf.txt = "Every day of "+(ini+1-total_days);
        else
          btn_graf.txt = "Every "+(ini-fin)+" days of "+(ini+1-total_days);
    }
  }
}
void mousePressed() {
  if (mouseButton == RIGHT) {
    boolean can_save = true;
    try {
      data(CONFIRMED, DEATHS, RECOVERED);
      ini = max(0, ini);
      ini = min(date.length-1, ini);
      fin = max(0, fin);
      fin = min(date.length-1, fin);
      for (Country c : country) {
        c.total(ini, fin);
      }
      max_con = -1;
      min_con = 999999999;
      for (Country c : country) {
        if (c.total_confirmed > max_con) max_con = c.total_confirmed;
        if (c.total_confirmed < min_con) min_con = c.total_confirmed;
      }
    }
    catch(Exception e) {
      can_save = false;
      data("data/offline/Confirmed.csv", "data/offline/Death.csv", "data/offline/Recovered.csv");
      println("Can´t read ", e);
    }
    if (can_save) {
      try {
        saveTable(confirmed, "data/offline/Confirmed.csv");
        saveTable(deaths, "data/offline/Death.csv");
        saveTable(recovered, "data/offline/Recovered.csv");
      }
      catch(Exception e) {
        println("Can´t save", e);
      }
    }
  } else if (mouseButton == LEFT) {
    if (mouseX > btn_show_date.x && mouseX < btn_show_date.x+btn_show_date.w && mouseY > btn_show_date.y && mouseY < btn_show_date.y+btn_show_date.h) {
      click = true;
      move = false;
      save_cant = ini - fin;
    } else if (mouseX > btn_total_data.x && mouseX < btn_total_data.x+btn_total_data.w && mouseY > btn_total_data.y && mouseY < btn_total_data.y+btn_total_data.h) {
      if (show_data[0] && show_data[1] && show_data[2]) {
        show_data[0] = true;
        show_data[1] = false;
        show_data[2] = false;
      } else if (show_data[0] && !show_data[1] && !show_data[2]) {
        show_data[0] = false;
        show_data[1] = true;
        show_data[2] = false;
      } else if (!show_data[0] && show_data[1] && !show_data[2]) {
        show_data[0] = false;
        show_data[1] = false;
        show_data[2] = true;
      } else if (!show_data[0] && !show_data[1] && show_data[2]) {
        show_data[0] = true;
        show_data[1] = true;
        show_data[2] = false;
      } else if (show_data[0] && show_data[1] && !show_data[2]) {
        show_data[0] = true;
        show_data[1] = false;
        show_data[2] = true;
      } else if (show_data[0] && !show_data[1] && show_data[2]) {
        show_data[0] = false;
        show_data[1] = true;
        show_data[2] = true;
      } else if (!show_data[0] && show_data[1] && show_data[2]) {
        show_data[0] = true;
        show_data[1] = true;
        show_data[2] = true;
      }
    } else if (mouseX > btn_graf.x && mouseX < btn_graf.x+btn_graf.w && mouseY > btn_graf.y && mouseY < btn_graf.y+btn_graf.h) {
      prom = !prom;
    }
  }
}
void mouseReleased() {
  click = false;
  move = true;
  for (Country c : country) {
    if (c.name.toLowerCase().contains(find) || c.persistent) {
      float d = 5;
      float x = c_xaxis+mercatorX(radians(c.lon)) - mercatorX(0);
      float y = c_yaxis+mercatorY(radians(c.lat)) - mercatorY(0);
      if ((mouseX-width/2) < x+d && (mouseX-width/2) > x-d && (mouseY-height/2) < y+d && (mouseY-height/2) > y-d)
        c.persistent = !c.persistent;
    }
  }
}
void mouseWheel(MouseEvent event) {
  //mouseX > btn_show_date.x && mouseX < btn_show_date.x+btn_show_date.w
  if (mouseX > btn_show_date.x && mouseX < btn_show_date.x+btn_show_date.w) {
    if (mouseY > btn_show_date.y && mouseY < btn_show_date.y+btn_show_date.h/2) {
      ini -= event.getCount();
      fin -= event.getCount();
    } else if (mouseY > btn_show_date.y && mouseY < btn_show_date.y+btn_show_date.h) {
      fin -= event.getCount();
    }
    if (ini < fin) fin = ini;
    if (fin > ini) ini = fin;
    ini = max(0, ini);
    ini = min(date.length-1, ini);
    fin = max(0, fin);
    fin = min(date.length-1, fin);
    for (Country c : country) {
      c.total(ini, fin);
    }
    max_con = -999999999;
    min_con = 999999999;
    for (Country c : country) {
      if (c.name.toLowerCase().contains(find)  || c.persistent) {
        if (c.total_confirmed > max_con) max_con = c.total_confirmed;
        if (c.total_confirmed < min_con) min_con = c.total_confirmed;
      }
    }
    if (mouseY > btn_graf.y && mouseY < btn_graf.y+btn_graf.h) {
      total_days -= event.getCount();
    }
    total_days = min(ini+event.getCount(), total_days);
    total_days = max(0, total_days);
  } else if (mouseX > contries_names.x && mouseX < contries_names.x+contries_names.w && mouseY > contries_names.y && mouseY < contries_names.y+contries_names.h) {
    contries_names_s -= event.getCount();
  } else {
    zoom -= event.getCount()/3.0;
    zoom = max(zoom, 1/3.0);
  }
}

void keyPressed() {
  if (int(key) == 8) {
    char t[] = find.toCharArray();
    find = "";
    for (int i = 0; i < t.length - 1; i++) {
      find += t[i];
    }
  } else if (int(key) != 10) {
    find += key;
  }
  find = find.toLowerCase();
  max_con = -999999999;
  min_con = 999999999;
  for (Country c : country) {
    if (c.name.toLowerCase().contains(find)  || c.persistent) {
      if (c.total_confirmed > max_con) max_con = c.total_confirmed;
      if (c.total_confirmed < min_con) min_con = c.total_confirmed;
    }
  }
}

void data(String co, String de, String re) {
  confirmed = loadTable(co, "header");
  deaths = loadTable(de, "header");
  recovered = loadTable(re, "header");
  int n_country = confirmed.getRowCount();
  country = new Country[n_country];

  int cols = confirmed.getColumnCount()-4;

  date = new String[cols];
  {
    Table confirmed_2 = loadTable(co);
    for (int j = 0; j < cols; j++) {
      date[j] = confirmed_2.getString(0, j+4);
    }
  }

  for (int i = 0; i < n_country; i++) {
    TableRow row = confirmed.getRow(i);
    String name = row.getString("Country/Region");
    String lat = row.getString("Lat");
    String lon = row.getString("Long");

    int[] c = new int[cols];
    int[] d = new int[cols];
    int[] r = new int[cols];

    {
      for (int j = 0; j < cols; j++) {
        c[j] = confirmed.getInt(i, j+4);
      }
    }
    {
      Table search1;
      search1 = new Table();
      search1.addColumn("Province/State");
      search1.addColumn("Country/Region");
      search1.addColumn("Lat");
      search1.addColumn("Long");
      for (int j = 0; j < cols; j++) {
        search1.addColumn(date[j]);
      }
      for (TableRow search_1 : deaths.findRows(name, "Country/Region")) {
        TableRow newRow = search1.addRow();
        newRow.setString("Province/State", search_1.getString("Province/State"));
        newRow.setString("Country/Region", search_1.getString("Country/Region"));
        newRow.setString("Lat", search_1.getString("Lat"));
        newRow.setString("Long", search_1.getString("Long"));
        for (int j = 0; j < cols; j++) {
          newRow.setString(date[j], search_1.getString(date[j]));
        }
      }
      Table search2;
      search2 = new Table();
      search2.addColumn("Province/State");
      search2.addColumn("Country/Region");
      search2.addColumn("Lat");
      search2.addColumn("Long");
      for (int j = 0; j < cols; j++) {
        search2.addColumn(date[j]);
      }
      for (TableRow search_2 : search1.findRows(lat+"", "Lat")) {
        TableRow newRow = search2.addRow();
        newRow.setString("Province/State", search_2.getString("Province/State"));
        newRow.setString("Country/Region", search_2.getString("Country/Region"));
        newRow.setString("Lat", search_2.getString("Lat"));
        newRow.setString("Long", search_2.getString("Long"));
        for (int j = 0; j < cols; j++) {
          newRow.setString(date[j], search_2.getString(date[j]));
        }
      }
      if (search2.getRowCount() == 0) {
        for (TableRow search_2 : search1.findRows(lon+"", "Long")) {
          TableRow newRow = search2.addRow();
          newRow.setString("Province/State", search_2.getString("Province/State"));
          newRow.setString("Country/Region", search_2.getString("Country/Region"));
          newRow.setString("Lat", search_2.getString("Lat"));
          newRow.setString("Long", search_2.getString("Long"));
          for (int j = 0; j < cols; j++) {
            newRow.setString(date[j], search_2.getString(date[j]));
          }
        }
      }
      if (search2.getRowCount() == 0) println(0);

      for (int j = 0; j < cols; j++) {
        TableRow search = search2.findRow(name, "Country/Region");
        d[j] = search.getInt(date[j]);
      }
    }
    {
      Table search1;
      search1 = new Table();
      search1.addColumn("Province/State");
      search1.addColumn("Country/Region");
      search1.addColumn("Lat");
      search1.addColumn("Long");
      for (int j = 0; j < cols; j++) {
        search1.addColumn(date[j]);
      }
      for (TableRow search_1 : recovered.findRows(name, "Country/Region")) {
        TableRow newRow = search1.addRow();
        newRow.setString("Province/State", search_1.getString("Province/State"));
        newRow.setString("Country/Region", search_1.getString("Country/Region"));
        newRow.setString("Lat", search_1.getString("Lat"));
        newRow.setString("Long", search_1.getString("Long"));
        for (int j = 0; j < cols; j++) {
          newRow.setString(date[j], search_1.getString(date[j]));
        }
      }
      Table search2;
      search2 = new Table();
      search2.addColumn("Province/State");
      search2.addColumn("Country/Region");
      search2.addColumn("Lat");
      search2.addColumn("Long");
      for (int j = 0; j < cols; j++) {
        search2.addColumn(date[j]);
      }
      for (TableRow search_2 : search1.findRows(lat+"", "Lat")) {
        TableRow newRow = search2.addRow();
        newRow.setString("Province/State", search_2.getString("Province/State"));
        newRow.setString("Country/Region", search_2.getString("Country/Region"));
        newRow.setString("Lat", search_2.getString("Lat"));
        newRow.setString("Long", search_2.getString("Long"));
        for (int j = 0; j < cols; j++) {
          newRow.setString(date[j], search_2.getString(date[j]));
        }
      }
      if (search2.getRowCount() == 0) {
        for (TableRow search_2 : search1.findRows(lat+"", "Lat")) {
          TableRow newRow = search2.addRow();
          newRow.setString("Province/State", search_2.getString("Province/State"));
          newRow.setString("Country/Region", search_2.getString("Country/Region"));
          newRow.setString("Lat", search_2.getString("Lat"));
          newRow.setString("Long", search_2.getString("Long"));
          for (int j = 0; j < cols; j++) {
            newRow.setString(date[j], search_2.getString(date[j]));
          }
        }
      }
      if (search2.getRowCount() == 0) {
        for (int j = 0; j < cols; j++) {
          r[j] = 0;
        }
      } else {
        for (int j = 0; j < cols; j++) {
          TableRow search = search2.findRow(name, "Country/Region");
          r[j] = search.getInt(date[j]);
        }
      }
    }
    country[i] = new Country(name, float(lat), float(lon), c, d, r);
  }
}
float mercatorX(float lon) {
  return (h/(2*PI))*2*zoom*(lon+PI);
}
float mercatorY(float lat) {
  return (h/(2*PI))*(2*zoom)*(PI-log(tan(PI/4+lat/2)));
}

class SortData implements Comparator<Country> { 
  public int compare(Country a, Country b) {
    int less = 0;
    int i = 0;
    while (less == 0 && i < a.name.length() && i < b.name.length()) {
      less = a.name.charAt(i) - b.name.charAt(i);
      i++;
    }
    return less;
  }
}
