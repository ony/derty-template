#!/usr/bin/env python3
# Silly monitor enough to distract you when you run out of work hours.
# Works for one day.

from datetime import datetime, timedelta
import math
from pathlib import Path
from subprocess import check_call, check_output
import sys
from time import sleep
from typing import Optional

import isodate


EVENTS_DIR = Path(sys.argv[0]).parent.parent.joinpath('events').resolve()


def timew(*args) -> str:
    return check_output(('timew',) + args).strip().decode('utf8')

def parse_time(text) -> timedelta:
    return timedelta(**{
        k: float(v)
        for (k, v) in zip(["seconds", "minutes", "hours"], text.split(':')[::-1])})

def active_track() -> Optional[timedelta]:
    if timew('get', 'dom.active') != '1':
        return None
    duration = isodate.parse_duration(timew('get', 'dom.active.duration'))
    return timedelta(seconds=duration.total_seconds())

def total_gaps_time(*args) -> timedelta:
    total_line = [line.strip() for line in timew('gaps', *args).splitlines() if line][-1]
    if 'No gaps found' in total_line:
        # There are some days when there is no work times
        return timedelta(seconds=0)
    return parse_time(total_line)

def total_summary_time(*args) -> timedelta:
    total_line = [line.strip() for line in timew('summary', *args).splitlines() if line][-1]
    if 'No filtered' in total_line:
        return timedelta(seconds=0)
    else:
        return parse_time(total_line)

def remaining_gaps_time() -> timedelta:
    return total_gaps_time(':blank') - total_summary_time()

def notify(*args):
    check_call(['notify-send', '-h', 'string:x-canonical-private-synchronous:timew-hours'] + list(args))

tomorrow = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
next_remainder_hours = 2
while True:
    active = active_track()
    time_left = min(remaining_gaps_time(), tomorrow - datetime.now())
    hours_left = time_left.total_seconds() / 3600
    if hours_left <= 0:
        check_call([EVENTS_DIR.joinpath('trigger.bash'), 'out-of-hours'])
        break
    if active is not None and hours_left <= next_remainder_hours:
        notify(f'Only {hours_left:.2f} hours left today')
        next_remainder_hours = math.floor(hours_left*4)/4
    sleep(5 * 60)
