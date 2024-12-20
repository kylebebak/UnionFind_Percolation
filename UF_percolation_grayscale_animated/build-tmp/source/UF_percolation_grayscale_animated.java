import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class UF_percolation_grayscale_animated extends PApplet {

int N = 80;
int sites = N*N;

float[][] pos = new float[sites][2];
float[] siteSize = new float[2];

Percolation perc;

int numberOfSitesPerFrame = 3;


public void setup() {

  
  siteSize[0] = (float)width/N;
  siteSize[1] = (float)height/N;

  for (int i=0; i<sites; i++) {
    pos[i][0] = (i%N)*siteSize[0];
    pos[i][1] = (i/N)*siteSize[1];
  }
  colorMode(HSB, 360, 1, 1);

  background(0);
  stroke(0);
  fill(85);
  for (int i=0; i<sites; i++) rect(pos[i][0], pos[i][1], siteSize[0], siteSize[1]);

  perc = new Percolation(N);
}


public void draw() {

  for (int j=0; j<numberOfSitesPerFrame; j++) {

    int p = (int)random(sites);
    // if p was already turned on, skip the rest of the code in the while loop

    perc.open(p);

    if (perc.percolates()) {
      noLoop();
      println();
      println();
      println("There were " + sites + " sites in total");
      println(perc.getOpened() + " were opened before percolation");
      println("There are " + perc.getCount() + " components");
      break;
    }
  }

  int[] maxSizes = perc.getMaxSizes();

  for (int i=0; i<sites; i++) {
    if (perc.isOpen(i)) {
      int componentSize = perc.getSize(i);
      float siteHue;

      if (perc.isFull(i)) {
        siteHue = 100 + 90 * sqrt(componentSize / (float)maxSizes[0]);
        fill(siteHue, 1, 1);
      }
      else {
        siteHue = sqrt(componentSize / (float)maxSizes[1]);
        fill(0, 0, siteHue);
      }

      rect(pos[i][0], pos[i][1], siteSize[0], siteSize[1]);
    }
  }

  // saveFrame("/Users/kylebebak/Desktop/frames/####.png");
}


public float mod(float in, float mod) {
  float quotient=in/mod;
  quotient=PApplet.parseFloat(floor(quotient));
  float out=in-mod*quotient;
  return out;
}
public class Percolation {

  private int[] id; // id[i] = parent of i
  private int[] sz; // sz[i] = number of objects in subtree rooted at i
  private int count; // number of components (total number of disjoint sets)
  private int sites; // there are N * N sites
  private boolean[] opened;
  private boolean[] top;
  private boolean[] bottom;
  private boolean percolates = false;
  private int N; // N * N grid of sites
  private int numOpened;

  // Create an empty union find data structure with N isolated sets.
  public Percolation(int N) {
    this.N = N;
    sites = N * N;
    count = N * N;
    numOpened = 0;

    id = new int[sites];
    sz = new int[sites];
    opened = new boolean[sites];
    top = new boolean[sites];
    bottom = new boolean[sites];

    for (int i = 0; i < sites; i++) {
      id[i] = i;
      sz[i] = 1;
    }

    for (int i = 0; i < N; i++) {
      top[i] = true;
    }

    for (int i = sites - N; i < sites; i++) {
      bottom[i] = true;
    }
  }

  public void open(int p) {

    if (opened[p]) return;
    numOpened++;

    opened[p] = true;
    if (N == 1) percolates = true;      // handles pathological case N = 1

    int[] adjacentSites = {
      p - 1, p + 1, p - N, p + N
    };

    for (int k = 0; k < adjacentSites.length; k++) {
      int q = adjacentSites[k];

      if (q < 0 || q > sites - 1)
        continue;
      // skip if q is less than 0 or greater than the number of sites
      if ((k == 0 || k == 1) && (q / N != p / N))
        continue;
      // if we're looking for adjacent sites on the same row, skip if
      // p and q are not actually on the same row
      if (!opened[q])
        continue;
      // if the adjacent site is blocked, don't call union
      if (connected(p, q)) continue;

      union(p, q);
      int root = find(p);
      if (top[root] && bottom[root]) percolates = true;
    }
  }

  public boolean isFull(int p) {
    return (top[find(p)] && opened[p]);
  }

  // is site (row i, column j) open?
  public boolean isOpen(int p) {
    return (opened[p]);
  }

  public boolean percolates() {
    return percolates;
  }

  public int getCount() {
    return count;
  }

  public int getOpened() {
    return numOpened;
  }

  public int getSize(int p) {
    return sz[find(p)];
  }

  public int getMaxSize() {
    return max(sz);
  }

   public int[] getMaxSizes() {
    // get max component size for both filled and unfilled but open components
    int maxFull = 0;
    int maxOpen = 0;
    int elementSize;
    for (int i = 0; i < sz.length; i++) {
      if (!opened[i]) continue;
        elementSize = sz[i];
        if (isFull(i)) {
          if (elementSize > maxFull) maxFull = elementSize;
        }
        else if (elementSize > maxOpen) maxOpen = elementSize;
    }
    int[] maxSizes = {
      maxFull, maxOpen
    };
    return maxSizes;
  }

  // Return component identifier (root) for component containing p
  private int find(int p) {
    while (p != id[p]) {
      id[p] = id[id[p]];
      // don't compress path because i need every site to point to its
      // immediate parent so that i can split the components up later
      p = id[p];
    }
    return p;
  }

  // Are objects p and q in the same set?
  private boolean connected(int p, int q) {
    return find(p) == find(q);
  }

  // Replace sets containing p and q with their union.
  private void union(int p, int q) {
    int i = find(p);
    int j = find(q);
    if (i == j)
      return;

    if (top[i]) top[j] = true;
    else if (top[j]) top[i] = true;

    if (bottom[i]) bottom[j] = true;
    else if (bottom[j]) bottom[i] = true;

    // make smaller root point to larger one
    if (sz[i] < sz[j]) {
      id[i] = j;
      sz[j] += sz[i];
    }
    else {
      id[j] = i;
      sz[i] += sz[j];
    }

    count--;
  }
}
  public void settings() {  size(700, 700); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "UF_percolation_grayscale_animated" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
