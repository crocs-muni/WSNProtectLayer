//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

#ifndef __VIZUALIZATION_INJECTOR_H_
#define __VIZUALIZATION_INJECTOR_H_

#include <omnetpp.h>
#include <time.h>

/**
 * TODO - Generated class
 */
class Injector: public cSimpleModule {
protected:
    FILE *f;
    time_t exp_start; //experiment start time
    char nodeId[3];
    char timeStamp[30];
    char messageHex[1000];
    char receiver[6];

    //table with the node ID conversions
//    char nodeIds[100][3];

    bool stillAliveFlag;

    cMessage * stmsg;
public:
    Injector();
    virtual ~Injector();

    enum InjectorMessageKinds {
        STEP_TIMER = 25500,
        LAST_INJECTOR_APPL_MESSAGE_KIND
    };

protected:
    virtual void initialize();
    virtual void finish();
    virtual void handleMessage(cMessage *msg);
};

#endif
