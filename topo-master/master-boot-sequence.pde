// master-boot-sequence.pde

#ifndef _MASTER_BOOT_SEQUENCE_PDE_
#define _MASTER_BOOT_SEQUENCE_PDE_

#include "master-header.pde"
#include "master-data-structures.pde"


void bootSequence() {

	initGraph(&graph, ndev); // init graph with ndev elements
	initItems(&path, ndev);

	// pack big_UID into 8-bit UID[]
	UID[0] = big_UID >> 24;
	UID[1] = big_UID >> 16;
	UID[2] = big_UID >> 8;
	UID[3] = big_UID;

	// packet to be sent
	neighbour_msg[0] = 'W';
	neighbour_msg[1] = MASTER;
	neighbour_msg[2] = UID[0];
	neighbour_msg[3] = UID[1]; 
	neighbour_msg[4] = UID[2]; 
	neighbour_msg[5] = UID[3];

	neighbour_msg[6] = port_180;
	int send_0 = com_0.send(addr_180, neighbour_msg, 7);

	neighbour_msg[6] = port_270;
	int send_90 = com_90.send(addr_270, neighbour_msg, 7);

	neighbour_msg[6] = port_0;
	int send_180 = com_180.send(addr_0, neighbour_msg, 7);

	neighbour_msg[6] = port_90;
	int send_270 = com_270.send(addr_90, neighbour_msg, 7);

	delay(1500-millis());
	blink(1, 10);

	for (uint8_t i = 0; i < 5; i++) {
		// send this address to neighbour
		scan_time = millis();
		while (millis() - scan_time < 100)
			com_0.update();

		scan_time = millis();
		while (millis() - scan_time < 100)
			com_90.update();

		scan_time = millis();
		while (millis() - scan_time < 100)
			com_180.update();

		scan_time = millis();
		while (millis() - scan_time < 100)
			com_270.update();
	}
	

	scan_time = millis();
	while (millis() - scan_time < 1500)
		bus.receive();


	// // first edge will always contain master address (01)
	// sort_edges();

	uint8_t new_dev;
	uint8_t dev_UID[4];

	// detect duplicate addresses and update them with a unique one
	for (uint8_t i = 0; i < graph.used; i++) {
		for (uint8_t j = i + 1; j < graph.used; j++) {
			if (graph.edges[i].node2 == graph.edges[j].node2) {
				// if duplicate address is found

				while(1) {
					new_dev = random(2,254);
					if (!deviceExists(new_dev))
						break;
				}

				printHEX(&graph.edges[i].node2, 1);
				Serial.print(" -> ");
				printHEX(&new_dev, 1);
				Serial.println();

				// pack dev_UID into 8-bit UID[] array
				// when the packet is sent to the duplicate addresses,
				// the device with the attached UID will recognise itself
				dev_UID[0] = graph.edges[i].node2_UID >> 24;
				dev_UID[1] = graph.edges[i].node2_UID >> 16;
				dev_UID[2] = graph.edges[i].node2_UID >> 8;
				dev_UID[3] = graph.edges[i].node2_UID;

				char new_address[6] = {'N', new_dev, dev_UID[0], dev_UID[1], dev_UID[2], dev_UID[3]};

				int send_new_address = bus.send(graph.edges[i].node2, new_address, 6);

				scan_time = millis();
				while (millis() - scan_time < 500)
					bus.update();

				// update graph with new unique address
				for (uint8_t k = 0; k < graph.used; k++) {
					if (graph.edges[i].node2_UID == graph.edges[k].node2_UID)
						graph.edges[k].node2 = new_dev;

					if (graph.edges[i].node2_UID == graph.edges[k].node1_UID)
						graph.edges[k].node1 = new_dev;
				}
			}
		}
	}

	// get depth of graph
	// traverse(from, to, port, start depth, get max depth)
	traverse(graph.edges[0].node1, 255, graph.edges[0].port, 0, 1); 
	destroyItems(&path);
	initItems(&path, ndev);

	// allocate memory for a matrix containing the modules' position
	// size of matrix depends on the depth of the graph
	matrix_size = maxdepth * 2 + 1;

	topology = (Module **)malloc(matrix_size * sizeof(Module *));

	for (uint8_t i = 0; i < matrix_size; ++i)
		topology[i] = (Module *)malloc(matrix_size * sizeof(Module));

	for (uint8_t i = 0; i < matrix_size; i++) {
		for (uint8_t j = 0; j < matrix_size; j++) {
			topology[i][j].id = 0;
			topology[i][j].func = 0;
		}
	}

	// master module is at the center of the matrix
	topology[maxdepth][maxdepth].id = 1;

	// populate matrix with nodes corresponding to network topology
	// traverse(from, to, port, start depth, build topology)
	traverse(graph.edges[0].node1, 255, graph.edges[0].port, 0, 4);
	destroyItems(&path);
	initItems(&path, ndev);

	consoleDebug();

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


#endif  //_MASTER_BOOT_SEQUENCE_PDE_
