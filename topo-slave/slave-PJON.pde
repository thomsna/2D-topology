// slave-PJON.pde

#ifndef _SLAVE_PJON_PDE_
#define _SLAVE_PJON_PDE_


void bus_receiver(uint8_t length, uint8_t *payload) {
	// set the bus to listen on a new address if the master says so
	if ((char)payload[0] == 'N') {
		// assemble the four last bytes in a uint32_t (Arduino is little endian)
		uint32_t tmp_UID = (uint32_t)payload[2] << 24 | (uint32_t)payload[3] << 16 | (uint32_t)payload[4] << 8 | (uint32_t)payload[5];

		// if the MAC address is this device's MAC
		if (tmp_UID == big_UID) {
			bus.set_id(payload[1]); // set address on the bus
			blink(5,50);
		}
	}
}

void receiver_0(uint8_t length, uint8_t *payload) {
	if ((char)payload[0] == 'W') 
		clockwork(1, payload);
}

void receiver_90(uint8_t length, uint8_t *payload) {
	if ((char)payload[0] == 'W') 
		clockwork(2, payload);
}

void receiver_180(uint8_t length, uint8_t *payload) {
	if ((char)payload[0] == 'W') 
		clockwork(3, payload);
}

void receiver_270(uint8_t length, uint8_t *payload) {
	if ((char)payload[0] == 'W') 
		clockwork(4, payload);
}

void clockwork(uint8_t from, uint8_t *payload) {

	blink(1,5);

	neighbour_addr = payload[1];
	neighbour_UID[0] = payload[2];
	neighbour_UID[1] = payload[3];
	neighbour_UID[2] = payload[4];
	neighbour_UID[3] = payload[5];
	this_port = payload[6];

	uint8_t count = abs(from - this_port) + 2;
	uint8_t ind = count % 4;

	// ringbuf[] is a ring buffer used to send the correct port ID
	// to the neighbour
	if (from != 1) {		
		neighbour_msg[6] = ringbuf[ind];
		int send_0 = com_0.send(addr_180, neighbour_msg, 7);
	}

	count++;
	ind = count % 4;

	if (from != 2) {
		neighbour_msg[6] = ringbuf[ind];
		int send_90 = com_90.send(addr_270, neighbour_msg, 7);
	}

	count++;
	ind = count % 4;

	if (from != 3) {
		neighbour_msg[6] = ringbuf[ind];
		int send_180 = com_180.send(addr_0, neighbour_msg, 7);
	}

	count++;
	ind = count % 4;

	if (from != 4) {
		neighbour_msg[6] = ringbuf[ind];
		int send_270 = com_270.send(addr_90, neighbour_msg, 7);
	}
}


void error_handler(uint8_t code, uint8_t data) {
	blink(10,50);
}

#endif  //_SLAVE_PJON_PDE_