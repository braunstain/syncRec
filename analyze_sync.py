import numpy as np
from scipy.io import wavfile
from scipy.signal import correlate
import os
import argparse


def measure_offset(file1, file2):
    sr1, data1 = wavfile.read(file1)
    sr2, data2 = wavfile.read(file2)
    assert sr1 == sr2, f"Sample rate mismatch: {sr1} vs {sr2}"

    a = (data1[:, 0] if data1.ndim > 1 else data1).astype(np.float64)
    b = (data2[:, 0] if data2.ndim > 1 else data2).astype(np.float64)

    corr = correlate(a, b, mode="full")
    lag = np.argmax(corr) - (len(b) - 1)
    return lag, lag / sr1 * 1000


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dir", default="./test_results")
    parser.add_argument("--tests", type=int, default=1)
    args = parser.parse_args()

    print(f"{'Test':<8} {'Lag (samples)':<16} {'Offset (ms)':<14} {'Leading'}")
    print("-" * 58)

    offsets = []
    for i in range(1, args.tests + 1):
        f1 = os.path.join(args.dir, "click_24062026_144551_pi100.wav")
        f2 = os.path.join(args.dir, "click_24062026_144551_pi100.wav")
        if not (os.path.exists(f1) and os.path.exists(f2)):
            print(f"test{i:<4} — files not found, skipping")
            continue
        lag, ms = measure_offset(f1, f2)
        lead = "pi100" if lag > 0 else "pi101" if lag < 0 else "in sync"
        print(f"test{i:<4} {lag:<16} {ms:>+8.2f} ms      {lead}")
        offsets.append(ms)

    if offsets:
        print("-" * 58)
        print(f"Mean:   {np.mean(offsets):+.2f} ms")
        print(f"Std:    {np.std(offsets):.2f} ms")
        print(f"Range:  {np.min(offsets):+.2f} ms  to  {np.max(offsets):+.2f} ms")


if __name__ == "__main__":
    main()
