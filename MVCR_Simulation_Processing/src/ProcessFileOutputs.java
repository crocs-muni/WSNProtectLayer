import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

/**
 * Created with IntelliJ IDEA.
 * User: Trimack
 * Date: 5.5.14
 * Time: 17:33
 * To change this template use File | Settings | File Templates.
 */
public class ProcessFileOutputs {
    public static void main(String[] args) throws IOException {
        String current = new File( "output" ).getCanonicalPath();
        System.out.println("Current dir: "+current);

        ArrayList<String> output = new ArrayList<String>();
        File folder = new File(current);
        for (final File fileEntry : folder.listFiles()) {
            System.out.println(fileEntry.getName());
            if (fileEntry.isFile()) {
                System.out.println(fileEntry.getName());
                BufferedReader br = new BufferedReader(new FileReader(fileEntry));
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.startsWith("2014"))
                        output.add(line);
                }
                br.close();
            }
        }

        Collections.sort(output, new OutputComparator());
        for (int i = 0; i < output.size(); i++) {
            System.out.println(output.get(i));
        }
    }


}

class OutputComparator implements Comparator<String> {

    @Override
    public int compare(String o1, String o2) {
        //2014-05-05 09:03:40:161: S: PrivacyP: msg=19:41:88:A2:22:00:FF:FF:28:00:3F:80:01:00:28:00:13:00:00:64:00:28:00:69;src=40;dst=19;type=1;len=24
        Calendar c1 = Calendar.getInstance();
        c1.set(Calendar.YEAR, Integer.parseInt(o1.substring(0,4)));
        c1.set(Calendar.MONTH, Integer.parseInt(o1.substring(5,7)));
        c1.set(Calendar.DAY_OF_MONTH, Integer.parseInt(o1.substring(8,10)));
        c1.set(Calendar.HOUR_OF_DAY, Integer.parseInt(o1.substring(11,13)));
        c1.set(Calendar.MINUTE, Integer.parseInt(o1.substring(14,16)));
        c1.set(Calendar.SECOND, Integer.parseInt(o1.substring(17,19)));
        c1.set(Calendar.MILLISECOND, Integer.parseInt(o1.substring(20,23)));

        Calendar c2 = Calendar.getInstance();
        c2.set(Calendar.YEAR, Integer.parseInt(o2.substring(0,4)));
        c2.set(Calendar.MONTH, Integer.parseInt(o2.substring(5,7)));
        c2.set(Calendar.DAY_OF_MONTH, Integer.parseInt(o2.substring(8,10)));
        c2.set(Calendar.HOUR_OF_DAY, Integer.parseInt(o2.substring(11,13)));
        c2.set(Calendar.MINUTE, Integer.parseInt(o2.substring(14, 16)));
        c2.set(Calendar.SECOND, Integer.parseInt(o2.substring(17,19)));
        c2.set(Calendar.MILLISECOND, Integer.parseInt(o2.substring(20,23)));

        return c1.compareTo(c2);
    }
}
