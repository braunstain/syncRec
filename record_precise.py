import sounddevice as sd
import numpy as np
import scipy.io.wavfile as wavfile
import time
import argparse


def wait_until(t: float):
    while True:
        remain = t - time.time()
        if remain <= 0:
            break
        if remain > 0.01:
            time.sleep(remain - 0.005)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--start-time", type=float, required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--duration", type=int, default=10)
    args = parser.parse_args()

    samplerate = 48000
    channels = 2

    # Open and configure ALSA device before waiting — the expensive step
    stream = sd.RawInputStream(
        device="hw:3,0",
        samplerate=samplerate,
        channels=channels,
        dtype="int16",
        latency="low",
    )

    wait_until(args.start_time)

    # Only this call is time-critical
    stream.start()

    total_samples = samplerate * args.duration
    chunks = []
    samples_read = 0
    while samples_read < total_samples:
        data, _ = stream.read(1024)
        chunks.append(bytes(data))
        samples_read += 1024

    stream.stop()
    stream.close()

    audio = np.frombuffer(b"".join(chunks), dtype=np.int16)
    audio = audio.reshape(-1, channels)
    wavfile.write(args.output, samplerate, audio)
    print("finished recording")


if __name__ == "__main__":
    main()
