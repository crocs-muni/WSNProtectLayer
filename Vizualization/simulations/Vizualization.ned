package vizualization.simulations;

import ned.DelayChannel;
import vizualization.*;

//
// A generated network with grid topology.
//
network Vizualization
{
    //TODO namerene hodnoty rssi od Dusana/Martina obsahovaly uzly 4, 12 a 13.. kde jsou?
    @display("bgb=2251,656;bgi=custom/lab_gotex_grey");

    types:
        channel Channel extends ned.DelayChannel
        {
            @display("ls=black,0,do");
        }

    submodules:
        inject: Injector {
            @display("i=custom/spacer");
        }

//        attacker: Attacker {
//            @display("p=1820,622");
//        }

        node_4: Node {
            @display("p=1511,108");

        }
        node_5: Node {
            @display("p=2031,421");

        }
        node_6: Node {
            @display("p=2056,89");

        }
        node_7: Node {
            @display("p=493,41");

        }
        node_10: Node {
            @display("p=2169,80");

        }
        node_14: Node {
            @display("p=208,41");

        }
        node_15: Node {
            @display("p=94,201");

        }
        node_17: Node {
            @display("p=285,201");

        }
        node_19: Node {
            @display("p=1746,41");

        }
        node_22: Node {
            @display("p=1504,306");

        }
        node_25: Node {
            @display("p=1903,108");

        }
        node_28: Node {
            @display("p=1380,69");

        }
        node_29: Node {
            @display("p=2169,228");

        }
        node_30: Node {
            @display("p=1523,528");

        }
        node_31: Node {
            @display("p=1631,210");

        }
        node_32: Node {
            @display("p=2169,470");

        }
        node_33: Node {
            @display("p=1106,201");

        }
        node_35: Node {
            @display("p=1631,345");

        }
        node_36: Node {
            @display("p=1891,528");

        }
        node_37: Node {
            @display("p=708,228");

        }
        node_40: Node {
            @display("p=1891,352");

        }
        node_41: Node {
            @display("p=1238,228");

        }
        node_42: Node {
            @display("p=1737,352");

        }
        node_43: Node {
            @display("p=48,30");

        }
        node_44: Node {
            @display("p=1782,178");

        }
        node_46: Node {
            @display("p=1045,50");

        }
        node_47: Node {
            @display("p=830,41");

        }
        node_48: Node {
            @display("p=813,210");

        }
        node_50: Node {
            @display("p=2019,162");

        }

    connections:
        node_4.gateTo[5] <--> Channel <--> node_5.gateTo[4];
        node_4.gateTo[6] <--> Channel <--> node_6.gateTo[4];
        node_4.gateTo[7] <--> Channel <--> node_7.gateTo[4];
        node_4.gateTo[10] <--> Channel <--> node_10.gateTo[4];
        node_4.gateTo[14] <--> Channel <--> node_14.gateTo[4];
        node_4.gateTo[15] <--> Channel <--> node_15.gateTo[4];
        node_4.gateTo[17] <--> Channel <--> node_17.gateTo[4];
        node_4.gateTo[19] <--> Channel <--> node_19.gateTo[4];
        node_4.gateTo[22] <--> Channel <--> node_22.gateTo[4];
        node_4.gateTo[25] <--> Channel <--> node_25.gateTo[4];
        node_4.gateTo[28] <--> Channel <--> node_28.gateTo[4];
        node_4.gateTo[29] <--> Channel <--> node_29.gateTo[4];
        node_4.gateTo[30] <--> Channel <--> node_30.gateTo[4];
        node_4.gateTo[31] <--> Channel <--> node_31.gateTo[4];
        node_4.gateTo[32] <--> Channel <--> node_32.gateTo[4];
        node_4.gateTo[33] <--> Channel <--> node_33.gateTo[4];
        node_4.gateTo[35] <--> Channel <--> node_35.gateTo[4];
        node_4.gateTo[36] <--> Channel <--> node_36.gateTo[4];
        node_4.gateTo[37] <--> Channel <--> node_37.gateTo[4];
        node_4.gateTo[40] <--> Channel <--> node_40.gateTo[4];
        node_4.gateTo[41] <--> Channel <--> node_41.gateTo[4];
        node_4.gateTo[42] <--> Channel <--> node_42.gateTo[4];
        node_4.gateTo[43] <--> Channel <--> node_43.gateTo[4];
        node_4.gateTo[44] <--> Channel <--> node_44.gateTo[4];
        node_4.gateTo[46] <--> Channel <--> node_46.gateTo[4];
        node_4.gateTo[47] <--> Channel <--> node_47.gateTo[4];
        node_4.gateTo[48] <--> Channel <--> node_48.gateTo[4];
        node_4.gateTo[50] <--> Channel <--> node_50.gateTo[4];
        node_5.gateTo[6] <--> Channel <--> node_6.gateTo[5];
        node_5.gateTo[7] <--> Channel <--> node_7.gateTo[5];
        node_5.gateTo[10] <--> Channel <--> node_10.gateTo[5];
        node_5.gateTo[14] <--> Channel <--> node_14.gateTo[5];
        node_5.gateTo[15] <--> Channel <--> node_15.gateTo[5];
        node_5.gateTo[17] <--> Channel <--> node_17.gateTo[5];
        node_5.gateTo[19] <--> Channel <--> node_19.gateTo[5];
        node_5.gateTo[22] <--> Channel <--> node_22.gateTo[5];
        node_5.gateTo[25] <--> Channel <--> node_25.gateTo[5];
        node_5.gateTo[28] <--> Channel <--> node_28.gateTo[5];
        node_5.gateTo[29] <--> Channel <--> node_29.gateTo[5];
        node_5.gateTo[30] <--> Channel <--> node_30.gateTo[5];
        node_5.gateTo[31] <--> Channel <--> node_31.gateTo[5];
        node_5.gateTo[32] <--> Channel <--> node_32.gateTo[5];
        node_5.gateTo[33] <--> Channel <--> node_33.gateTo[5];
        node_5.gateTo[35] <--> Channel <--> node_35.gateTo[5];
        node_5.gateTo[36] <--> Channel <--> node_36.gateTo[5];
        node_5.gateTo[37] <--> Channel <--> node_37.gateTo[5];
        node_5.gateTo[40] <--> Channel <--> node_40.gateTo[5];
        node_5.gateTo[41] <--> Channel <--> node_41.gateTo[5];
        node_5.gateTo[42] <--> Channel <--> node_42.gateTo[5];
        node_5.gateTo[43] <--> Channel <--> node_43.gateTo[5];
        node_5.gateTo[44] <--> Channel <--> node_44.gateTo[5];
        node_5.gateTo[46] <--> Channel <--> node_46.gateTo[5];
        node_5.gateTo[47] <--> Channel <--> node_47.gateTo[5];
        node_5.gateTo[48] <--> Channel <--> node_48.gateTo[5];
        node_5.gateTo[50] <--> Channel <--> node_50.gateTo[5];
        node_6.gateTo[7] <--> Channel <--> node_7.gateTo[6];
        node_6.gateTo[10] <--> Channel <--> node_10.gateTo[6];
        node_6.gateTo[14] <--> Channel <--> node_14.gateTo[6];
        node_6.gateTo[15] <--> Channel <--> node_15.gateTo[6];
        node_6.gateTo[17] <--> Channel <--> node_17.gateTo[6];
        node_6.gateTo[19] <--> Channel <--> node_19.gateTo[6];
        node_6.gateTo[22] <--> Channel <--> node_22.gateTo[6];
        node_6.gateTo[25] <--> Channel <--> node_25.gateTo[6];
        node_6.gateTo[28] <--> Channel <--> node_28.gateTo[6];
        node_6.gateTo[29] <--> Channel <--> node_29.gateTo[6];
        node_6.gateTo[30] <--> Channel <--> node_30.gateTo[6];
        node_6.gateTo[31] <--> Channel <--> node_31.gateTo[6];
        node_6.gateTo[32] <--> Channel <--> node_32.gateTo[6];
        node_6.gateTo[33] <--> Channel <--> node_33.gateTo[6];
        node_6.gateTo[35] <--> Channel <--> node_35.gateTo[6];
        node_6.gateTo[36] <--> Channel <--> node_36.gateTo[6];
        node_6.gateTo[37] <--> Channel <--> node_37.gateTo[6];
        node_6.gateTo[40] <--> Channel <--> node_40.gateTo[6];
        node_6.gateTo[41] <--> Channel <--> node_41.gateTo[6];
        node_6.gateTo[42] <--> Channel <--> node_42.gateTo[6];
        node_6.gateTo[43] <--> Channel <--> node_43.gateTo[6];
        node_6.gateTo[44] <--> Channel <--> node_44.gateTo[6];
        node_6.gateTo[46] <--> Channel <--> node_46.gateTo[6];
        node_6.gateTo[47] <--> Channel <--> node_47.gateTo[6];
        node_6.gateTo[48] <--> Channel <--> node_48.gateTo[6];
        node_6.gateTo[50] <--> Channel <--> node_50.gateTo[6];
        node_7.gateTo[10] <--> Channel <--> node_10.gateTo[7];
        node_7.gateTo[14] <--> Channel <--> node_14.gateTo[7];
        node_7.gateTo[15] <--> Channel <--> node_15.gateTo[7];
        node_7.gateTo[17] <--> Channel <--> node_17.gateTo[7];
        node_7.gateTo[19] <--> Channel <--> node_19.gateTo[7];
        node_7.gateTo[22] <--> Channel <--> node_22.gateTo[7];
        node_7.gateTo[25] <--> Channel <--> node_25.gateTo[7];
        node_7.gateTo[28] <--> Channel <--> node_28.gateTo[7];
        node_7.gateTo[29] <--> Channel <--> node_29.gateTo[7];
        node_7.gateTo[30] <--> Channel <--> node_30.gateTo[7];
        node_7.gateTo[31] <--> Channel <--> node_31.gateTo[7];
        node_7.gateTo[32] <--> Channel <--> node_32.gateTo[7];
        node_7.gateTo[33] <--> Channel <--> node_33.gateTo[7];
        node_7.gateTo[35] <--> Channel <--> node_35.gateTo[7];
        node_7.gateTo[36] <--> Channel <--> node_36.gateTo[7];
        node_7.gateTo[37] <--> Channel <--> node_37.gateTo[7];
        node_7.gateTo[40] <--> Channel <--> node_40.gateTo[7];
        node_7.gateTo[41] <--> Channel <--> node_41.gateTo[7];
        node_7.gateTo[42] <--> Channel <--> node_42.gateTo[7];
        node_7.gateTo[43] <--> Channel <--> node_43.gateTo[7];
        node_7.gateTo[44] <--> Channel <--> node_44.gateTo[7];
        node_7.gateTo[46] <--> Channel <--> node_46.gateTo[7];
        node_7.gateTo[47] <--> Channel <--> node_47.gateTo[7];
        node_7.gateTo[48] <--> Channel <--> node_48.gateTo[7];
        node_7.gateTo[50] <--> Channel <--> node_50.gateTo[7];
        node_10.gateTo[14] <--> Channel <--> node_14.gateTo[10];
        node_10.gateTo[15] <--> Channel <--> node_15.gateTo[10];
        node_10.gateTo[17] <--> Channel <--> node_17.gateTo[10];
        node_10.gateTo[19] <--> Channel <--> node_19.gateTo[10];
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
        node_10.gateTo[40] <--> Channel <--> node_40.gateTo[10];
        node_10.gateTo[41] <--> Channel <--> node_41.gateTo[10];
        node_10.gateTo[42] <--> Channel <--> node_42.gateTo[10];
        node_10.gateTo[43] <--> Channel <--> node_43.gateTo[10];
        node_10.gateTo[44] <--> Channel <--> node_44.gateTo[10];
        node_10.gateTo[46] <--> Channel <--> node_46.gateTo[10];
        node_10.gateTo[47] <--> Channel <--> node_47.gateTo[10];
        node_10.gateTo[48] <--> Channel <--> node_48.gateTo[10];
        node_10.gateTo[50] <--> Channel <--> node_50.gateTo[10];
        node_14.gateTo[15] <--> Channel <--> node_15.gateTo[14];
        node_14.gateTo[17] <--> Channel <--> node_17.gateTo[14];
        node_14.gateTo[19] <--> Channel <--> node_19.gateTo[14];
        node_14.gateTo[22] <--> Channel <--> node_22.gateTo[14];
        node_14.gateTo[25] <--> Channel <--> node_25.gateTo[14];
        node_14.gateTo[28] <--> Channel <--> node_28.gateTo[14];
        node_14.gateTo[29] <--> Channel <--> node_29.gateTo[14];
        node_14.gateTo[30] <--> Channel <--> node_30.gateTo[14];
        node_14.gateTo[31] <--> Channel <--> node_31.gateTo[14];
        node_14.gateTo[32] <--> Channel <--> node_32.gateTo[14];
        node_14.gateTo[33] <--> Channel <--> node_33.gateTo[14];
        node_14.gateTo[35] <--> Channel <--> node_35.gateTo[14];
        node_14.gateTo[36] <--> Channel <--> node_36.gateTo[14];
        node_14.gateTo[37] <--> Channel <--> node_37.gateTo[14];
        node_14.gateTo[40] <--> Channel <--> node_40.gateTo[14];
        node_14.gateTo[41] <--> Channel <--> node_41.gateTo[14];
        node_14.gateTo[42] <--> Channel <--> node_42.gateTo[14];
        node_14.gateTo[43] <--> Channel <--> node_43.gateTo[14];
        node_14.gateTo[44] <--> Channel <--> node_44.gateTo[14];
        node_14.gateTo[46] <--> Channel <--> node_46.gateTo[14];
        node_14.gateTo[47] <--> Channel <--> node_47.gateTo[14];
        node_14.gateTo[48] <--> Channel <--> node_48.gateTo[14];
        node_14.gateTo[50] <--> Channel <--> node_50.gateTo[14];
        node_15.gateTo[17] <--> Channel <--> node_17.gateTo[15];
        node_15.gateTo[19] <--> Channel <--> node_19.gateTo[15];
        node_15.gateTo[22] <--> Channel <--> node_22.gateTo[15];
        node_15.gateTo[25] <--> Channel <--> node_25.gateTo[15];
        node_15.gateTo[28] <--> Channel <--> node_28.gateTo[15];
        node_15.gateTo[29] <--> Channel <--> node_29.gateTo[15];
        node_15.gateTo[30] <--> Channel <--> node_30.gateTo[15];
        node_15.gateTo[31] <--> Channel <--> node_31.gateTo[15];
        node_15.gateTo[32] <--> Channel <--> node_32.gateTo[15];
        node_15.gateTo[33] <--> Channel <--> node_33.gateTo[15];
        node_15.gateTo[35] <--> Channel <--> node_35.gateTo[15];
        node_15.gateTo[36] <--> Channel <--> node_36.gateTo[15];
        node_15.gateTo[37] <--> Channel <--> node_37.gateTo[15];
        node_15.gateTo[40] <--> Channel <--> node_40.gateTo[15];
        node_15.gateTo[41] <--> Channel <--> node_41.gateTo[15];
        node_15.gateTo[42] <--> Channel <--> node_42.gateTo[15];
        node_15.gateTo[43] <--> Channel <--> node_43.gateTo[15];
        node_15.gateTo[44] <--> Channel <--> node_44.gateTo[15];
        node_15.gateTo[46] <--> Channel <--> node_46.gateTo[15];
        node_15.gateTo[47] <--> Channel <--> node_47.gateTo[15];
        node_15.gateTo[48] <--> Channel <--> node_48.gateTo[15];
        node_15.gateTo[50] <--> Channel <--> node_50.gateTo[15];
        node_17.gateTo[19] <--> Channel <--> node_19.gateTo[17];
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
        node_17.gateTo[40] <--> Channel <--> node_40.gateTo[17];
        node_17.gateTo[41] <--> Channel <--> node_41.gateTo[17];
        node_17.gateTo[42] <--> Channel <--> node_42.gateTo[17];
        node_17.gateTo[43] <--> Channel <--> node_43.gateTo[17];
        node_17.gateTo[44] <--> Channel <--> node_44.gateTo[17];
        node_17.gateTo[46] <--> Channel <--> node_46.gateTo[17];
        node_17.gateTo[47] <--> Channel <--> node_47.gateTo[17];
        node_17.gateTo[48] <--> Channel <--> node_48.gateTo[17];
        node_17.gateTo[50] <--> Channel <--> node_50.gateTo[17];
        node_19.gateTo[22] <--> Channel <--> node_22.gateTo[19];
        node_19.gateTo[25] <--> Channel <--> node_25.gateTo[19];
        node_19.gateTo[28] <--> Channel <--> node_28.gateTo[19];
        node_19.gateTo[29] <--> Channel <--> node_29.gateTo[19];
        node_19.gateTo[30] <--> Channel <--> node_30.gateTo[19];
        node_19.gateTo[31] <--> Channel <--> node_31.gateTo[19];
        node_19.gateTo[32] <--> Channel <--> node_32.gateTo[19];
        node_19.gateTo[33] <--> Channel <--> node_33.gateTo[19];
        node_19.gateTo[35] <--> Channel <--> node_35.gateTo[19];
        node_19.gateTo[36] <--> Channel <--> node_36.gateTo[19];
        node_19.gateTo[37] <--> Channel <--> node_37.gateTo[19];
        node_19.gateTo[40] <--> Channel <--> node_40.gateTo[19];
        node_19.gateTo[41] <--> Channel <--> node_41.gateTo[19];
        node_19.gateTo[42] <--> Channel <--> node_42.gateTo[19];
        node_19.gateTo[43] <--> Channel <--> node_43.gateTo[19];
        node_19.gateTo[44] <--> Channel <--> node_44.gateTo[19];
        node_19.gateTo[46] <--> Channel <--> node_46.gateTo[19];
        node_19.gateTo[47] <--> Channel <--> node_47.gateTo[19];
        node_19.gateTo[48] <--> Channel <--> node_48.gateTo[19];
        node_19.gateTo[50] <--> Channel <--> node_50.gateTo[19];
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
        node_25.gateTo[28] <--> Channel <--> node_28.gateTo[25];
        node_25.gateTo[29] <--> Channel <--> node_29.gateTo[25];
        node_25.gateTo[30] <--> Channel <--> node_30.gateTo[25];
        node_25.gateTo[31] <--> Channel <--> node_31.gateTo[25];
        node_25.gateTo[32] <--> Channel <--> node_32.gateTo[25];
        node_25.gateTo[33] <--> Channel <--> node_33.gateTo[25];
        node_25.gateTo[35] <--> Channel <--> node_35.gateTo[25];
        node_25.gateTo[36] <--> Channel <--> node_36.gateTo[25];
        node_25.gateTo[37] <--> Channel <--> node_37.gateTo[25];
        node_25.gateTo[40] <--> Channel <--> node_40.gateTo[25];
        node_25.gateTo[41] <--> Channel <--> node_41.gateTo[25];
        node_25.gateTo[42] <--> Channel <--> node_42.gateTo[25];
        node_25.gateTo[43] <--> Channel <--> node_43.gateTo[25];
        node_25.gateTo[44] <--> Channel <--> node_44.gateTo[25];
        node_25.gateTo[46] <--> Channel <--> node_46.gateTo[25];
        node_25.gateTo[47] <--> Channel <--> node_47.gateTo[25];
        node_25.gateTo[48] <--> Channel <--> node_48.gateTo[25];
        node_25.gateTo[50] <--> Channel <--> node_50.gateTo[25];
        node_28.gateTo[29] <--> Channel <--> node_29.gateTo[28];
        node_28.gateTo[30] <--> Channel <--> node_30.gateTo[28];
        node_28.gateTo[31] <--> Channel <--> node_31.gateTo[28];
        node_28.gateTo[32] <--> Channel <--> node_32.gateTo[28];
        node_28.gateTo[33] <--> Channel <--> node_33.gateTo[28];
        node_28.gateTo[35] <--> Channel <--> node_35.gateTo[28];
        node_28.gateTo[36] <--> Channel <--> node_36.gateTo[28];
        node_28.gateTo[37] <--> Channel <--> node_37.gateTo[28];
        node_28.gateTo[40] <--> Channel <--> node_40.gateTo[28];
        node_28.gateTo[41] <--> Channel <--> node_41.gateTo[28];
        node_28.gateTo[42] <--> Channel <--> node_42.gateTo[28];
        node_28.gateTo[43] <--> Channel <--> node_43.gateTo[28];
        node_28.gateTo[44] <--> Channel <--> node_44.gateTo[28];
        node_28.gateTo[46] <--> Channel <--> node_46.gateTo[28];
        node_28.gateTo[47] <--> Channel <--> node_47.gateTo[28];
        node_28.gateTo[48] <--> Channel <--> node_48.gateTo[28];
        node_28.gateTo[50] <--> Channel <--> node_50.gateTo[28];
        node_29.gateTo[30] <--> Channel <--> node_30.gateTo[29];
        node_29.gateTo[31] <--> Channel <--> node_31.gateTo[29];
        node_29.gateTo[32] <--> Channel <--> node_32.gateTo[29];
        node_29.gateTo[33] <--> Channel <--> node_33.gateTo[29];
        node_29.gateTo[35] <--> Channel <--> node_35.gateTo[29];
        node_29.gateTo[36] <--> Channel <--> node_36.gateTo[29];
        node_29.gateTo[37] <--> Channel <--> node_37.gateTo[29];
        node_29.gateTo[40] <--> Channel <--> node_40.gateTo[29];
        node_29.gateTo[41] <--> Channel <--> node_41.gateTo[29];
        node_29.gateTo[42] <--> Channel <--> node_42.gateTo[29];
        node_29.gateTo[43] <--> Channel <--> node_43.gateTo[29];
        node_29.gateTo[44] <--> Channel <--> node_44.gateTo[29];
        node_29.gateTo[46] <--> Channel <--> node_46.gateTo[29];
        node_29.gateTo[47] <--> Channel <--> node_47.gateTo[29];
        node_29.gateTo[48] <--> Channel <--> node_48.gateTo[29];
        node_29.gateTo[50] <--> Channel <--> node_50.gateTo[29];
        node_30.gateTo[31] <--> Channel <--> node_31.gateTo[30];
        node_30.gateTo[32] <--> Channel <--> node_32.gateTo[30];
        node_30.gateTo[33] <--> Channel <--> node_33.gateTo[30];
        node_30.gateTo[35] <--> Channel <--> node_35.gateTo[30];
        node_30.gateTo[36] <--> Channel <--> node_36.gateTo[30];
        node_30.gateTo[37] <--> Channel <--> node_37.gateTo[30];
        node_30.gateTo[40] <--> Channel <--> node_40.gateTo[30];
        node_30.gateTo[41] <--> Channel <--> node_41.gateTo[30];
        node_30.gateTo[42] <--> Channel <--> node_42.gateTo[30];
        node_30.gateTo[43] <--> Channel <--> node_43.gateTo[30];
        node_30.gateTo[44] <--> Channel <--> node_44.gateTo[30];
        node_30.gateTo[46] <--> Channel <--> node_46.gateTo[30];
        node_30.gateTo[47] <--> Channel <--> node_47.gateTo[30];
        node_30.gateTo[48] <--> Channel <--> node_48.gateTo[30];
        node_30.gateTo[50] <--> Channel <--> node_50.gateTo[30];
        node_31.gateTo[32] <--> Channel <--> node_32.gateTo[31];
        node_31.gateTo[33] <--> Channel <--> node_33.gateTo[31];
        node_31.gateTo[35] <--> Channel <--> node_35.gateTo[31];
        node_31.gateTo[36] <--> Channel <--> node_36.gateTo[31];
        node_31.gateTo[37] <--> Channel <--> node_37.gateTo[31];
        node_31.gateTo[40] <--> Channel <--> node_40.gateTo[31];
        node_31.gateTo[41] <--> Channel <--> node_41.gateTo[31];
        node_31.gateTo[42] <--> Channel <--> node_42.gateTo[31];
        node_31.gateTo[43] <--> Channel <--> node_43.gateTo[31];
        node_31.gateTo[44] <--> Channel <--> node_44.gateTo[31];
        node_31.gateTo[46] <--> Channel <--> node_46.gateTo[31];
        node_31.gateTo[47] <--> Channel <--> node_47.gateTo[31];
        node_31.gateTo[48] <--> Channel <--> node_48.gateTo[31];
        node_31.gateTo[50] <--> Channel <--> node_50.gateTo[31];
        node_32.gateTo[33] <--> Channel <--> node_33.gateTo[32];
        node_32.gateTo[35] <--> Channel <--> node_35.gateTo[32];
        node_32.gateTo[36] <--> Channel <--> node_36.gateTo[32];
        node_32.gateTo[37] <--> Channel <--> node_37.gateTo[32];
        node_32.gateTo[40] <--> Channel <--> node_40.gateTo[32];
        node_32.gateTo[41] <--> Channel <--> node_41.gateTo[32];
        node_32.gateTo[42] <--> Channel <--> node_42.gateTo[32];
        node_32.gateTo[43] <--> Channel <--> node_43.gateTo[32];
        node_32.gateTo[44] <--> Channel <--> node_44.gateTo[32];
        node_32.gateTo[46] <--> Channel <--> node_46.gateTo[32];
        node_32.gateTo[47] <--> Channel <--> node_47.gateTo[32];
        node_32.gateTo[48] <--> Channel <--> node_48.gateTo[32];
        node_32.gateTo[50] <--> Channel <--> node_50.gateTo[32];
        node_33.gateTo[35] <--> Channel <--> node_35.gateTo[33];
        node_33.gateTo[36] <--> Channel <--> node_36.gateTo[33];
        node_33.gateTo[37] <--> Channel <--> node_37.gateTo[33];
        node_33.gateTo[40] <--> Channel <--> node_40.gateTo[33];
        node_33.gateTo[41] <--> Channel <--> node_41.gateTo[33];
        node_33.gateTo[42] <--> Channel <--> node_42.gateTo[33];
        node_33.gateTo[43] <--> Channel <--> node_43.gateTo[33];
        node_33.gateTo[44] <--> Channel <--> node_44.gateTo[33];
        node_33.gateTo[46] <--> Channel <--> node_46.gateTo[33];
        node_33.gateTo[47] <--> Channel <--> node_47.gateTo[33];
        node_33.gateTo[48] <--> Channel <--> node_48.gateTo[33];
        node_33.gateTo[50] <--> Channel <--> node_50.gateTo[33];
        node_35.gateTo[36] <--> Channel <--> node_36.gateTo[35];
        node_35.gateTo[37] <--> Channel <--> node_37.gateTo[35];
        node_35.gateTo[40] <--> Channel <--> node_40.gateTo[35];
        node_35.gateTo[41] <--> Channel <--> node_41.gateTo[35];
        node_35.gateTo[42] <--> Channel <--> node_42.gateTo[35];
        node_35.gateTo[43] <--> Channel <--> node_43.gateTo[35];
        node_35.gateTo[44] <--> Channel <--> node_44.gateTo[35];
        node_35.gateTo[46] <--> Channel <--> node_46.gateTo[35];
        node_35.gateTo[47] <--> Channel <--> node_47.gateTo[35];
        node_35.gateTo[48] <--> Channel <--> node_48.gateTo[35];
        node_35.gateTo[50] <--> Channel <--> node_50.gateTo[35];
        node_36.gateTo[37] <--> Channel <--> node_37.gateTo[36];
        node_36.gateTo[40] <--> Channel <--> node_40.gateTo[36];
        node_36.gateTo[41] <--> Channel <--> node_41.gateTo[36];
        node_36.gateTo[42] <--> Channel <--> node_42.gateTo[36];
        node_36.gateTo[43] <--> Channel <--> node_43.gateTo[36];
        node_36.gateTo[44] <--> Channel <--> node_44.gateTo[36];
        node_36.gateTo[46] <--> Channel <--> node_46.gateTo[36];
        node_36.gateTo[47] <--> Channel <--> node_47.gateTo[36];
        node_36.gateTo[48] <--> Channel <--> node_48.gateTo[36];
        node_36.gateTo[50] <--> Channel <--> node_50.gateTo[36];
        node_37.gateTo[40] <--> Channel <--> node_40.gateTo[37];
        node_37.gateTo[41] <--> Channel <--> node_41.gateTo[37];
        node_37.gateTo[42] <--> Channel <--> node_42.gateTo[37];
        node_37.gateTo[43] <--> Channel <--> node_43.gateTo[37];
        node_37.gateTo[44] <--> Channel <--> node_44.gateTo[37];
        node_37.gateTo[46] <--> Channel <--> node_46.gateTo[37];
        node_37.gateTo[47] <--> Channel <--> node_47.gateTo[37];
        node_37.gateTo[48] <--> Channel <--> node_48.gateTo[37];
        node_37.gateTo[50] <--> Channel <--> node_50.gateTo[37];
        node_40.gateTo[41] <--> Channel <--> node_41.gateTo[40];
        node_40.gateTo[42] <--> Channel <--> node_42.gateTo[40];
        node_40.gateTo[43] <--> Channel <--> node_43.gateTo[40];
        node_40.gateTo[44] <--> Channel <--> node_44.gateTo[40];
        node_40.gateTo[46] <--> Channel <--> node_46.gateTo[40];
        node_40.gateTo[47] <--> Channel <--> node_47.gateTo[40];
        node_40.gateTo[48] <--> Channel <--> node_48.gateTo[40];
        node_40.gateTo[50] <--> Channel <--> node_50.gateTo[40];
        node_41.gateTo[42] <--> Channel <--> node_42.gateTo[41];
        node_41.gateTo[43] <--> Channel <--> node_43.gateTo[41];
        node_41.gateTo[44] <--> Channel <--> node_44.gateTo[41];
        node_41.gateTo[46] <--> Channel <--> node_46.gateTo[41];
        node_41.gateTo[47] <--> Channel <--> node_47.gateTo[41];
        node_41.gateTo[48] <--> Channel <--> node_48.gateTo[41];
        node_41.gateTo[50] <--> Channel <--> node_50.gateTo[41];
        node_42.gateTo[43] <--> Channel <--> node_43.gateTo[42];
        node_42.gateTo[44] <--> Channel <--> node_44.gateTo[42];
        node_42.gateTo[46] <--> Channel <--> node_46.gateTo[42];
        node_42.gateTo[47] <--> Channel <--> node_47.gateTo[42];
        node_42.gateTo[48] <--> Channel <--> node_48.gateTo[42];
        node_42.gateTo[50] <--> Channel <--> node_50.gateTo[42];
        node_43.gateTo[44] <--> Channel <--> node_44.gateTo[43];
        node_43.gateTo[46] <--> Channel <--> node_46.gateTo[43];
        node_43.gateTo[47] <--> Channel <--> node_47.gateTo[43];
        node_43.gateTo[48] <--> Channel <--> node_48.gateTo[43];
        node_43.gateTo[50] <--> Channel <--> node_50.gateTo[43];
        node_44.gateTo[46] <--> Channel <--> node_46.gateTo[44];
        node_44.gateTo[47] <--> Channel <--> node_47.gateTo[44];
        node_44.gateTo[48] <--> Channel <--> node_48.gateTo[44];
        node_44.gateTo[50] <--> Channel <--> node_50.gateTo[44];
        node_46.gateTo[47] <--> Channel <--> node_47.gateTo[46];
        node_46.gateTo[48] <--> Channel <--> node_48.gateTo[46];
        node_46.gateTo[50] <--> Channel <--> node_50.gateTo[46];
        node_47.gateTo[48] <--> Channel <--> node_48.gateTo[47];
        node_47.gateTo[50] <--> Channel <--> node_50.gateTo[47];
        node_48.gateTo[50] <--> Channel <--> node_50.gateTo[48];


//        connections out of earlier experiments:
//        node_4.gateTo[19] <--> Channel <--> node_19.gateTo[4];
//        node_4.gateTo[28] <--> Channel <--> node_28.gateTo[4];
//        node_4.gateTo[41] <--> Channel <--> node_41.gateTo[4];
//        node_10.gateTo[5] <--> Channel <--> node_5.gateTo[10];
//        node_10.gateTo[6] <--> Channel <--> node_6.gateTo[10];
//        node_10.gateTo[7] <--> Channel <--> node_7.gateTo[10];
//        node_10.gateTo[14] <--> Channel <--> node_14.gateTo[10];
//        node_10.gateTo[17] <--> Channel <--> node_17.gateTo[10];
//        node_10.gateTo[22] <--> Channel <--> node_22.gateTo[10];
//        node_10.gateTo[25] <--> Channel <--> node_25.gateTo[10];
//        node_10.gateTo[28] <--> Channel <--> node_28.gateTo[10];
//        node_10.gateTo[29] <--> Channel <--> node_29.gateTo[10];
//        node_10.gateTo[30] <--> Channel <--> node_30.gateTo[10];
//        node_10.gateTo[31] <--> Channel <--> node_31.gateTo[10];
//        node_10.gateTo[32] <--> Channel <--> node_32.gateTo[10];
//        node_10.gateTo[33] <--> Channel <--> node_33.gateTo[10];
//        node_10.gateTo[35] <--> Channel <--> node_35.gateTo[10];
//        node_10.gateTo[36] <--> Channel <--> node_36.gateTo[10];
//        node_10.gateTo[37] <--> Channel <--> node_37.gateTo[10];
//        node_10.gateTo[41] <--> Channel <--> node_41.gateTo[10];
//        node_10.gateTo[42] <--> Channel <--> node_42.gateTo[10];
//        node_10.gateTo[43] <--> Channel <--> node_43.gateTo[10];
//        node_10.gateTo[44] <--> Channel <--> node_44.gateTo[10];
//        node_10.gateTo[46] <--> Channel <--> node_46.gateTo[10];
//        node_10.gateTo[47] <--> Channel <--> node_47.gateTo[10];
//        node_10.gateTo[48] <--> Channel <--> node_48.gateTo[10];
//        node_10.gateTo[50] <--> Channel <--> node_50.gateTo[10];
//        node_14.gateTo[5] <--> Channel <--> node_5.gateTo[14];
//        node_14.gateTo[6] <--> Channel <--> node_6.gateTo[14];
//        node_14.gateTo[7] <--> Channel <--> node_7.gateTo[14];
//        node_14.gateTo[15] <--> Channel <--> node_15.gateTo[14];
//        node_14.gateTo[17] <--> Channel <--> node_17.gateTo[14];
//        node_14.gateTo[22] <--> Channel <--> node_22.gateTo[14];
//        node_14.gateTo[25] <--> Channel <--> node_25.gateTo[14];
//        node_14.gateTo[28] <--> Channel <--> node_28.gateTo[14];
//        node_14.gateTo[29] <--> Channel <--> node_29.gateTo[14];
//        node_14.gateTo[30] <--> Channel <--> node_30.gateTo[14];
//        node_14.gateTo[31] <--> Channel <--> node_31.gateTo[14];
//        node_14.gateTo[33] <--> Channel <--> node_33.gateTo[14];
//        node_14.gateTo[35] <--> Channel <--> node_35.gateTo[14];
//        node_14.gateTo[36] <--> Channel <--> node_36.gateTo[14];
//        node_14.gateTo[37] <--> Channel <--> node_37.gateTo[14];
//        node_14.gateTo[41] <--> Channel <--> node_41.gateTo[14];
//        node_14.gateTo[42] <--> Channel <--> node_42.gateTo[14];
//        node_14.gateTo[43] <--> Channel <--> node_43.gateTo[14];
//        node_14.gateTo[44] <--> Channel <--> node_44.gateTo[14];
//        node_14.gateTo[46] <--> Channel <--> node_46.gateTo[14];
//        node_14.gateTo[47] <--> Channel <--> node_47.gateTo[14];
//        node_14.gateTo[48] <--> Channel <--> node_48.gateTo[14];
//        node_14.gateTo[50] <--> Channel <--> node_50.gateTo[14];
//        node_15.gateTo[5] <--> Channel <--> node_5.gateTo[15];
//        node_15.gateTo[6] <--> Channel <--> node_6.gateTo[15];
//        node_15.gateTo[7] <--> Channel <--> node_7.gateTo[15];
//        node_15.gateTo[10] <--> Channel <--> node_10.gateTo[15];
//        node_15.gateTo[17] <--> Channel <--> node_17.gateTo[15];
//        node_15.gateTo[22] <--> Channel <--> node_22.gateTo[15];
//        node_15.gateTo[25] <--> Channel <--> node_25.gateTo[15];
//        node_15.gateTo[28] <--> Channel <--> node_28.gateTo[15];
//        node_15.gateTo[29] <--> Channel <--> node_29.gateTo[15];
//        node_15.gateTo[30] <--> Channel <--> node_30.gateTo[15];
//        node_15.gateTo[31] <--> Channel <--> node_31.gateTo[15];
//        node_15.gateTo[33] <--> Channel <--> node_33.gateTo[15];
//        node_15.gateTo[35] <--> Channel <--> node_35.gateTo[15];
//        node_15.gateTo[36] <--> Channel <--> node_36.gateTo[15];
//        node_15.gateTo[37] <--> Channel <--> node_37.gateTo[15];
//        node_15.gateTo[41] <--> Channel <--> node_41.gateTo[15];
//        node_15.gateTo[42] <--> Channel <--> node_42.gateTo[15];
//        node_15.gateTo[43] <--> Channel <--> node_43.gateTo[15];
//        node_15.gateTo[44] <--> Channel <--> node_44.gateTo[15];
//        node_15.gateTo[46] <--> Channel <--> node_46.gateTo[15];
//        node_15.gateTo[47] <--> Channel <--> node_47.gateTo[15];
//        node_15.gateTo[48] <--> Channel <--> node_48.gateTo[15];
//        node_15.gateTo[50] <--> Channel <--> node_50.gateTo[15];
//        node_17.gateTo[5] <--> Channel <--> node_5.gateTo[17];
//        node_17.gateTo[6] <--> Channel <--> node_6.gateTo[17];
//        node_17.gateTo[7] <--> Channel <--> node_7.gateTo[17];
//        node_17.gateTo[22] <--> Channel <--> node_22.gateTo[17];
//        node_17.gateTo[25] <--> Channel <--> node_25.gateTo[17];
//        node_17.gateTo[28] <--> Channel <--> node_28.gateTo[17];
//        node_17.gateTo[29] <--> Channel <--> node_29.gateTo[17];
//        node_17.gateTo[30] <--> Channel <--> node_30.gateTo[17];
//        node_17.gateTo[31] <--> Channel <--> node_31.gateTo[17];
//        node_17.gateTo[32] <--> Channel <--> node_32.gateTo[17];
//        node_17.gateTo[33] <--> Channel <--> node_33.gateTo[17];
//        node_17.gateTo[35] <--> Channel <--> node_35.gateTo[17];
//        node_17.gateTo[36] <--> Channel <--> node_36.gateTo[17];
//        node_17.gateTo[37] <--> Channel <--> node_37.gateTo[17];
//        node_17.gateTo[41] <--> Channel <--> node_41.gateTo[17];
//        node_17.gateTo[42] <--> Channel <--> node_42.gateTo[17];
//        node_17.gateTo[43] <--> Channel <--> node_43.gateTo[17];
//        node_17.gateTo[44] <--> Channel <--> node_44.gateTo[17];
//        node_17.gateTo[46] <--> Channel <--> node_46.gateTo[17];
//        node_17.gateTo[47] <--> Channel <--> node_47.gateTo[17];
//        node_17.gateTo[48] <--> Channel <--> node_48.gateTo[17];
//        node_17.gateTo[50] <--> Channel <--> node_50.gateTo[17];
//        node_22.gateTo[5] <--> Channel <--> node_5.gateTo[22];
//        node_22.gateTo[6] <--> Channel <--> node_6.gateTo[22];
//        node_22.gateTo[7] <--> Channel <--> node_7.gateTo[22];
//        node_22.gateTo[25] <--> Channel <--> node_25.gateTo[22];
//        node_22.gateTo[28] <--> Channel <--> node_28.gateTo[22];
//        node_22.gateTo[29] <--> Channel <--> node_29.gateTo[22];
//        node_22.gateTo[30] <--> Channel <--> node_30.gateTo[22];
//        node_22.gateTo[31] <--> Channel <--> node_31.gateTo[22];
//        node_22.gateTo[32] <--> Channel <--> node_32.gateTo[22];
//        node_22.gateTo[33] <--> Channel <--> node_33.gateTo[22];
//        node_22.gateTo[35] <--> Channel <--> node_35.gateTo[22];
//        node_22.gateTo[36] <--> Channel <--> node_36.gateTo[22];
//        node_22.gateTo[37] <--> Channel <--> node_37.gateTo[22];
//        node_22.gateTo[41] <--> Channel <--> node_41.gateTo[22];
//        node_22.gateTo[42] <--> Channel <--> node_42.gateTo[22];
//        node_22.gateTo[43] <--> Channel <--> node_43.gateTo[22];
//        node_22.gateTo[44] <--> Channel <--> node_44.gateTo[22];
//        node_22.gateTo[46] <--> Channel <--> node_46.gateTo[22];
//        node_22.gateTo[47] <--> Channel <--> node_47.gateTo[22];
//        node_22.gateTo[48] <--> Channel <--> node_48.gateTo[22];
//        node_22.gateTo[50] <--> Channel <--> node_50.gateTo[22];
//        node_25.gateTo[5] <--> Channel <--> node_5.gateTo[25];
//        node_25.gateTo[6] <--> Channel <--> node_6.gateTo[25];
//        node_25.gateTo[7] <--> Channel <--> node_7.gateTo[25];
//        node_25.gateTo[28] <--> Channel <--> node_28.gateTo[25];
//        node_25.gateTo[29] <--> Channel <--> node_29.gateTo[25];
//        node_25.gateTo[30] <--> Channel <--> node_30.gateTo[25];
//        node_25.gateTo[31] <--> Channel <--> node_31.gateTo[25];
//        node_25.gateTo[32] <--> Channel <--> node_32.gateTo[25];
//        node_25.gateTo[33] <--> Channel <--> node_33.gateTo[25];
//        node_25.gateTo[35] <--> Channel <--> node_35.gateTo[25];
//        node_25.gateTo[36] <--> Channel <--> node_36.gateTo[25];
//        node_25.gateTo[37] <--> Channel <--> node_37.gateTo[25];
//        node_25.gateTo[41] <--> Channel <--> node_41.gateTo[25];
//        node_25.gateTo[42] <--> Channel <--> node_42.gateTo[25];
//        node_25.gateTo[43] <--> Channel <--> node_43.gateTo[25];
//        node_25.gateTo[44] <--> Channel <--> node_44.gateTo[25];
//        node_25.gateTo[46] <--> Channel <--> node_46.gateTo[25];
//        node_25.gateTo[47] <--> Channel <--> node_47.gateTo[25];
//        node_25.gateTo[48] <--> Channel <--> node_48.gateTo[25];
//        node_25.gateTo[50] <--> Channel <--> node_50.gateTo[25];
//        node_28.gateTo[5] <--> Channel <--> node_5.gateTo[28];
//        node_28.gateTo[6] <--> Channel <--> node_6.gateTo[28];
//        node_28.gateTo[7] <--> Channel <--> node_7.gateTo[28];
//        node_28.gateTo[29] <--> Channel <--> node_29.gateTo[28];
//        node_28.gateTo[30] <--> Channel <--> node_30.gateTo[28];
//        node_28.gateTo[31] <--> Channel <--> node_31.gateTo[28];
//        node_28.gateTo[32] <--> Channel <--> node_32.gateTo[28];
//        node_28.gateTo[33] <--> Channel <--> node_33.gateTo[28];
//        node_28.gateTo[35] <--> Channel <--> node_35.gateTo[28];
//        node_28.gateTo[36] <--> Channel <--> node_36.gateTo[28];
//        node_28.gateTo[37] <--> Channel <--> node_37.gateTo[28];
//        node_28.gateTo[41] <--> Channel <--> node_41.gateTo[28];
//        node_28.gateTo[42] <--> Channel <--> node_42.gateTo[28];
//        node_28.gateTo[43] <--> Channel <--> node_43.gateTo[28];
//        node_28.gateTo[44] <--> Channel <--> node_44.gateTo[28];
//        node_28.gateTo[46] <--> Channel <--> node_46.gateTo[28];
//        node_28.gateTo[47] <--> Channel <--> node_47.gateTo[28];
//        node_28.gateTo[48] <--> Channel <--> node_48.gateTo[28];
//        node_28.gateTo[50] <--> Channel <--> node_50.gateTo[28];
//        node_29.gateTo[5] <--> Channel <--> node_5.gateTo[29];
//        node_29.gateTo[6] <--> Channel <--> node_6.gateTo[29];
//        node_29.gateTo[7] <--> Channel <--> node_7.gateTo[29];
//        node_29.gateTo[30] <--> Channel <--> node_30.gateTo[29];
//        node_29.gateTo[31] <--> Channel <--> node_31.gateTo[29];
//        node_29.gateTo[32] <--> Channel <--> node_32.gateTo[29];
//        node_29.gateTo[33] <--> Channel <--> node_33.gateTo[29];
//        node_29.gateTo[35] <--> Channel <--> node_35.gateTo[29];
//        node_29.gateTo[36] <--> Channel <--> node_36.gateTo[29];
//        node_29.gateTo[37] <--> Channel <--> node_37.gateTo[29];
//        node_29.gateTo[41] <--> Channel <--> node_41.gateTo[29];
//        node_29.gateTo[42] <--> Channel <--> node_42.gateTo[29];
//        node_29.gateTo[43] <--> Channel <--> node_43.gateTo[29];
//        node_29.gateTo[44] <--> Channel <--> node_44.gateTo[29];
//        node_29.gateTo[46] <--> Channel <--> node_46.gateTo[29];
//        node_29.gateTo[47] <--> Channel <--> node_47.gateTo[29];
//        node_29.gateTo[48] <--> Channel <--> node_48.gateTo[29];
//        node_29.gateTo[50] <--> Channel <--> node_50.gateTo[29];
//        node_30.gateTo[5] <--> Channel <--> node_5.gateTo[30];
//        node_30.gateTo[6] <--> Channel <--> node_6.gateTo[30];
//        node_30.gateTo[7] <--> Channel <--> node_7.gateTo[30];
//        node_30.gateTo[31] <--> Channel <--> node_31.gateTo[30];
//        node_30.gateTo[32] <--> Channel <--> node_32.gateTo[30];
//        node_30.gateTo[33] <--> Channel <--> node_33.gateTo[30];
//        node_30.gateTo[35] <--> Channel <--> node_35.gateTo[30];
//        node_30.gateTo[36] <--> Channel <--> node_36.gateTo[30];
//        node_30.gateTo[37] <--> Channel <--> node_37.gateTo[30];
//        node_30.gateTo[41] <--> Channel <--> node_41.gateTo[30];
//        node_30.gateTo[42] <--> Channel <--> node_42.gateTo[30];
//        node_30.gateTo[43] <--> Channel <--> node_43.gateTo[30];
//        node_30.gateTo[44] <--> Channel <--> node_44.gateTo[30];
//        node_30.gateTo[46] <--> Channel <--> node_46.gateTo[30];
//        node_30.gateTo[47] <--> Channel <--> node_47.gateTo[30];
//        node_30.gateTo[48] <--> Channel <--> node_48.gateTo[30];
//        node_30.gateTo[50] <--> Channel <--> node_50.gateTo[30];
//        node_31.gateTo[5] <--> Channel <--> node_5.gateTo[31];
//        node_31.gateTo[6] <--> Channel <--> node_6.gateTo[31];
//        node_31.gateTo[7] <--> Channel <--> node_7.gateTo[31];
//        node_31.gateTo[32] <--> Channel <--> node_32.gateTo[31];
//        node_31.gateTo[33] <--> Channel <--> node_33.gateTo[31];
//        node_31.gateTo[35] <--> Channel <--> node_35.gateTo[31];
//        node_31.gateTo[36] <--> Channel <--> node_36.gateTo[31];
//        node_31.gateTo[37] <--> Channel <--> node_37.gateTo[31];
//        node_31.gateTo[41] <--> Channel <--> node_41.gateTo[31];
//        node_31.gateTo[42] <--> Channel <--> node_42.gateTo[31];
//        node_31.gateTo[43] <--> Channel <--> node_43.gateTo[31];
//        node_31.gateTo[44] <--> Channel <--> node_44.gateTo[31];
//        node_31.gateTo[46] <--> Channel <--> node_46.gateTo[31];
//        node_31.gateTo[47] <--> Channel <--> node_47.gateTo[31];
//        node_31.gateTo[48] <--> Channel <--> node_48.gateTo[31];
//        node_31.gateTo[50] <--> Channel <--> node_50.gateTo[31];
//        node_32.gateTo[5] <--> Channel <--> node_5.gateTo[32];
//        node_32.gateTo[6] <--> Channel <--> node_6.gateTo[32];
//        node_32.gateTo[7] <--> Channel <--> node_7.gateTo[32];
//        node_32.gateTo[33] <--> Channel <--> node_33.gateTo[32];
//        node_32.gateTo[35] <--> Channel <--> node_35.gateTo[32];
//        node_32.gateTo[36] <--> Channel <--> node_36.gateTo[32];
//        node_32.gateTo[37] <--> Channel <--> node_37.gateTo[32];
//        node_32.gateTo[41] <--> Channel <--> node_41.gateTo[32];
//        node_32.gateTo[42] <--> Channel <--> node_42.gateTo[32];
//        node_32.gateTo[43] <--> Channel <--> node_43.gateTo[32];
//        node_32.gateTo[44] <--> Channel <--> node_44.gateTo[32];
//        node_32.gateTo[46] <--> Channel <--> node_46.gateTo[32];
//        node_32.gateTo[47] <--> Channel <--> node_47.gateTo[32];
//        node_32.gateTo[48] <--> Channel <--> node_48.gateTo[32];
//        node_32.gateTo[50] <--> Channel <--> node_50.gateTo[32];
//        node_33.gateTo[5] <--> Channel <--> node_5.gateTo[33];
//        node_33.gateTo[6] <--> Channel <--> node_6.gateTo[33];
//        node_33.gateTo[7] <--> Channel <--> node_7.gateTo[33];
//        node_33.gateTo[35] <--> Channel <--> node_35.gateTo[33];
//        node_33.gateTo[36] <--> Channel <--> node_36.gateTo[33];
//        node_33.gateTo[37] <--> Channel <--> node_37.gateTo[33];
//        node_33.gateTo[41] <--> Channel <--> node_41.gateTo[33];
//        node_33.gateTo[42] <--> Channel <--> node_42.gateTo[33];
//        node_33.gateTo[43] <--> Channel <--> node_43.gateTo[33];
//        node_33.gateTo[44] <--> Channel <--> node_44.gateTo[33];
//        node_33.gateTo[46] <--> Channel <--> node_46.gateTo[33];
//        node_33.gateTo[47] <--> Channel <--> node_47.gateTo[33];
//        node_33.gateTo[48] <--> Channel <--> node_48.gateTo[33];
//        node_33.gateTo[50] <--> Channel <--> node_50.gateTo[33];
//        node_35.gateTo[5] <--> Channel <--> node_5.gateTo[35];
//        node_35.gateTo[6] <--> Channel <--> node_6.gateTo[35];
//        node_35.gateTo[7] <--> Channel <--> node_7.gateTo[35];
//        node_35.gateTo[36] <--> Channel <--> node_36.gateTo[35];
//        node_35.gateTo[37] <--> Channel <--> node_37.gateTo[35];
//        node_35.gateTo[41] <--> Channel <--> node_41.gateTo[35];
//        node_35.gateTo[42] <--> Channel <--> node_42.gateTo[35];
//        node_35.gateTo[43] <--> Channel <--> node_43.gateTo[35];
//        node_35.gateTo[44] <--> Channel <--> node_44.gateTo[35];
//        node_35.gateTo[46] <--> Channel <--> node_46.gateTo[35];
//        node_35.gateTo[47] <--> Channel <--> node_47.gateTo[35];
//        node_35.gateTo[48] <--> Channel <--> node_48.gateTo[35];
//        node_35.gateTo[50] <--> Channel <--> node_50.gateTo[35];
//        node_36.gateTo[5] <--> Channel <--> node_5.gateTo[36];
//        node_36.gateTo[6] <--> Channel <--> node_6.gateTo[36];
//        node_36.gateTo[7] <--> Channel <--> node_7.gateTo[36];
//        node_36.gateTo[37] <--> Channel <--> node_37.gateTo[36];
//        node_36.gateTo[41] <--> Channel <--> node_41.gateTo[36];
//        node_36.gateTo[42] <--> Channel <--> node_42.gateTo[36];
//        node_36.gateTo[43] <--> Channel <--> node_43.gateTo[36];
//        node_36.gateTo[44] <--> Channel <--> node_44.gateTo[36];
//        node_36.gateTo[46] <--> Channel <--> node_46.gateTo[36];
//        node_36.gateTo[47] <--> Channel <--> node_47.gateTo[36];
//        node_36.gateTo[48] <--> Channel <--> node_48.gateTo[36];
//        node_36.gateTo[50] <--> Channel <--> node_50.gateTo[36];
//        node_37.gateTo[5] <--> Channel <--> node_5.gateTo[37];
//        node_37.gateTo[6] <--> Channel <--> node_6.gateTo[37];
//        node_37.gateTo[7] <--> Channel <--> node_7.gateTo[37];
//        node_37.gateTo[41] <--> Channel <--> node_41.gateTo[37];
//        node_37.gateTo[42] <--> Channel <--> node_42.gateTo[37];
//        node_37.gateTo[43] <--> Channel <--> node_43.gateTo[37];
//        node_37.gateTo[44] <--> Channel <--> node_44.gateTo[37];
//        node_37.gateTo[46] <--> Channel <--> node_46.gateTo[37];
//        node_37.gateTo[47] <--> Channel <--> node_47.gateTo[37];
//        node_37.gateTo[48] <--> Channel <--> node_48.gateTo[37];
//        node_37.gateTo[50] <--> Channel <--> node_50.gateTo[37];
//        node_41.gateTo[5] <--> Channel <--> node_5.gateTo[41];
//        node_41.gateTo[6] <--> Channel <--> node_6.gateTo[41];
//        node_41.gateTo[7] <--> Channel <--> node_7.gateTo[41];
//        node_41.gateTo[42] <--> Channel <--> node_42.gateTo[41];
//        node_41.gateTo[43] <--> Channel <--> node_43.gateTo[41];
//        node_41.gateTo[44] <--> Channel <--> node_44.gateTo[41];
//        node_41.gateTo[46] <--> Channel <--> node_46.gateTo[41];
//        node_41.gateTo[47] <--> Channel <--> node_47.gateTo[41];
//        node_41.gateTo[48] <--> Channel <--> node_48.gateTo[41];
//        node_41.gateTo[50] <--> Channel <--> node_50.gateTo[41];
//        node_42.gateTo[5] <--> Channel <--> node_5.gateTo[42];
//        node_42.gateTo[6] <--> Channel <--> node_6.gateTo[42];
//        node_42.gateTo[7] <--> Channel <--> node_7.gateTo[42];
//        node_42.gateTo[43] <--> Channel <--> node_43.gateTo[42];
//        node_42.gateTo[44] <--> Channel <--> node_44.gateTo[42];
//        node_42.gateTo[46] <--> Channel <--> node_46.gateTo[42];
//        node_42.gateTo[47] <--> Channel <--> node_47.gateTo[42];
//        node_42.gateTo[48] <--> Channel <--> node_48.gateTo[42];
//        node_42.gateTo[50] <--> Channel <--> node_50.gateTo[42];
//        node_43.gateTo[5] <--> Channel <--> node_5.gateTo[43];
//        node_43.gateTo[6] <--> Channel <--> node_6.gateTo[43];
//        node_43.gateTo[7] <--> Channel <--> node_7.gateTo[43];
//        node_43.gateTo[44] <--> Channel <--> node_44.gateTo[43];
//        node_43.gateTo[46] <--> Channel <--> node_46.gateTo[43];
//        node_43.gateTo[47] <--> Channel <--> node_47.gateTo[43];
//        node_43.gateTo[48] <--> Channel <--> node_48.gateTo[43];
//        node_43.gateTo[50] <--> Channel <--> node_50.gateTo[43];
//        node_44.gateTo[5] <--> Channel <--> node_5.gateTo[44];
//        node_44.gateTo[6] <--> Channel <--> node_6.gateTo[44];
//        node_44.gateTo[7] <--> Channel <--> node_7.gateTo[44];
//        node_44.gateTo[46] <--> Channel <--> node_46.gateTo[44];
//        node_44.gateTo[47] <--> Channel <--> node_47.gateTo[44];
//        node_44.gateTo[48] <--> Channel <--> node_48.gateTo[44];
//        node_44.gateTo[50] <--> Channel <--> node_50.gateTo[44];
//        node_46.gateTo[5] <--> Channel <--> node_5.gateTo[46];
//        node_46.gateTo[6] <--> Channel <--> node_6.gateTo[46];
//        node_46.gateTo[7] <--> Channel <--> node_7.gateTo[46];
//        node_46.gateTo[47] <--> Channel <--> node_47.gateTo[46];
//        node_46.gateTo[48] <--> Channel <--> node_48.gateTo[46];
//        node_46.gateTo[50] <--> Channel <--> node_50.gateTo[46];
//        node_47.gateTo[5] <--> Channel <--> node_5.gateTo[47];
//        node_47.gateTo[6] <--> Channel <--> node_6.gateTo[47];
//        node_47.gateTo[7] <--> Channel <--> node_7.gateTo[47];
//        node_47.gateTo[48] <--> Channel <--> node_48.gateTo[47];
//        node_47.gateTo[50] <--> Channel <--> node_50.gateTo[47];
//        node_48.gateTo[5] <--> Channel <--> node_5.gateTo[48];
//        node_48.gateTo[6] <--> Channel <--> node_6.gateTo[48];
//        node_48.gateTo[7] <--> Channel <--> node_7.gateTo[48];
//        node_48.gateTo[50] <--> Channel <--> node_50.gateTo[48];
//        node_5.gateTo[6] <--> Channel <--> node_6.gateTo[5];
//        node_5.gateTo[7] <--> Channel <--> node_7.gateTo[5];
//        node_5.gateTo[50] <--> Channel <--> node_50.gateTo[5];
//        node_50.gateTo[6] <--> Channel <--> node_6.gateTo[50];
//        node_50.gateTo[7] <--> Channel <--> node_7.gateTo[50];
//        node_6.gateTo[7] <--> Channel <--> node_7.gateTo[6];

        //TODO delete these connetions - testing purposes only
}
