package vizualization.simulations;

import ned.DelayChannel;
import vizualization.*;

//
// A generated network with grid topology.
//
network PoliceApp
{
    //TODO namerene hodnoty rssi od Dusana/Martina obsahovaly uzly 4, 12 a 13.. kde jsou?
    @display("bgb=889,839;bgi=custom/Mirov2");

    types:
        channel Channel extends ned.DelayChannel
        {
            @display("ls=black,0,do");
        }

    submodules:
        inject: Injector {
            //@display("b=0,0,rectangle;p=23,42");
            @display("i=custom/spacer");
        }

        attacker: Attacker {
            @display("p=11,536");
        }

        node_04: Node {
            @display("p=562,478");

        }
        node_05: Node {
            @display("p=72,273");

        }
        node_06: Node {
            @display("p=849,410");

        }
        node_07: Node {
            @display("p=661,745");

        }
        node_10: Node {
            @display("p=623,75");

        }
        node_14: Node {
            @display("p=367,676");

        }
        node_15: Node {
            @display("p=482,796");

        }
        node_17: Node {
            @display("p=533,653");

        }
        node_19: Node {
            @display("p=722,449");

        }
        node_22: Node {
            @display("p=274,439");

        }
        node_25: Node {
            @display("p=533,157");

        }
        node_28: Node {
            @display("p=795,598");

        }
        node_29: Node {
            @display("p=406,42");

        }
        node_30: Node {
            @display("p=149,676");

        }
        node_31: Node {
            @display("p=324,294");

        }
        node_32: Node {
            @display("p=204,108");

        }
        node_33: Node {
            @display("p=543,312");

        }
        node_35: Node {
            @display("p=222,598");

        }
        node_36: Node {
            @display("p=47,489");

        }
        node_37: Node {
            @display("p=399,553");

        }
        node_40: Node {
            @display("p=169,305");

        }
        node_41: Node {
            @display("p=421,410");

        }
        node_42: Node {
            @display("p=143,463");

        }
        node_43: Node {
            @display("p=306,778");

        }
        node_44: Node {
            @display("p=445,253");

        }
        node_46: Node {
            @display("p=655,241");

        }
        node_47: Node {
            @display("p=776,214");

        }
        node_48: Node {
            @display("p=722,344");

        }
        node_50: Node {
            @display("p=335,157");

        }

    connections:
        node_04.gateTo[19] <--> Channel <--> node_19.gateTo[4];
        node_04.gateTo[28] <--> Channel <--> node_28.gateTo[4];
        node_04.gateTo[41] <--> Channel <--> node_41.gateTo[4];
        node_10.gateTo[5] <--> Channel <--> node_05.gateTo[10];
        node_10.gateTo[6] <--> Channel <--> node_06.gateTo[10];
        node_10.gateTo[7] <--> Channel <--> node_07.gateTo[10];
        node_10.gateTo[14] <--> Channel <--> node_14.gateTo[10];
        node_10.gateTo[17] <--> Channel <--> node_17.gateTo[10];
        node_10.gateTo[22] <--> Channel <--> node_22.gateTo[10];
        node_10.gateTo[25] <--> Channel <--> node_25.gateTo[10];
        node_10.gateTo[28] <--> Channel <--> node_28.gateTo[10];
        node_10.gateTo[29] <--> Channel <--> node_29.gateTo[10];
        node_10.gateTo[30] <--> Channel <--> node_30.gateTo[10];
        node_10.gateTo[31] <--> Channel <--> node_31.gateTo[10];
        node_10.gateTo[32] <--> Channel <--> node_32.gateTo[10];
        node_10.gateTo[33] <--> Channel <--> node_33.gateTo[10];
        node_10.gateTo[35] <--> Channel <--> node_35.gateTo[10];
        node_10.gateTo[36] <--> Channel <--> node_36.gateTo[10];
        node_10.gateTo[37] <--> Channel <--> node_37.gateTo[10];
        node_10.gateTo[41] <--> Channel <--> node_41.gateTo[10];
        node_10.gateTo[42] <--> Channel <--> node_42.gateTo[10];
        node_10.gateTo[43] <--> Channel <--> node_43.gateTo[10];
        node_10.gateTo[44] <--> Channel <--> node_44.gateTo[10];
        node_10.gateTo[46] <--> Channel <--> node_46.gateTo[10];
        node_10.gateTo[47] <--> Channel <--> node_47.gateTo[10];
        node_10.gateTo[48] <--> Channel <--> node_48.gateTo[10];
        node_10.gateTo[50] <--> Channel <--> node_50.gateTo[10];
        node_14.gateTo[5] <--> Channel <--> node_05.gateTo[14];
        node_14.gateTo[6] <--> Channel <--> node_06.gateTo[14];
        node_14.gateTo[7] <--> Channel <--> node_07.gateTo[14];
        node_14.gateTo[15] <--> Channel <--> node_15.gateTo[14];
        node_14.gateTo[17] <--> Channel <--> node_17.gateTo[14];
        node_14.gateTo[22] <--> Channel <--> node_22.gateTo[14];
        node_14.gateTo[25] <--> Channel <--> node_25.gateTo[14];
        node_14.gateTo[28] <--> Channel <--> node_28.gateTo[14];
        node_14.gateTo[29] <--> Channel <--> node_29.gateTo[14];
        node_14.gateTo[30] <--> Channel <--> node_30.gateTo[14];
        node_14.gateTo[31] <--> Channel <--> node_31.gateTo[14];
        node_14.gateTo[33] <--> Channel <--> node_33.gateTo[14];
        node_14.gateTo[35] <--> Channel <--> node_35.gateTo[14];
        node_14.gateTo[36] <--> Channel <--> node_36.gateTo[14];
        node_14.gateTo[37] <--> Channel <--> node_37.gateTo[14];
        node_14.gateTo[41] <--> Channel <--> node_41.gateTo[14];
        node_14.gateTo[42] <--> Channel <--> node_42.gateTo[14];
        node_14.gateTo[43] <--> Channel <--> node_43.gateTo[14];
        node_14.gateTo[44] <--> Channel <--> node_44.gateTo[14];
        node_14.gateTo[46] <--> Channel <--> node_46.gateTo[14];
        node_14.gateTo[47] <--> Channel <--> node_47.gateTo[14];
        node_14.gateTo[48] <--> Channel <--> node_48.gateTo[14];
        node_14.gateTo[50] <--> Channel <--> node_50.gateTo[14];
        node_15.gateTo[5] <--> Channel <--> node_05.gateTo[15];
        node_15.gateTo[6] <--> Channel <--> node_06.gateTo[15];
        node_15.gateTo[7] <--> Channel <--> node_07.gateTo[15];
        node_15.gateTo[10] <--> Channel <--> node_10.gateTo[15];
        node_15.gateTo[17] <--> Channel <--> node_17.gateTo[15];
        node_15.gateTo[22] <--> Channel <--> node_22.gateTo[15];
        node_15.gateTo[25] <--> Channel <--> node_25.gateTo[15];
        node_15.gateTo[28] <--> Channel <--> node_28.gateTo[15];
        node_15.gateTo[29] <--> Channel <--> node_29.gateTo[15];
        node_15.gateTo[30] <--> Channel <--> node_30.gateTo[15];
        node_15.gateTo[31] <--> Channel <--> node_31.gateTo[15];
        node_15.gateTo[33] <--> Channel <--> node_33.gateTo[15];
        node_15.gateTo[35] <--> Channel <--> node_35.gateTo[15];
        node_15.gateTo[36] <--> Channel <--> node_36.gateTo[15];
        node_15.gateTo[37] <--> Channel <--> node_37.gateTo[15];
        node_15.gateTo[41] <--> Channel <--> node_41.gateTo[15];
        node_15.gateTo[42] <--> Channel <--> node_42.gateTo[15];
        node_15.gateTo[43] <--> Channel <--> node_43.gateTo[15];
        node_15.gateTo[44] <--> Channel <--> node_44.gateTo[15];
        node_15.gateTo[46] <--> Channel <--> node_46.gateTo[15];
        node_15.gateTo[47] <--> Channel <--> node_47.gateTo[15];
        node_15.gateTo[48] <--> Channel <--> node_48.gateTo[15];
        node_15.gateTo[50] <--> Channel <--> node_50.gateTo[15];
        node_17.gateTo[5] <--> Channel <--> node_05.gateTo[17];
        node_17.gateTo[6] <--> Channel <--> node_06.gateTo[17];
        node_17.gateTo[7] <--> Channel <--> node_07.gateTo[17];
        node_17.gateTo[22] <--> Channel <--> node_22.gateTo[17];
        node_17.gateTo[25] <--> Channel <--> node_25.gateTo[17];
        node_17.gateTo[28] <--> Channel <--> node_28.gateTo[17];
        node_17.gateTo[29] <--> Channel <--> node_29.gateTo[17];
        node_17.gateTo[30] <--> Channel <--> node_30.gateTo[17];
        node_17.gateTo[31] <--> Channel <--> node_31.gateTo[17];
        node_17.gateTo[32] <--> Channel <--> node_32.gateTo[17];
        node_17.gateTo[33] <--> Channel <--> node_33.gateTo[17];
        node_17.gateTo[35] <--> Channel <--> node_35.gateTo[17];
        node_17.gateTo[36] <--> Channel <--> node_36.gateTo[17];
        node_17.gateTo[37] <--> Channel <--> node_37.gateTo[17];
        node_17.gateTo[41] <--> Channel <--> node_41.gateTo[17];
        node_17.gateTo[42] <--> Channel <--> node_42.gateTo[17];
        node_17.gateTo[43] <--> Channel <--> node_43.gateTo[17];
        node_17.gateTo[44] <--> Channel <--> node_44.gateTo[17];
        node_17.gateTo[46] <--> Channel <--> node_46.gateTo[17];
        node_17.gateTo[47] <--> Channel <--> node_47.gateTo[17];
        node_17.gateTo[48] <--> Channel <--> node_48.gateTo[17];
        node_17.gateTo[50] <--> Channel <--> node_50.gateTo[17];
        node_22.gateTo[5] <--> Channel <--> node_05.gateTo[22];
        node_22.gateTo[6] <--> Channel <--> node_06.gateTo[22];
        node_22.gateTo[7] <--> Channel <--> node_07.gateTo[22];
        node_22.gateTo[25] <--> Channel <--> node_25.gateTo[22];
        node_22.gateTo[28] <--> Channel <--> node_28.gateTo[22];
        node_22.gateTo[29] <--> Channel <--> node_29.gateTo[22];
        node_22.gateTo[30] <--> Channel <--> node_30.gateTo[22];
        node_22.gateTo[31] <--> Channel <--> node_31.gateTo[22];
        node_22.gateTo[32] <--> Channel <--> node_32.gateTo[22];
        node_22.gateTo[33] <--> Channel <--> node_33.gateTo[22];
        node_22.gateTo[35] <--> Channel <--> node_35.gateTo[22];
        node_22.gateTo[36] <--> Channel <--> node_36.gateTo[22];
        node_22.gateTo[37] <--> Channel <--> node_37.gateTo[22];
        node_22.gateTo[40] <--> Channel <--> node_40.gateTo[22];
        node_22.gateTo[41] <--> Channel <--> node_41.gateTo[22];
        node_22.gateTo[42] <--> Channel <--> node_42.gateTo[22];
        node_22.gateTo[43] <--> Channel <--> node_43.gateTo[22];
        node_22.gateTo[44] <--> Channel <--> node_44.gateTo[22];
        node_22.gateTo[46] <--> Channel <--> node_46.gateTo[22];
        node_22.gateTo[47] <--> Channel <--> node_47.gateTo[22];
        node_22.gateTo[48] <--> Channel <--> node_48.gateTo[22];
        node_22.gateTo[50] <--> Channel <--> node_50.gateTo[22];
        node_25.gateTo[5] <--> Channel <--> node_05.gateTo[25];
        node_25.gateTo[6] <--> Channel <--> node_06.gateTo[25];
        node_25.gateTo[7] <--> Channel <--> node_07.gateTo[25];
        node_25.gateTo[28] <--> Channel <--> node_28.gateTo[25];
        node_25.gateTo[29] <--> Channel <--> node_29.gateTo[25];
        node_25.gateTo[30] <--> Channel <--> node_30.gateTo[25];
        node_25.gateTo[31] <--> Channel <--> node_31.gateTo[25];
        node_25.gateTo[32] <--> Channel <--> node_32.gateTo[25];
        node_25.gateTo[33] <--> Channel <--> node_33.gateTo[25];
        node_25.gateTo[35] <--> Channel <--> node_35.gateTo[25];
        node_25.gateTo[36] <--> Channel <--> node_36.gateTo[25];
        node_25.gateTo[37] <--> Channel <--> node_37.gateTo[25];
        node_25.gateTo[41] <--> Channel <--> node_41.gateTo[25];
        node_25.gateTo[42] <--> Channel <--> node_42.gateTo[25];
        node_25.gateTo[43] <--> Channel <--> node_43.gateTo[25];
        node_25.gateTo[44] <--> Channel <--> node_44.gateTo[25];
        node_25.gateTo[46] <--> Channel <--> node_46.gateTo[25];
        node_25.gateTo[47] <--> Channel <--> node_47.gateTo[25];
        node_25.gateTo[48] <--> Channel <--> node_48.gateTo[25];
        node_25.gateTo[50] <--> Channel <--> node_50.gateTo[25];
        node_28.gateTo[5] <--> Channel <--> node_05.gateTo[28];
        node_28.gateTo[6] <--> Channel <--> node_06.gateTo[28];
        node_28.gateTo[7] <--> Channel <--> node_07.gateTo[28];
        node_28.gateTo[29] <--> Channel <--> node_29.gateTo[28];
        node_28.gateTo[30] <--> Channel <--> node_30.gateTo[28];
        node_28.gateTo[31] <--> Channel <--> node_31.gateTo[28];
        node_28.gateTo[32] <--> Channel <--> node_32.gateTo[28];
        node_28.gateTo[33] <--> Channel <--> node_33.gateTo[28];
        node_28.gateTo[35] <--> Channel <--> node_35.gateTo[28];
        node_28.gateTo[36] <--> Channel <--> node_36.gateTo[28];
        node_28.gateTo[37] <--> Channel <--> node_37.gateTo[28];
        node_28.gateTo[41] <--> Channel <--> node_41.gateTo[28];
        node_28.gateTo[42] <--> Channel <--> node_42.gateTo[28];
        node_28.gateTo[43] <--> Channel <--> node_43.gateTo[28];
        node_28.gateTo[44] <--> Channel <--> node_44.gateTo[28];
        node_28.gateTo[46] <--> Channel <--> node_46.gateTo[28];
        node_28.gateTo[47] <--> Channel <--> node_47.gateTo[28];
        node_28.gateTo[48] <--> Channel <--> node_48.gateTo[28];
        node_28.gateTo[50] <--> Channel <--> node_50.gateTo[28];
        node_29.gateTo[5] <--> Channel <--> node_05.gateTo[29];
        node_29.gateTo[6] <--> Channel <--> node_06.gateTo[29];
        node_29.gateTo[7] <--> Channel <--> node_07.gateTo[29];
        node_29.gateTo[30] <--> Channel <--> node_30.gateTo[29];
        node_29.gateTo[31] <--> Channel <--> node_31.gateTo[29];
        node_29.gateTo[32] <--> Channel <--> node_32.gateTo[29];
        node_29.gateTo[33] <--> Channel <--> node_33.gateTo[29];
        node_29.gateTo[35] <--> Channel <--> node_35.gateTo[29];
        node_29.gateTo[36] <--> Channel <--> node_36.gateTo[29];
        node_29.gateTo[37] <--> Channel <--> node_37.gateTo[29];
        node_29.gateTo[41] <--> Channel <--> node_41.gateTo[29];
        node_29.gateTo[42] <--> Channel <--> node_42.gateTo[29];
        node_29.gateTo[43] <--> Channel <--> node_43.gateTo[29];
        node_29.gateTo[44] <--> Channel <--> node_44.gateTo[29];
        node_29.gateTo[46] <--> Channel <--> node_46.gateTo[29];
        node_29.gateTo[47] <--> Channel <--> node_47.gateTo[29];
        node_29.gateTo[48] <--> Channel <--> node_48.gateTo[29];
        node_29.gateTo[50] <--> Channel <--> node_50.gateTo[29];
        node_30.gateTo[5] <--> Channel <--> node_05.gateTo[30];
        node_30.gateTo[6] <--> Channel <--> node_06.gateTo[30];
        node_30.gateTo[7] <--> Channel <--> node_07.gateTo[30];
        node_30.gateTo[31] <--> Channel <--> node_31.gateTo[30];
        node_30.gateTo[32] <--> Channel <--> node_32.gateTo[30];
        node_30.gateTo[33] <--> Channel <--> node_33.gateTo[30];
        node_30.gateTo[35] <--> Channel <--> node_35.gateTo[30];
        node_30.gateTo[36] <--> Channel <--> node_36.gateTo[30];
        node_30.gateTo[37] <--> Channel <--> node_37.gateTo[30];
        node_30.gateTo[41] <--> Channel <--> node_41.gateTo[30];
        node_30.gateTo[42] <--> Channel <--> node_42.gateTo[30];
        node_30.gateTo[43] <--> Channel <--> node_43.gateTo[30];
        node_30.gateTo[44] <--> Channel <--> node_44.gateTo[30];
        node_30.gateTo[46] <--> Channel <--> node_46.gateTo[30];
        node_30.gateTo[47] <--> Channel <--> node_47.gateTo[30];
        node_30.gateTo[48] <--> Channel <--> node_48.gateTo[30];
        node_30.gateTo[50] <--> Channel <--> node_50.gateTo[30];
        node_31.gateTo[5] <--> Channel <--> node_05.gateTo[31];
        node_31.gateTo[6] <--> Channel <--> node_06.gateTo[31];
        node_31.gateTo[7] <--> Channel <--> node_07.gateTo[31];
        node_31.gateTo[32] <--> Channel <--> node_32.gateTo[31];
        node_31.gateTo[33] <--> Channel <--> node_33.gateTo[31];
        node_31.gateTo[35] <--> Channel <--> node_35.gateTo[31];
        node_31.gateTo[36] <--> Channel <--> node_36.gateTo[31];
        node_31.gateTo[37] <--> Channel <--> node_37.gateTo[31];
        node_31.gateTo[41] <--> Channel <--> node_41.gateTo[31];
        node_31.gateTo[42] <--> Channel <--> node_42.gateTo[31];
        node_31.gateTo[43] <--> Channel <--> node_43.gateTo[31];
        node_31.gateTo[44] <--> Channel <--> node_44.gateTo[31];
        node_31.gateTo[46] <--> Channel <--> node_46.gateTo[31];
        node_31.gateTo[47] <--> Channel <--> node_47.gateTo[31];
        node_31.gateTo[48] <--> Channel <--> node_48.gateTo[31];
        node_31.gateTo[50] <--> Channel <--> node_50.gateTo[31];
        node_32.gateTo[5] <--> Channel <--> node_05.gateTo[32];
        node_32.gateTo[6] <--> Channel <--> node_06.gateTo[32];
        node_32.gateTo[7] <--> Channel <--> node_07.gateTo[32];
        node_32.gateTo[33] <--> Channel <--> node_33.gateTo[32];
        node_32.gateTo[35] <--> Channel <--> node_35.gateTo[32];
        node_32.gateTo[36] <--> Channel <--> node_36.gateTo[32];
        node_32.gateTo[37] <--> Channel <--> node_37.gateTo[32];
        node_32.gateTo[41] <--> Channel <--> node_41.gateTo[32];
        node_32.gateTo[42] <--> Channel <--> node_42.gateTo[32];
        node_32.gateTo[43] <--> Channel <--> node_43.gateTo[32];
        node_32.gateTo[44] <--> Channel <--> node_44.gateTo[32];
        node_32.gateTo[46] <--> Channel <--> node_46.gateTo[32];
        node_32.gateTo[47] <--> Channel <--> node_47.gateTo[32];
        node_32.gateTo[48] <--> Channel <--> node_48.gateTo[32];
        node_32.gateTo[50] <--> Channel <--> node_50.gateTo[32];
        node_33.gateTo[5] <--> Channel <--> node_05.gateTo[33];
        node_33.gateTo[6] <--> Channel <--> node_06.gateTo[33];
        node_33.gateTo[7] <--> Channel <--> node_07.gateTo[33];
        node_33.gateTo[35] <--> Channel <--> node_35.gateTo[33];
        node_33.gateTo[36] <--> Channel <--> node_36.gateTo[33];
        node_33.gateTo[37] <--> Channel <--> node_37.gateTo[33];
        node_33.gateTo[41] <--> Channel <--> node_41.gateTo[33];
        node_33.gateTo[42] <--> Channel <--> node_42.gateTo[33];
        node_33.gateTo[43] <--> Channel <--> node_43.gateTo[33];
        node_33.gateTo[44] <--> Channel <--> node_44.gateTo[33];
        node_33.gateTo[46] <--> Channel <--> node_46.gateTo[33];
        node_33.gateTo[47] <--> Channel <--> node_47.gateTo[33];
        node_33.gateTo[48] <--> Channel <--> node_48.gateTo[33];
        node_33.gateTo[50] <--> Channel <--> node_50.gateTo[33];
        node_35.gateTo[5] <--> Channel <--> node_05.gateTo[35];
        node_35.gateTo[6] <--> Channel <--> node_06.gateTo[35];
        node_35.gateTo[7] <--> Channel <--> node_07.gateTo[35];
        node_35.gateTo[36] <--> Channel <--> node_36.gateTo[35];
        node_35.gateTo[37] <--> Channel <--> node_37.gateTo[35];
        node_35.gateTo[41] <--> Channel <--> node_41.gateTo[35];
        node_35.gateTo[42] <--> Channel <--> node_42.gateTo[35];
        node_35.gateTo[43] <--> Channel <--> node_43.gateTo[35];
        node_35.gateTo[44] <--> Channel <--> node_44.gateTo[35];
        node_35.gateTo[46] <--> Channel <--> node_46.gateTo[35];
        node_35.gateTo[47] <--> Channel <--> node_47.gateTo[35];
        node_35.gateTo[48] <--> Channel <--> node_48.gateTo[35];
        node_35.gateTo[50] <--> Channel <--> node_50.gateTo[35];
        node_36.gateTo[5] <--> Channel <--> node_05.gateTo[36];
        node_36.gateTo[6] <--> Channel <--> node_06.gateTo[36];
        node_36.gateTo[7] <--> Channel <--> node_07.gateTo[36];
        node_36.gateTo[37] <--> Channel <--> node_37.gateTo[36];
        node_36.gateTo[41] <--> Channel <--> node_41.gateTo[36];
        node_36.gateTo[42] <--> Channel <--> node_42.gateTo[36];
        node_36.gateTo[43] <--> Channel <--> node_43.gateTo[36];
        node_36.gateTo[44] <--> Channel <--> node_44.gateTo[36];
        node_36.gateTo[46] <--> Channel <--> node_46.gateTo[36];
        node_36.gateTo[47] <--> Channel <--> node_47.gateTo[36];
        node_36.gateTo[48] <--> Channel <--> node_48.gateTo[36];
        node_36.gateTo[50] <--> Channel <--> node_50.gateTo[36];
        node_37.gateTo[5] <--> Channel <--> node_05.gateTo[37];
        node_37.gateTo[6] <--> Channel <--> node_06.gateTo[37];
        node_37.gateTo[7] <--> Channel <--> node_07.gateTo[37];
        node_37.gateTo[41] <--> Channel <--> node_41.gateTo[37];
        node_37.gateTo[42] <--> Channel <--> node_42.gateTo[37];
        node_37.gateTo[43] <--> Channel <--> node_43.gateTo[37];
        node_37.gateTo[44] <--> Channel <--> node_44.gateTo[37];
        node_37.gateTo[46] <--> Channel <--> node_46.gateTo[37];
        node_37.gateTo[47] <--> Channel <--> node_47.gateTo[37];
        node_37.gateTo[48] <--> Channel <--> node_48.gateTo[37];
        node_37.gateTo[50] <--> Channel <--> node_50.gateTo[37];
        node_41.gateTo[5] <--> Channel <--> node_05.gateTo[41];
        node_41.gateTo[6] <--> Channel <--> node_06.gateTo[41];
        node_41.gateTo[7] <--> Channel <--> node_07.gateTo[41];
        node_41.gateTo[42] <--> Channel <--> node_42.gateTo[41];
        node_41.gateTo[43] <--> Channel <--> node_43.gateTo[41];
        node_41.gateTo[44] <--> Channel <--> node_44.gateTo[41];
        node_41.gateTo[46] <--> Channel <--> node_46.gateTo[41];
        node_41.gateTo[47] <--> Channel <--> node_47.gateTo[41];
        node_41.gateTo[48] <--> Channel <--> node_48.gateTo[41];
        node_41.gateTo[50] <--> Channel <--> node_50.gateTo[41];
        node_42.gateTo[5] <--> Channel <--> node_05.gateTo[42];
        node_42.gateTo[6] <--> Channel <--> node_06.gateTo[42];
        node_42.gateTo[7] <--> Channel <--> node_07.gateTo[42];
        node_42.gateTo[43] <--> Channel <--> node_43.gateTo[42];
        node_42.gateTo[44] <--> Channel <--> node_44.gateTo[42];
        node_42.gateTo[46] <--> Channel <--> node_46.gateTo[42];
        node_42.gateTo[47] <--> Channel <--> node_47.gateTo[42];
        node_42.gateTo[48] <--> Channel <--> node_48.gateTo[42];
        node_42.gateTo[50] <--> Channel <--> node_50.gateTo[42];
        node_43.gateTo[5] <--> Channel <--> node_05.gateTo[43];
        node_43.gateTo[6] <--> Channel <--> node_06.gateTo[43];
        node_43.gateTo[7] <--> Channel <--> node_07.gateTo[43];
        node_43.gateTo[44] <--> Channel <--> node_44.gateTo[43];
        node_43.gateTo[46] <--> Channel <--> node_46.gateTo[43];
        node_43.gateTo[47] <--> Channel <--> node_47.gateTo[43];
        node_43.gateTo[48] <--> Channel <--> node_48.gateTo[43];
        node_43.gateTo[50] <--> Channel <--> node_50.gateTo[43];
        node_44.gateTo[5] <--> Channel <--> node_05.gateTo[44];
        node_44.gateTo[6] <--> Channel <--> node_06.gateTo[44];
        node_44.gateTo[7] <--> Channel <--> node_07.gateTo[44];
        node_44.gateTo[46] <--> Channel <--> node_46.gateTo[44];
        node_44.gateTo[47] <--> Channel <--> node_47.gateTo[44];
        node_44.gateTo[48] <--> Channel <--> node_48.gateTo[44];
        node_44.gateTo[50] <--> Channel <--> node_50.gateTo[44];
        node_46.gateTo[5] <--> Channel <--> node_05.gateTo[46];
        node_46.gateTo[6] <--> Channel <--> node_06.gateTo[46];
        node_46.gateTo[7] <--> Channel <--> node_07.gateTo[46];
        node_46.gateTo[47] <--> Channel <--> node_47.gateTo[46];
        node_46.gateTo[48] <--> Channel <--> node_48.gateTo[46];
        node_46.gateTo[50] <--> Channel <--> node_50.gateTo[46];
        node_47.gateTo[5] <--> Channel <--> node_05.gateTo[47];
        node_47.gateTo[6] <--> Channel <--> node_06.gateTo[47];
        node_47.gateTo[7] <--> Channel <--> node_07.gateTo[47];
        node_47.gateTo[48] <--> Channel <--> node_48.gateTo[47];
        node_47.gateTo[50] <--> Channel <--> node_50.gateTo[47];
        node_48.gateTo[5] <--> Channel <--> node_05.gateTo[48];
        node_48.gateTo[6] <--> Channel <--> node_06.gateTo[48];
        node_48.gateTo[7] <--> Channel <--> node_07.gateTo[48];
        node_48.gateTo[50] <--> Channel <--> node_50.gateTo[48];
        node_05.gateTo[6] <--> Channel <--> node_06.gateTo[5];
        node_05.gateTo[7] <--> Channel <--> node_07.gateTo[5];
        node_05.gateTo[50] <--> Channel <--> node_50.gateTo[5];
        node_50.gateTo[6] <--> Channel <--> node_06.gateTo[50];
        node_50.gateTo[7] <--> Channel <--> node_07.gateTo[50];
        node_06.gateTo[7] <--> Channel <--> node_07.gateTo[6];

        //TODO delete these connetions - testing purposes only
}
