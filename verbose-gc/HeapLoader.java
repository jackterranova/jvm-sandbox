public class HeapLoader {
  public static void main(String args[]) {
    for (int i = 0; i < 1000000; i++) {
      StringBuffer sb = new StringBuffer();
      sb.append(i);
    }

    System.out.println("DONE");
  }
}
