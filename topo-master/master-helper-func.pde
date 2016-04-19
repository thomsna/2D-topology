// master-helper-func.pde

#ifndef _MASTER_HELPER_FUNC_PDE_
#define _MASTER_HELPER_FUNC_PDE_


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

// create a hash from the reading of an analog pin.
// hash algorithm used is the one-at-a-time hash function
// https://en.wikipedia.org/wiki/Jenkins_hash_function#one-at-a-time
uint32_t getSeed(const int pin) {
	uint32_t seed;
	uint32_t i;
	for (seed = 0, i = 0; i < 4; ++i) {
		seed += analogRead(pin);
		seed += (seed << 10);
		seed ^= (seed >> 6);
	}	
	seed += (seed << 3);
	seed ^= (seed >> 11);
	seed += (seed << 15);

	return seed;
}

// prints the matrix containing a representation of 
// the resulting network topology
void printMatrix(uint8_t maxtrix_size) {
	for (uint8_t i = 0; i < maxtrix_size; i++) {
		for (uint8_t j = 0; j < maxtrix_size; j++) {
			if (topology[i][j].id == 0)
				Serial.print("--"); // set console to read UTF-8 ░░
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

	printHEX(&graph.edges[0].node1, 1); // address
	Serial.print(" (");
	for (uint8_t j=0; j<4; j++) {
		printHEX(&tmp_UID[j], 1);
	}
	Serial.println(")");
	Serial.println();

	for (uint8_t i=0; i<graph.used; i++) {
		printHEX(&graph.edges[i].node2, 1); // address

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

// prints avaible memory left on device
void printMem() {
	Serial.print("Mem: ");
	Serial.print(freeMemory());
	Serial.println(" bytes");
}

// blink n times, with delay t
void blink(uint8_t n, uint8_t t) {
	for (uint8_t i = 0; i < n; i++) {
		digitalWrite(13, HIGH);
		delay(t);
		digitalWrite(13, LOW);
		delay(t);
	}
}

// software reset
void softReset() {
	asm volatile (" jmp 0");
}


#endif  //_MASTER_HELPER_FUNC_PDE_
