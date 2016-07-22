// master-PJON.pde

#ifndef _MASTER_PJON_PDE_
#define _MASTER_PJON_PDE_

#include "master-header.pde"
#include "master-data-structures.pde"


void bus_receiver(uint8_t *payload, uint8_t length, const PacketInfo &packet_info) {
	if ((char)payload[0] == 'A') {
		// reassemble the 8-bit UID bytes into a 32-bit number
		uint32_t node1_UID = (uint32_t)payload[7] << 24 | (uint32_t)payload[8] << 16 | (uint32_t)payload[9] << 8 | (uint32_t)payload[10];
		uint32_t node2_UID = (uint32_t)payload[3] << 24 | (uint32_t)payload[4] << 16 | (uint32_t)payload[5] << 8 | (uint32_t)payload[6];		

		// add an edge to the graph with values:
		// node1, node2, node1_UID, node2_UID, port number that is seen on node2
		if (dupe != node2_UID)
			insertEdge(&graph, {payload[2], payload[1], node1_UID, node2_UID, payload[11]});
		else
			Serial.println("dupe!!!");

		dupe = node2_UID;

		// keep on listening if data is still being received
		scan_time = millis();
	}
}

void error_handler(uint8_t code, uint8_t data) {
	blink(10, 50);
}


#endif  //_MASTER_PJON_PDE_
