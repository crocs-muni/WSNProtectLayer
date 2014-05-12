/**
 * Created with IntelliJ IDEA.
 * User: Trimack
 * Date: 7.5.14
 * Time: 11:45
 * To change this template use File | Settings | File Templates.
 */
public class ChannelGenerator {
    public static void main(String[] args) {
        String[] nodesList = {"4", "5", "6", "7", "10", "14", "15", "17", "19", "22", "25", "28", "29", "30", "31",
                "32", "33", "35", "36", "37", "40", "41", "42", "43", "44", "46", "47", "48", "50"};

        for (int i = 0; i < nodesList.length; i++) {
            for (int j = i + 1; j < nodesList.length; j++) {
                System.out.println("node_" + nodesList[i] + ".gateTo[" + nodesList[j] +
                        "] <--> Channel <--> node_" + nodesList[j] + ".gateTo[" + nodesList[i] + "];");
            }
        }
    }
}
