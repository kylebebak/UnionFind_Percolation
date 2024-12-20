import peasy.*;

int N = 41;
int M = 7;
int sites = N*N*N;

float boxSpacing;
float boxSize;

Percolation3D perc;
PeasyCam cam;

int numberOfSitesPerFrame = 120;
boolean finished = false;





void setup() {

  size(1000, 750, P3D);
  boxSpacing = .5*height / (float)N;
  boxSize = boxSpacing / 3.0;

  colorMode(HSB, 360, 1, 1, 1);
  noStroke();

  perc = new Percolation3D(N);

  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(25);
  cam.setMaximumDistance(2500);
}



void draw() {

  if (!finished) for (int j=0; j<numberOfSitesPerFrame; j++) {

    int p = (int)random(sites);

    perc.open(p);

    if (perc.percolates()) {
      println();
      println();
      println("There were " + sites + " sites in total");
      println(perc.getOpened() + " were opened before percolation");
      println("There are " + perc.getCount() + " components");
      finished = true;
      break;
    }
  }

  rotateX(+.5);
  rotateY(+.5);
  translate(-width/3.5, -height/8.0);

  background(0);
  draw3dBoxGrid(N, boxSpacing, boxSize);
  
//  saveFrame("/Users/kylebebak/Desktop/frames/####.png");
}



void draw3dBoxGrid(int N, float boxSpacing, float boxSize) {
  int p, componentSize;   // p is box index
  int[] maxSizes; //max size for both full components and not full but open components
  // so they can be colored individually
  float siteHue, transparency;
  maxSizes = perc.getMaxSizes();

  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      for (int k = 0; k < N; k++) {

        translate(boxSpacing, 0, 0);

        p = N*N*i + N*j + k;
        if (perc.isOpen(p)) {
          componentSize = perc.getSize(p);

          if (perc.isFull(p)) {
            siteHue = 80 + 130 * sqrt(componentSize / (float)maxSizes[0]);
            fill(siteHue, 1, 1, .6);
          } 
          else {
            siteHue = 70 - 150 * sqrt(sqrt(componentSize / (float)maxSizes[1]));
            transparency = .125 + .2*(componentSize / (float)maxSizes[1]);
            siteHue = mod(siteHue, 360);
            fill(siteHue, 1, 1, .2);
          }

          box(boxSize);
        }
      }

      translate(-N * boxSpacing, 0, 0);
      translate(0, 0, boxSpacing);
    }

    translate(0, 0, -N * boxSpacing);
    translate(0, boxSpacing, 0);
  }
}



float mod(float in, float mod) {
  float quotient=in/mod;
  quotient=float(floor(quotient));
  float out=in-mod*quotient;
  return out;
}

