// slave-header.pde

#ifndef _SLAVE_HEADER_PDE_
#define _SLAVE_HEADER_PDE_


#include <PJON.h>
#include <Entropy.h>
#include <MemoryFree.h>


// PJON bus
// Bus id definition
// uint8_t bus_id[] = {0, 0, 0, 1};
// uint8_t addr_0_id[] = {0, 0, 0, 2};
// uint8_t addr_90_id[] = {0, 0, 0, 3};
// uint8_t addr_180_id[] = {0, 0, 0, 2};
// uint8_t addr_270_id[] = {0, 0, 0, 3};

PJON<SoftwareBitBang> bus;

const uint8_t MASTER = 1; // the master is at address 1 on the bus

// define addresses for PJON interconnects
const uint8_t addr_0 = 2;
const uint8_t addr_90 = 3;
const uint8_t addr_180 = 4;
const uint8_t addr_270 = 5;

// set PJON addresses for interconnections
PJON<OverSampling> com_0(addr_0);
PJON<OverSampling> com_90(addr_90);
PJON<OverSampling> com_180(addr_180);
PJON<OverSampling> com_270(addr_270);

// defined for identification of ports.
// if devices receives from specific port,
// send to resulting addresses
const uint8_t port_0 = 1;
const uint8_t port_90 = 2;
const uint8_t port_180 = 3;
const uint8_t port_270 = 4;


const uint8_t maxdev = 255; // maximum number of devices
const uint8_t activityLED = 13;
char neighbour_msg[7];
uint32_t scan_time;
uint8_t ringbuf[4] = {port_0, port_90, port_180, port_270};
uint8_t rand_address;
uint8_t UID[4];
uint32_t big_UID;
uint8_t neighbour_UID[4]; // neighbour's UID
uint8_t this_port;
uint8_t neighbour_addr = NULL;
uint32_t synchro;


#endif  //_SLAVE_HEADER_PDE_