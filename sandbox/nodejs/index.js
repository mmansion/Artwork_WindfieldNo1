let dgram = require('dgram');
// import { Buffer } from 'node:byteArray';

// The Uint16Array typed array represents an array of 16-bit unsigned integers 
// in the platform byte order
// var byteArray = new Uint16Array(1);
var byteArray = new Uint8Array(2);


function readBit(byteArray, i, bit){
  return (byteArray[i] >> bit) % 2;
}

function setBit(byteArray, i, bit, value){
  if(value == 0){
    byteArray[i] &= ~(1 << bit);
  }else{
    byteArray[i] |= (1 << bit);
  }
}


// set all the bits to 1
for(let i = 0; i < 16; i++){
    
    if(i < 8){
        //if i is even
        if(i % 2 == 0){
            //args: arr, index, bit, value
            setBit(byteArray, 0, i, 1);
        } else {
            setBit(byteArray, 0, i, 0);
    
        }
    } else {
        setBit(byteArray, 1, i-8, 0);
    }

    //set bit i of byteArray[0]
    //or
    // setBit(byteArray, 0, i, 0);
}

// read back the bits
for(let i = 0; i < 16; i++){
    if(i < 8){
        console.log(readBit(byteArray, 0, i));
    } else {
        console.log(readBit(byteArray, 1, i-8));

    }
}

function sendData() {
    const message = Buffer.from(byteArray);
    const client = dgram.createSocket('udp4');
    client.send(message, 7010, '192.168.86.248', (err) => {
        client.close();
    });
}

sendData();