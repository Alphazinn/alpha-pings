# Alpha Pings

Alpha Pings is a lightweight and user-friendly FiveM resource for creating and managing team-based marker pings in real time. The script is designed for QBCore Framework and offers features for creating, sharing, and managing pings among team members.

## Features

- Create a team and invite others to join.
- Share marker pings with your team members.
- Delete pings after a specified timeout or manually.
- Configurable options for key bindings, timeout durations, and sounds.
- QBCore integration for notifications and team management.

## Installation

1. Download or clone this repository into your FiveM server's resources folder.
2. Add `ensure alpha-pings` to your `server.cfg` file.

## How to Use
Create a Team: Use /apcreateteam to create a new team.  
Join a Team: Use /apjointeam <teamID> to send a request to join a team.  
Accept Join Requests: The team owner can use /apaccept <playerID> to accept a player's join request.  
Create a Ping: Aim using your crosshair and press the key defined in Config.Key to create a marker ping.  
Delete a Ping: Hold the key defined in Config.Key to delete your marker.

## Commands

| Command         | Description                                  |
|-----------------|----------------------------------------------|
| `/apcreateteam` | Create a new team.                          |
| `/apjointeam <teamID>` | Request to join a specified team.     |
| `/apaccept <playerID>` | Accept a join request from a player.  |
| `/apleaveteam`  | Leave the current team.                     |
| `/apdeleteteam` | Delete your team.                           |

Resmon:

![](https://i.hizliresim.com/3jefmfp.png)

Resmon (1 Marker):

![](https://i.hizliresim.com/pd63ld1.png)

Preview Image:

![](https://i.hizliresim.com/py4qfl8.png)

## Configuration

Modify the `shared/config.lua` file to customize the script's behavior:

```lua
Config = {}

Config.Key = 74 -- [H] key for creating and deleting pings.
Config.MarkerTimeout = 10000 -- 10 seconds (in milliseconds).
Config.ButtonHoldTime = 1000 -- 1 second (in milliseconds).
Config.DelayTime = 1000 -- 1 second (in milliseconds).

Config.PingIcon = "📍" -- Icon displayed on the ping marker.

Config.PlaySound = true
Config.SoundName = "Beep_Red"
Config.SoundSetName = "DLC_HEIST_HACKING_SNAKE_SOUNDS"

```

## Contributing
Feel free to fork this repository and make improvements. Contributions are always welcome! Open a pull request if you wish to share your changes.
