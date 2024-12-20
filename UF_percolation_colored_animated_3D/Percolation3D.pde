
public class Percolation3D {

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
  public Percolation3D(int N) {
    this.N = N;
    sites = N * N * N;
    count = N * N * N;
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

    for (int i = 0; i < N * N; i++) {
      top[i] = true;
    }

    for (int i = sites - (N * N); i < sites; i++) {
      bottom[i] = true;
    }
  }



  public Percolation3D(int N, int M) {
    /* this constructor opens M or M - 1 sites in the middle of the cube.
     instead of all of the sites on top, these middle sites
     begin with the "top" bit true. percolation occurs when a
     connection is made between these middle sites and the bottom
     */
    this.N = max(3, N);
    sites = N * N * N;
    count = N * N * N;
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

    int mid = sites / 2;
    if (N % 2 == 0) mid -= (N * N / 2 - N / 2);
    M = max(0, M-1);
    for (int i = mid - 2*M; i <= mid + 2*M; i+=4) {
      top[i] = true;
      this.open(i);
    }

    for (int i = sites - (N * N); i < sites; i++) {
      bottom[i] = true;
    }
  }



  public void open(int p) {

    if (opened[p]) return; // if p was already opened don't open it again 
    numOpened++;

    opened[p] = true;
    if (N == 1) percolates = true;      // handles pathological case N = 1

    int[] adjacentSites = { 
      p - 1, p + 1, p - N, p + N, p - N * N, p + N * N
    };

    for (int k = 0; k < adjacentSites.length; k++) {
      int q = adjacentSites[k];

      if (q < 0 || q > sites - 1) continue;
      // skip if q is less than 0 or greater than the number of sites
      if ((k == 2 || k == 3) && (q / (N * N) != p / (N * N))) continue;
      // if we're looking for adjacent sites in the same sheet,
      // skip if p and q are not actually in the same "sheet"
      if ((k == 0 || k == 1) && (q / N != p / N)) continue;
      // if we're looking for adjacent sites on the same row, skip if
      // p and q are not actually on the same row
      if (!opened[q]) continue;
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

    //    println("union between " + p + " " + q);
    //    println("there are " + count + " components");
  }
}

