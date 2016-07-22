// master-helper-func.pde

#ifndef _MASTER_HELPER_FUNC_PDE_
#define _MASTER_HELPER_FUNC_PDE_

#include "master-header.pde"
#include "master-data-structures.pde"


void DFS(uint8_t from, uint8_t to, uint8_t port, uint8_t depth, uint8_t type);
void traverse(uint8_t from, uint8_t to, uint8_t port, uint8_t depth, uint8_t type);



// check if a device address already exists
bool deviceExists(uint8_t val) {
	for (uint8_t i = 0; i < graph.used; i++) {
		if (graph.edges[i].node2 == val)
			return true;
	}
	return false;
}

// used as templace for qsort
int edgeCompare(const void *a, const void *b) {
	uint8_t c = ((Edge *) a)->node1;
	uint8_t d = ((Edge *) b)->node1;
	// sort by increasing order
	if (c < d) return -1;
	if (c > d) return 1;
	return 0;
}

// sort edges by node1
void sort_edges() {
	qsort(graph.edges, graph.used, sizeof(Edge), edgeCompare);
}

// create a hash from multiple readings on all analog pins.
// hash algorithm used is the one-at-a-time hash function
// https://en.wikipedia.org/wiki/Jenkins_hash_function#one-at-a-time
uint32_t getSeed() {
	uint32_t seed;
	uint8_t i;

	for (seed = 0, i = 0; i < 32; i++) {
		seed += analogRead(random(0,8));
		seed += (seed << 10);
		seed ^= (seed >> 6);
	}
	seed += (seed << 3);
	seed ^= (seed >> 11);
	seed += (seed << 15);

	return seed;
}

// prints 8-bit data in hex
void printHEX(uint8_t *data, uint8_t len) {
	char tmp[len*2+1];
	byte first;
	int j = 0;
	for (uint8_t i = 0; i < len; i++) {
		first = (data[i] >> 4) | 48;
		if (first > 57) tmp[j] = first + (byte)39;
		else tmp[j] = first;
		j++;

		first = (data[i] & 0x0F) | 48;
		if (first > 57) tmp[j] = first + (byte)39; 
		else tmp[j] = first;
		j++;
	}
	tmp[len*2] = 0;
	Serial.print(tmp);
}


void DFS(uint8_t from, uint8_t to, uint8_t port, uint8_t depth, uint8_t type) {
	for (uint8_t i = 0; i < graph.used; i++) {
		if (!graph.edges[i].visited) {
			graph.edges[i].visited = 1;
			if (from == graph.edges[i].node1)
				traverse(graph.edges[i].node2, to, graph.edges[i].port, depth, type);
			else if (from == graph.edges[i].node2)
				traverse(graph.edges[i].node1, to, graph.edges[i].port, depth, type);
			graph.edges[i].visited = 0;
		}
	}
}


// use DFS to find different kinds of information about the graph
void traverse(uint8_t from, uint8_t to, uint8_t port, uint8_t depth, uint8_t type) {
	uint8_t counter = depth++;
	addItem(&path, {0,0});	
	path.array[counter].val1 = from;
	path.array[counter].val2 = port;	

	// if type == 1 -> calculate maxdepth
	if (type == 1) {
		if (depth > maxdepth) 
			maxdepth = depth-1;
	}

	// if type == 2 -> print paths from a to b
	// if type == 3 -> print all paths in the graph
	if (type == 2 || type == 3) {
		if (from == to || type == 3) {
			for (uint8_t i = 0; i < depth; i++) {
				if (i) Serial.print(" ");
				printHEX(&path.array[i].val1, 1);
			}
			Serial.println();
		}
	}

	// if type == 4 -> construct topology
	if (type == 4) {
		uint8_t x = maxdepth;
		uint8_t y = maxdepth;

		for (uint8_t i = 1; i < depth; i++) {

			if (path.array[i].val2 == port_0) {
				y++;
				topology[y][x].id = path.array[i].val1;
			}

			if (path.array[i].val2 == port_90) {
				x--;
				topology[y][x].id = path.array[i].val1;
			}		

			if (path.array[i].val2 == port_180) {
				y--;
				topology[y][x].id = path.array[i].val1;
			}

			if (path.array[i].val2 == port_270) {
				x++;
				topology[y][x].id = path.array[i].val1;	
			}

		}
	}

	if (from != to)
		DFS(from, to, port, depth, type);

}

void printLine(uint8_t len) {
	for (uint8_t i = 0; i < len; i++)
		Serial.print("-");
	Serial.println();
}


