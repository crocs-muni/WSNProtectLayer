#include "Node.h"

Define_Module(Node)
;

void Node::initialize() {

}

void Node::handleMessage(cMessage *msg) {
    //old version
//    if (strcmp(this->getName(), "node_41") == 0) //BS
//    {
//        ev.bubble(this, "ALERT - MOVEMENT DETECTED!!!");
//        delete msg;
//    } else {
//        cGate * outgate = gate("gateTo$o", routeToInt(atoi(getName()+5)));
//        msg->setSentFrom(this, outgate->getId(), simTime());
//        EVCB.beginSend(msg);
//        bool keepit = outgate->deliver(msg, simTime());
//        EVCB.messageSent_OBSOLETE(msg);
//        if (!keepit) {
//            delete msg;
//        } else {
//            EVCB.endSend(msg);
//        }
//    }

    //new version
    delete msg;

//    send(msg, "gateTo$o", 43);
}

const char * Node::routeTo(int nodeId) {
    switch (nodeId) {
            case 4: return "node_41";
            case 5: return "node_40";
            case 6: return "node_19";
            case 7: return "node_17";
            case 10: return "node_25";
            case 14: return "node_37";
            case 15: return "node_17";
            case 17: return "node_37";
            case 19: return "node_04";
            case 22: return "node_41";
            case 25: return "node_44";
            case 28: return "node_04";
            case 29: return "node_50";
            case 30: return "node_35";
            case 31: return "node_41";
            case 32: return "node_50";
            case 33: return "node_41";
            case 35: return "node_22";
            case 36: return "node_42";
            case 37: return "node_41";
            case 40: return "node_22";
            case 41: return "node_41";
            case 42: return "node_22";
            case 43: return "node_14";
            case 44: return "node_41";
            case 46: return "node_33";
            case 47: return "node_46";
            case 48: return "node_33";
            case 50: return "node_31";
            default: return "node_41";
    }
}

int Node::routeToInt(int nodeId) {
    switch (nodeId) {
            case 4: return 41;
            case 5: return 40;
            case 6: return 19;
            case 7: return 17;
            case 10: return 25;
            case 14: return 37;
            case 15: return 17;
            case 17: return 37;
            case 19: return 04;
            case 22: return 41;
            case 25: return 44;
            case 28: return 04;
            case 29: return 50;
            case 30: return 35;
            case 31: return 41;
            case 32: return 50;
            case 33: return 41;
            case 35: return 22;
            case 36: return 42;
            case 37: return 41;
            case 40: return 22;
            case 41: return 41;
            case 42: return 22;
            case 43: return 14;
            case 44: return 41;
            case 46: return 33;
            case 47: return 46;
            case 48: return 33;
            case 50: return 31;
            default: return 41;
    }
}
