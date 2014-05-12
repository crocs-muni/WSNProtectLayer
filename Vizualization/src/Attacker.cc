#include "Attacker.h"

Define_Module(Attacker)
;

Attacker::Attacker() {
//    visualRepresentation = NULL;
}

Attacker::~Attacker() {
    fclose(f);
}

void Attacker::initialize() {
    if (hasPar("attackerPath") && !strcmp(par("attackerPath").stringValue(), "")) {
        f = fopen(par("attackerPath").stringValue(), "r");

//    visualRepresentation = findVisualRepresentation();
//    if (visualRepresentation) {
//        const char *s = visualRepresentation->getDisplayString().getTagArg("p", 2);
//    const char *s = this->getDisplayString().getTagArg("p", 2);
//        if (s && *s)
//            error("The coordinates of '%s' are invalid. Please remove automatic arrangement (3rd argument of 'p' tag) from '@display' attribute.",
//                    this->getFullPath().c_str());
////    }
        scheduleAt(simTime(), new cMessage());
    }
}

void Attacker::finish() {
    fclose(f);
}

void Attacker::handleMessage(cMessage *msg) {
    char line[1024];
    while (true) {
        if (fgets(line, 1024, f) != NULL) {
        EV<< "line: " << line;
        std::vector<std::string> tokens = cStringTokenizer(line, ";").asVector();

            if (ev.isGUI() && this)
            {
                EV << "visual position. x = " << tokens[1].c_str() << " y = " << tokens[2].c_str() << " z = " << 0 << endl;
                this->getDisplayString().setTagArg("p", 0, atol(tokens[1].c_str()));
                this->getDisplayString().setTagArg("p", 1, atol(tokens[2].c_str()));
                break;
            }

        } else {
            fclose(f);
            delete msg;
        }
    }

    scheduleAt(simTime() + 1, msg);
}
