// slave-helper-func.pde

#ifndef _SLAVE_HELPER_FUNC_PDE_
#define _SLAVE_HELPER_FUNC_PDE_


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


#endif  //_SLAVE_HELPER_FUNC_PDE_
