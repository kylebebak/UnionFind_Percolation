/****************************************************************************
 *  Compilation:  javac WeightedQuickUnionUF.java
 *  Execution:  java WeightedQuickUnionUF < input.txt
 *  Dependencies: StdIn.java StdOut.java
 *
 *  Weighted quick-union (without path compression).
 *
 ****************************************************************************/

public class WeightedQuickUnionUF {
  private int[] id;    // id[i] = parent of i
  private int[] sz;    // sz[i] = number of objects in subtree rooted at i
  private int count;   // number of components

  // Create an empty union find data structure with N isolated sets.
  public WeightedQuickUnionUF(int N) {
    count = N;
    id = new int[N];
    sz = new int[N];
    for (int i = 0; i < N; i++) {
      id[i] = i;
      sz[i] = 1;
    }
  }

  // Return the number of disjoint sets.
  public int count() {
    return count;
  }

  // Return component identifier (root) for component containing p
  public int root(int p) {
    while (p != id[p]) {
      id[p] = id[id[p]];
      // compress path by making every other node in tree as we work towards
      // the root point to its grandparent
      p = id[p];
    }
    return p;
  }

  // Are objects p and q in the same set?
  public boolean connected(int p, int q) {
    return root(p) == root(q);
  }

  // get the size of p's component
  public int getSize(int p) {
    return sz[root(p)];
  }

  // Replace sets containing p and q with their union.
  public void union(int p, int q) {
    int i = root(p);
    int j = root(q);
    if (i == j) return;

    // make smaller root point to larger one
    if   (sz[i] < sz[j]) {
      id[i] = j;
      sz[j] += sz[i];
    }
    else {
      id[j] = i;
      sz[i] += sz[j];
    }
    count--;
  }

  public void splitUp(int p) {
    if (p == id[p]) return;

    int[] rc = findRootAndChild(p);
    int r = rc[0];
    int c = rc[1];
    /*
    StdOut.println("r, c, sz[r], sz[c], id[r], id[c]    : " + r
     + "  " + c + "  " + sz[r] + "  " + sz[c] + "  " + id[r] + "  " + id[c]);
     */
    sz[r] -= sz[c];
    id[c] = c;
    count++;
  }

  public int[] findRootAndChild(int p) {
    // this function takes an object p and goes to the root
    // of its component, and then returns the root and the immediate
    // child of this root that was passed along the way
    int c = p;

    while (p != id[p]) {
      c = p;
      p = id[p];
    }

    int[] rootAndChild = {
      p, c
    };
    return rootAndChild;
  }
}