// prints the matrix containing a representation of 
// the resulting network topology
void printMatrixBounds(uint8_t maxtrix_size) {
	uint8_t up = maxtrix_size;
	uint8_t down = 0;
	uint8_t left = maxtrix_size;
	uint8_t right = 0;

	for (uint8_t i = 0; i < maxtrix_size; i++) {
		for (uint8_t j = 0; j < maxtrix_size; j++) {
			if (topology[i][j].id > 0 && right <= j)
				right = j;
			if (topology[i][j].id > 0 && left >= j)
				left = j;
			if (topology[i][j].id > 0 && up >= i)
				up = i;
			if (topology[i][j].id > 0 && down <= i)
				down = i;
		}
	}

	for (uint8_t i = up; i <= down; i++) {
		for (uint8_t j = left; j <= right; j++) {
			Serial.print(" ");
			if (topology[i][j].id == 0)
				Serial.print("  ");
			else
				printHEX(&topology[i][j].id, 1);
		}
		Serial.println();
		Serial.println();
	}	
}

// prints the matrix containing a representation of 
// the resulting network topology
void printMatrix(uint8_t maxtrix_size) {
	for (uint8_t i = 0; i < maxtrix_size; i++) {
		for (uint8_t j = 0; j < maxtrix_size; j++) {
			if (topology[i][j].id == 0)
				Serial.print("░░"); // set console to read UTF-8
			else
				printHEX(&topology[i][j].id, 1);
			Serial.print(" ");
		}
		Serial.println();
		Serial.println();
	}
}


// prints list of devices with their unique ID
void printDevices() {
	uint8_t tmp_UID[4];

	tmp_UID[0] = graph.edges[0].node1_UID >> 24;
	tmp_UID[1] = graph.edges[0].node1_UID >> 16;
	tmp_UID[2] = graph.edges[0].node1_UID >> 8;
	tmp_UID[3] = graph.edges[0].node1_UID;

	printHEX(&graph.edges[0].node1, 1); // master address
	Serial.print(" (");
	for (uint8_t j=0; j<4; j++) {
		printHEX(&tmp_UID[j], 1);
	}
	Serial.println(")");
	Serial.println();

	for (uint8_t i=0; i<graph.used; i++) {
		printHEX(&graph.edges[i].node2, 1); // slave addresses

		tmp_UID[0] = graph.edges[i].node2_UID >> 24;
		tmp_UID[1] = graph.edges[i].node2_UID >> 16;
		tmp_UID[2] = graph.edges[i].node2_UID >> 8;
		tmp_UID[3] = graph.edges[i].node2_UID;

		Serial.print(" (");
		for (uint8_t j=0; j<4; j++) {
			printHEX(&tmp_UID[j], 1);
		}
		Serial.println(")");
	}
}

// prints list of edges from the graph
void printEdges() {
	for (uint8_t i = 0; i < graph.used; i++) {
		Serial.print("E");
		Serial.print(i+1);
		Serial.print(": ");
		printHEX(&graph.edges[i].node1, 1);
		Serial.print("-");
		printHEX(&graph.edges[i].node2, 1);
		// Serial.write(9); // tab
		Serial.print(" ");
		Serial.println(graph.edges[i].port);
	}
}

// prints avaible memory left on device
void printMem() {
	Serial.print("Mem: ");
	Serial.print(freeMemory());
	Serial.println(" bytes");
}

void consoleDebug() {

	Serial.println();
	Serial.println("Devices found");
	printLine(13);
	printDevices();

	Serial.println();
	Serial.println("Edges");
	printLine(5);
	printEdges();

	// print all paths
	Serial.println();
	Serial.print("DFS (depth: ");
	Serial.print(maxdepth);
	Serial.println(")");
	printLine(3);
	traverse(graph.edges[0].node1, 255, graph.edges[0].port, 0, 3); 
	destroyItems(&path);
	initItems(&path, ndev);
	Serial.println();

	Serial.println("Topology (UTF-8)");
	printLine(8);
	Serial.println();
	printMatrix(matrix_size);
	Serial.println();

	printMem();
	Serial.println();

	Serial.print("Boot time: ");
	Serial.print(millis());
	Serial.println("ms");
	Serial.println();

}

// blink n times, with delay t
void blink(uint8_t n, uint8_t t) {
	for (uint8_t i = 0; i < n; i++) {
		digitalWrite(activityLED, HIGH);
		delay(t);
		digitalWrite(activityLED, LOW);
		delay(t);
	}
}

// software reset
void softReset() {
	asm volatile (" jmp 0");
}


#endif  //_MASTER_HELPER_FUNC_PDE_
