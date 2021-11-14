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


def active_track() -> Optional[timedelta]:
    if check_output(['timew', 'get', 'dom.active']).strip() != b'1':
        return None
    duration = isodate.parse_duration(check_output(['timew', 'get', 'dom.active.duration']).strip().decode('utf8'))
    return timedelta(seconds=duration.total_seconds())


def total_gaps() -> timedelta:
    total_line = [line.strip() for line in check_output(['timew', 'gaps']).splitlines() if line][-1]
    gaps = timedelta(**{k: int(v)
        for (k, v) in zip(
            ["seconds", "minutes", "hours"],
            total_line.split(b':')[::-1])})
    return gaps


def notify(*args):
    check_call(['notify-send', '-h', 'string:x-canonical-private-synchronous:timew-hours'] + list(args))


tomorrow = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
next_reminder_hours = 2
while True:
    active = active_track()
    reamaining_time = min(
            total_gaps() - (active or timedelta(seconds=0)),
            tomorrow - datetime.now())
    reamaining_hours = reamaining_time.total_seconds() / 3600
    if reamaining_hours <= 0:
        check_call([EVENTS_DIR.joinpath('trigger.bash'), 'out-of-hours'])
        break
    if active is not None and reamaining_hours <= next_reminder_hours:
        notify(f'Only {reamaining_hours:.2f} hours left today')
        next_reminder_hours = math.floor(reamaining_hours*4)/4
    sleep(5 * 60)
