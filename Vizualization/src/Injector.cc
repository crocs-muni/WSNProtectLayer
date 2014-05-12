#include "Injector.h"
#include "globals.h"
#include "cenvir.h"
#include "cconfiguration.h"
#include "cconfigoption.h"
//#include "platdep/platmisc.h" // usleep
Define_Module(Injector)
;

Injector::Injector() {
    stmsg = NULL;
}

Injector::~Injector() {
//    fclose(f);
    cancelAndDelete(stmsg);
}

void Injector::finish() {
//    fclose(f);
}

void Injector::initialize() {
    //2014-05-06 09:23:15:580: S: PrivacyP: msg=19:41:88:B6:22:00:FF:FF:2C:00:3F:80:01:00:2C:00:13:00:00:64:00:2F:00:02;src=44;dst=19;type=S: FwdBuffP: sendTask;msg=19:41:88:CC:22:00:FF:FF:04:00:3F:80;src=44;dst=65535;len=12

    char line[1024];
    f = fopen(par("filename").stringValue(), "r");
    fgets(line, 1024, f);
    EV<< "line: " << line;
    std::vector<std::string> tokens = cStringTokenizer(line).asVector();

    // get fields from tokens
    strcpy(timeStamp, tokens[0].c_str());
    strcat(timeStamp, " ");
    strcat(timeStamp, tokens[1].c_str());
    std::vector<std::string> timeTokens = cStringTokenizer(timeStamp, " -:").asVector();
    struct tm ts;
    ts.tm_year = atol(timeTokens[0].c_str()) - 1900;
    ts.tm_mon = atol(timeTokens[1].c_str()) - 1;
    ts.tm_mday = atol(timeTokens[2].c_str());
    ts.tm_hour = atol(timeTokens[3].c_str());
    ts.tm_min = atol(timeTokens[4].c_str());
    ts.tm_sec = atol(timeTokens[5].c_str());
    ts.tm_isdst = 1; // Is DST on? 1 = yes, 0 = no, -1 = unknown
    exp_start = mktime(&ts);

    EV<< "exp_start: " << exp_start << endl;

    std::vector<std::string> contentTokens = cStringTokenizer(tokens[4].c_str(), " =;").asVector();

    //get message
    strcpy(messageHex, contentTokens[1].c_str());

    //get sender
    strcpy(nodeId, contentTokens[3].c_str());

    //get receiver
    strcpy(receiver, contentTokens[5].c_str());

    //send
    stmsg = new cMessage("message", STEP_TIMER);
    scheduleAt(simTime(), stmsg);
}

void Injector::handleMessage(cMessage *msg) {
    if (msg->getKind() == STEP_TIMER) {
        //signal detected movement
        char buf[8];
        strcpy(buf, "node_");
        strcat(buf, nodeId);
        cModule *mod = getParentModule()->getSubmodule(buf);
        mod->bubble(timeStamp);
        EV << "Timestamp: " << timeStamp << endl;
        cMessage * message = new cMessage(messageHex);

        int receiverId = atoi(receiver);

        //check for broadcasting the message
        if(receiverId == 65535) {
            for (int i=0; i<60; i++) {
                cGate *outgate = mod->gate("gateTo$o", i);
                cGate *otherGate = outgate->getType()==cGate::OUTPUT ? outgate->getNextGate() : outgate->getPreviousGate();
                if (otherGate) {
                    cMessage *copy = message->dup();
                    copy->setSentFrom(mod, outgate->getId(), simTime());
                    EVCB.beginSend(copy);
                    bool keepit = outgate->deliver(copy, simTime());
                    EVCB.messageSent_OBSOLETE(copy);
                    if (!keepit) {
                        delete copy;
                    } else {
                        EVCB.endSend(copy);
                    }
                }
            }
            delete message;
        } else {
            cGate * outgate = mod->gate("gateTo$o", receiverId);
            message->setSentFrom(mod, outgate->getId(), simTime());
            EVCB.beginSend(message);
            bool keepit = outgate->deliver(message, simTime());
            EVCB.messageSent_OBSOLETE(message);
            if (!keepit) {
                delete message;
            } else {
                EVCB.endSend(message);
            }
        }

         //read new data from the file
        char line[1024];
        if (fgets(line, 1024, f) != NULL) {
            EV<< "line: " << line;
            std::vector<std::string> tokens = cStringTokenizer(line).asVector();

            // get fields from tokens
            strcpy(timeStamp, tokens[0].c_str());
            strcat(timeStamp, " ");
            strcat(timeStamp, tokens[1].c_str());
            std::vector<std::string> timeTokens = cStringTokenizer(timeStamp, " -:").asVector();

            struct tm ts;
            time_t epoch;
            ts.tm_year = atol(timeTokens[0].c_str()) - 1900;
            ts.tm_mon = atol(timeTokens[1].c_str()) - 1;
            ts.tm_mday = atol(timeTokens[2].c_str());
            ts.tm_hour = atol(timeTokens[3].c_str());
            ts.tm_min = atol(timeTokens[4].c_str());
            ts.tm_sec = atol(timeTokens[5].c_str());
            ts.tm_isdst = 1;// Is DST on? 1 = yes, 0 = no, -1 = unknown
            epoch = mktime(&ts);

            std::vector<std::string> contentTokens = cStringTokenizer(tokens[4].c_str(), " =;").asVector();
            //get message
            strcpy(messageHex, contentTokens[1].c_str());

            //get sender
            strcpy(nodeId, contentTokens[3].c_str());

            //get receiver
            strcpy(receiver, contentTokens[5].c_str());

            //schedule next event
            simtime_t time = epoch - exp_start;
            EV<< "time: " << time << endl;
            EV<< "epoch: " << epoch << endl;
//                cMessage *lstmsg = new cMessage("message", LONG_STEP_TIMER);
            scheduleAt(time, stmsg);
        }
        else
        {
            fclose(f);
            delete stmsg;
        }

    }
//    Sleep(300);        //100ms

//    delete msg;
}
