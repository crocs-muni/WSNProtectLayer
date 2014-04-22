#ifndef NODE_LIST_H
#define NODE_LIST_H

typedef struct registered_node {
	uint8_t nodeid;
	uint8_t delay;
} TRNode;

#define MAX_NODES 32

#endif /* NODE_LIST_H */
