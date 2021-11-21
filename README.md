# derty-template
Seed for scripting daily workflows like time tracking, mail highlights, build completions.

This repo is intended as an initial template for building own setup. It is
still recommended to track template in order to receive updates if any will
happen.

## Motivation

There are many home automation solutions, but I was not able to find some
local-only solution with simplicity of old hotplug scripts but targeting user
environment.

- Do not spend minutes staring at command output or refreshing web page.
- Be mindful of working hours on remote.
- Keep informed about valuable events. Shorten communication loop as if you
  were in a same room.
- Evolve your automation rapidly.

## Structure

```
├── events
│   ├── trigger.bash
│   ├── some-event.d
│   │   └── ...
│   └── ...
├── hooks
│   └── ...
├── agents
│   └── ...
└── ...
```

### `events`
This is the heart of all automatic "reactions" here. Either create
`some-event.d` folder or `some-event.bash` script to get it triggered when
`events/trigger.bash some-event` being called.

Right now it is based on `run-parts` script from `debianutils`.

### `hooks`
Some basic integrations goes here to trigger events in a form of one-time-fire.
Think of scripts for handling dekstop notification from dunst, Evolution
mailbox, or git commit-msg hook.

### `agents`
If you cannot get away with just `hooks`, you might need some daemons that
either listen or monitor something to produce events.

## What goes into this repo
It is subjective choice for mix of specific and generic stuff.

### Trivial

To get cmd-completion events, prefix your command with `hooks/run-cmd.bash`
and you'll get back on it. `events/cmd-complete.d/notify.bash` will send
desktop notification.

To get locking/unlocked/awakened wrap your screen lock with `hooks/run-lock.bash`.

### TimeWarrior

If you track your time using it and have configuration for exclusions
like described here https://timewarrior.net/docs/workweek/
```
# ~/.timewarrior/timewarrior.cfg

define exclusions:
  monday    = <9:00 12:30-13:00 >17:00
  tuesday   = <9:00 12:30-13:00 >17:00
  wednesday = <9:00 12:30-13:00 >17:00
  thursday  = <9:00 12:30-13:00 >17:00
  friday    = <9:00 12:30-13:00 >17:00
  saturday  = >0:00
  sunday    = >0:00

```

You can benefit from:
- `events/awakened.d/timew.bash` auto-pause your intervals
  saving from doing `timew stop`, `timew cont`.
- `events/out-of-hours.d/sample.bash` sample notification to shout "Go home!".
- `agents/timew-sampler.py` silly sampler of "Ho much do I left for today?"
  saving from checking `timew summary`.
  Makes sense to be run on first work login of the day.
