#!/usr/bin/env python3

import sys
import os, signal
import argparse

DEFAULT_TARGET_PROCESS='benchmark_app'
DEFAULT_DELAY=5

def is_cpu_idle_or_full(prev, curr):
    if (prev < 10 and curr < 10) or (abs(prev - 100) < 10 and abs(curr - 100) < 10):
        return True
    return False

def monitor(args):
    curr = {}
    prev = {}
    duration = 0
    exit_count = 0

    pse = os.popen(f'top -b -d {args.d}')

    for line in pse:
        line = line.rstrip('\n')
        line_tok = line.split()
        try:
            if line_tok[0].strip() == 'PID':
                # This is the start of iteration. Move curr to prev.
                prev = curr
                curr = {}
                if len(prev) == 0:
                    print(f'No {args.t} process is running...')

            pid = int(line_tok[0])
            user = line_tok[1]
            proc = line_tok[11]
        except:
            # If this line is not about process list, move to next list
            continue

        if proc != args.t:
            continue

        print(line)
        curr[pid] = line_tok
        # check VIRT, RES, SHR and %CPU
        if pid in prev and prev[pid][4:6] == curr[pid][4:6]:
            duration = duration + DEFAULT_DELAY
            if duration > 50:
                print(f'process {pid} is hanging. Send SIGKILL.')
                os.system(f'ps -wf --pid {pid}')
                print('---------------------------------------')
                try:
                    os.kill(pid, signal.SIGKILL)
                except:
                    pass   # os.kill may throw exception because process is already killed
        else:
            duration = 0


def main():
    parser = argparse.ArgumentParser(description='Kill hanging process. A process is judged as hang or not by VIRT, RES, SHR, %CPU in top.')

    parser.add_argument('-t', default=DEFAULT_TARGET_PROCESS, help=f'process name to monitor. default: {DEFAULT_TARGET_PROCESS}')
    parser.add_argument('-d', default=DEFAULT_DELAY, type=int, help=f'Time delay between hang check. default: {DEFAULT_DELAY}')

    args = parser.parse_args()

    monitor(args)


if __name__ == '__main__':
    main()
