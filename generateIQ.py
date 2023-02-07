#!/usr/bin/env python


from sun_phy import Mr_fsk_modulator, Mr_ofdm_modulator
import numpy as np
from subprocess import run

IQ_FILE = 'IQ.csv'
SCRIPT_FILE = 'bladerf_script.txt'

# Edit the message here
MESSAGE = b'this is a test message'

# Edit this function to change the transmitted signal (IQ)
def iq():
    # Center carrier frequency
    Fc = 869.025e6 # OFDM option 2 channel 7   

    mod = Mr_ofdm_modulator(
        MCS = 3,
        OFDM_Option = 2,
        phyOFDMInterleaving = 1,
        scrambler = 0,
        verbose = False
    )

    iq, Fs = mod.bytesToIQ(MESSAGE)

    return Fc, iq, Fs



def main():
    Fc, iq, Fs = iq()

    sampleBits = 12

    print(f"message : {' '.join([hex(x) for x in MESSAGE])}")
    
    M = np.stack([iq.real, iq.imag]).T

    M = np.floor(M * 2**(sampleBits-1) / np.abs(M).max()).astype(int)

    np.savetxt(IQ_FILE, M, fmt='%i', delimiter=',')

    # With "set gain tx1 30", the receiver has ~ -60dBm when 40cm appart (with antennas)
    
    bladeRFScript = f"""
set frequency tx {Fc/1e6:.3f}M
set samplerate tx {f}
set bandwidth tx 1M
set gain tx1 60

tx config file=IQ.csv format=csv repeat=5 delay=1000000
tx start
tx wait
tx
    """
    # Write the BladeRF script
    with open(SCRIPT_FILE, 'w') as f:
        f.write(bladeRFScript)

    # Run the BladeRF CLI tool
    run(["bladeRF-cli", "-s", "bladerf_script.txt"])

if __name__ == '__main__':
    main()