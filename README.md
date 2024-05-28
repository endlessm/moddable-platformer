# Godot Minigames

Mini games from [Endless OS Foundation](https://endlessos.org) intended to help ease the learning curve into Godot.

See the `doc/` folder inside each game's subdirectory for more information on each game!

## Opening Projects

For now:

1. Clone this repository (or download it as a zip and extract it)
2. Open Godot; from the Project Manager window select **Import** and navigate to the folder for this repository
3. Select the subdirectory for the game you want to import (e.g. `pong`)

We plan to export these minigames somewhere more accessible, e.g. as release on GitHub or to Itch.io in the future.

## Contributing

This repo is being developed internally based on the needs and active pilots of the Endless learning team. Endless team members should **communicate openly with the team to avoid potential merge conflicts**, as we are still learning best practices for collaborative development of a Godot project.

External contributions are welcome, but may be difficult to integrate during periods of more rapid development; **communicating with the Endless team via filing an issue against this repo is highly encouraged** before sinking too much time into a PR.

### Development environment

Please use [pre-commit](https://pre-commit.com) to check for correct formatting
and other issues before creating commits. To do this automatically, you can add
it as a git hook:

```
# If you don't have pre-commit already:
pip install pre-commit

# Setup git hook:
pre-commit install
```

Now `pre-commit` will run automatically on `git commit`!
