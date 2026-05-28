import time
import argparse
import subprocess
import os

def wait_until(target_time: float):
	while True:
		now=time.time()
		remain = target_time - now
		if remain <= 0:
			break
		if remain > 1.00:
			time.sleep(remain / 2)


def main():
	parser = argparse.ArgumentParser()

	parser.add_argument("--start-time", type=float, required=True)
	parser.add_argument("--output", required=True)
	parser.add_argument("--duration", type=int, default=10)
	args = parser.parse_args()

	remote_dir="/home/mic1/recordings"
	timestamp=""
	label="pi"
	device="hw:3,0"
	rate="48000"
	channels="2"
	format="S16_LE"

	cmd = [
	"arecord",
	"-D", device,
	"-f", format,
	"-r", rate,
	"-c", channels,
	"-d", str(args.duration),
	"-t", "wav",
	args.output
	]
	

	wait_until(args.start_time)
	subprocess.run(cmd, check=True)
	print("finished recording")


if __name__ == "__main__":
	main()
