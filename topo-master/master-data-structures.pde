// master-data-structures.pde

#ifndef _MASTER_DATA_STRUCTURES_PDE_
#define _MASTER_DATA_STRUCTURES_PDE_

#include "master-header.pde"


// struct to store the graph's edges
// each edge contains the node's UID
struct Edge {
	uint8_t node1;
	uint8_t node2;
	uint32_t node1_UID;
	uint32_t node2_UID;
	uint8_t port;
	uint8_t visited;
};

struct Graph {
	Edge *edges;
	uint8_t used;
	uint8_t size;
};

// dynamic array allocation helper functions
void initGraph(Graph *items, uint8_t init_size) {
	items->edges = (Edge *)malloc(init_size * sizeof(Edge));
	items->used = 0;
	items->size = init_size;
}

void insertEdge(Graph *items, Edge element) {
	if (items->used == items->size) {
		items->size *= 2;
		items->edges = (Edge *)realloc(items->edges, items->size * sizeof(Edge));
	}
	items->edges[items->used++] = element;
}

void destroyGraph(struct Graph *items) {
	free(items->edges);
	items->edges = NULL;
	items->used = items->size = 0;
}
// END dynamic array allocation helper functions

Graph graph;


// this data structure is used for the DFS tool
typedef struct _bundle {
	uint8_t val1;
	uint8_t val2;
} bundle;

typedef struct _Array {
	bundle *array;
	uint8_t used;
	uint8_t size;
} Array;

// dynamic array allocation helper functions
void initItems(struct _Array *items, uint8_t initialSize) {
	items->array = (bundle *)malloc(initialSize * sizeof(bundle));
	items->used = 0;
	items->size = initialSize;
}

void addItem(struct _Array *items, bundle element) {
	if (items->used == items->size) {
		items->size *= 2;
		items->array = (bundle *)realloc(items->array, items->size * sizeof(bundle));
	}
	items->array[items->used++] = element;
}

void destroyItems(struct _Array *items) {
	free(items->array);
	items->array = NULL;
	items->used = items->size = 0;
}
// END dynamic array allocation helper functions

Array path; // used for DFS() as a temporary layer



// used to store the modules position (and function)
// aka the network topology
// the modules are stored in a matrix
typedef struct _Module {
	uint8_t id;
	uint8_t func;
} Module;

Module **topology;


#endif  //_MASTER_DATA_STRUCTURES_PDE_
