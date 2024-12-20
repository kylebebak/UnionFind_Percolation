int N = 80;
int sites = N*N;

boolean percolated = false;
boolean phase2     = false;
boolean[] opened = new boolean[sites];
int openSites = 0;

float[][] pos = new float[sites][2];
float[] siteSize = new float[2];

WeightedQuickUnionUF ufperc;
WeightedQuickUnionUF ufdraw;

int numberOfSitesPerFrame = 30;
int endPhase2 = 10;


void setup() {

  size(800, 800);
  siteSize[0] = (float)width/N;
  siteSize[1] = (float)height/N;

  for (int i=0; i<sites; i++) {
    pos[i][0] = (i%N)*siteSize[0];
    pos[i][1] = (i/N)*siteSize[1];
  }
  colorMode(HSB, 360, 1, 1);

  stroke(0);

  ufperc = new WeightedQuickUnionUF(N*N+2);
  for (int i=0; i<N; i++) ufperc.union(N*N, i);
  for (int i=N*(N-1); i<N*N; i++) ufperc.union(N*N+1, i);
  ufdraw = new WeightedQuickUnionUF(N*N);
}


void draw() {

  if (!phase2) {
    for (int j=0; j<numberOfSitesPerFrame; j++) {

      int p = (int)random(sites);
      // if p was already turned on, skip the rest of the code in the while loop

      if (!opened[p]) openSites++;
      opened[p] = true;

      int[] adjacentSites = {
        p-1, p+1, p-N, p+N
      };
      for (int i=0; i<adjacentSites.length; i++) {
        int q = adjacentSites[i];
        if (q < 0 || q > sites - 1) continue;
        // skip if q is less than 0 or greater than the number of sites
        if ( (i == 0 || i == 1) && (q/N != p/N) ) continue;
        // if we're looking for adjacent sites on the same row, skip if
        // p and q are not actually on the same row

        if (!opened[q]) continue;
        //if (ufperc.connected(p, q)) continue;
        // this line of code probably isn't necessary--they shouldn't already
        // be connected because p was just turned on
        ufperc.union(p, q);
        ufdraw.union(p, q);
      }

      percolated = (ufperc.connected(N * N, N * N + 1));

      if (percolated) {
        phase2 = true;
        println();
        println();
        println("There were " + sites + " sites in total");
        println(openSites + " were opened before percolation");
        println("There are " + ufdraw.count() + " components");
        break;
      }
    }
  }

  if (phase2) {

    int p = (int)random(sites);
    for (int j=0; j<5*numberOfSitesPerFrame; j++) {
      ufdraw.splitUp(p);
    }
    if (max(ufdraw.sz) < endPhase2) {
      phase2 = false;
      noLoop();
    }
  }

  int minComponentSize = 2;
  int maxSize = max(ufdraw.sz);
  println("The biggest component has " + maxSize + " sites");

  for (int i=0; i<sites; i++) {
    if (opened[i]) {
      int componentSize = ufdraw.getSize(i);
      if (componentSize < minComponentSize) fill(0, 1, 1);
      else {
        float siteHue = 30 + 170*componentSize / (float)maxSize;
        fill(siteHue, 1, 1);
      }
    }
    else fill(85);

    rect(pos[i][0], pos[i][1], siteSize[0], siteSize[1]);
  }
}
