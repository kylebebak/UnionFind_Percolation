int N = 200;
int sites = N*N;

float[][] pos = new float[sites][2];
float[] siteSize = new float[2];

Percolation perc;

int numberOfSitesPerFrame = 150;


void setup() {

  size(750, 750);
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


void draw() {

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

      if (perc.isFull(i)) siteHue = 100 + 90 * sqrt(componentSize / (float)maxSizes[0]);
      else {
        siteHue = 60 - 120 * sqrt(componentSize / (float)maxSizes[1]);
        siteHue = mod(siteHue, 360);
      }

      fill(siteHue, 1, 1);
      rect(pos[i][0], pos[i][1], siteSize[0], siteSize[1]);
    }

  }

}

float mod(float in, float mod) {
  float quotient=in/mod;
  quotient=float(floor(quotient));
  float out=in-mod*quotient;
  return out;
}
