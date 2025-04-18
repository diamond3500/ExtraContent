# Foundation
Ready-to-use foundational React Lua components.

<p align="center">
	<a href="https://foundation.roblox.com">
		<img src="https://img.shields.io/badge/%E2%80%8E-Documentation-6AE488?logo=materialformkdocs&logoColor=white" alt="Documentation Link">
	</a>
	<a href="https://roblox.atlassian.net/wiki/spaces/UIBlox/overview">
		<img src="https://img.shields.io/badge/%E2%80%8E-Confluence-0052CC?logo=confluence&logoColor=white" alt="Confluence Link">
	</a>
	<a href="https://www.roblox.com/games/18428583948/Foundation">
		<img src="https://img.shields.io/badge/%E2%80%8E-Storybook-FF4785?logo=storybook&logoColor=white" alt="Storybook Link">
	</a>
	<a href="https://rbx.enterprise.slack.com/archives/C07HG449HNZ">
		<img src="https://img.shields.io/badge/Slack-%23foundation-4A154B?logo=slack" alt="Slack Link">
	</a>
</p>
<p align="center">
	<a href="https://github.com/Roblox/foundation/actions/workflows/test.yml?query=branch%3Amain">
		<img src="https://github.com/Roblox/foundation/actions/workflows/test.yml/badge.svg?branch=main" alt="Tests">
	</a>
	<a href="https://github.com/Roblox/foundation/actions/workflows/analyze.yml?query=branch%3Amain">
		<img src="https://github.com/Roblox/foundation/actions/workflows/analyze.yml/badge.svg?branch=main" alt="Static Code Analysis">
	</a>
	<a href="https://roblox.codecov.io/gh/Roblox/foundation" > 
		<img src="https://roblox.codecov.io/gh/Roblox/foundation/graph/badge.svg?token=naygRna4En"/> 
	</a>
</p>

## Getting Started
In order to contribute to this repo you will need to be a part of the [Lua Apps Team](https://github.com/orgs/Roblox/teams/lua-apps/members)

Make sure you've cloned the Foundation repository:

```sh
git clone https://github.com/Roblox/foundation.git
```

## Development Environment

### Foreman
[Foreman](https://github.com/roblox/foreman) is used to install tools used to develop on this repository. Install foreman and run `foreman install` to get the correct version of these tools.

### Rotriever
[Rotriever](https://github.com/Roblox/rotriever) is used to install dependencies like Roact and t. Rotriever will be automatically installed via `foreman` in the step above. Run `rotrieve install` to install the dependencies.

### Developer Storybook
[Developer Storybook]((https://roblox.atlassian.net/wiki/spaces/HOW/pages/1556186059/1005+-+Using+Developer+Storybooks)) is Roblox Studio's built in storybook viewer solution. You will need to be logged in with an internal account.
* Open `foundation/projects/storybook.rbxp` in Roblox Studio
* Click on the Storybook button under the Plugins tab!

#### Working with Storybook
To work on Storybook stories, open the test place with the steps above.
Open the Storybook plugin from the plugins menu, and you will see the public and private storybooks for Foundation.
You can also play the Place to view all the stories embedded in the running game.

#### Storybook Place
When you create a PR, Foundation CI will publish your changes to a place development place based on your PR number. A link to the place will be commented on your PR. This place will be updated with your changes every time you push to your PR.

When a PR is merged, Foundation CI will publish the latest main to [this Roblox place](https://www.roblox.com/games/18428583948/Foundation) via [this GHA job](https://github.com/Roblox/foundation/actions/workflows/place-publish.yml).

## Adding new components

Average component consists of 6 files
- `init.lua` - reexport of the component for cleaner inputs. Don't forget to reexport the types needed.
- `Component.bench.lua` - standard benchmarks to detect performance degradation.
- `Component.lua` - main code of the component. Feel free to create subcomponent in separate files.
- `Component.md` - documentation that will be displayed on the documentation site.
- `Component.story.lua`
- `Component.tests.lua`

To simplify setup of the new component there is an [init_component.py](scripts/init_component.py) script that will create 
the files described above with the basic working component setup. The script requires two parameters: **component name**: `string`, the name of the component, and **category**: `"Display", "Inputs", "Layout", "Media", "Actions"`, the category the components is in as it will be shown in the docs site.

e.g. to create boilerplate for an `AvatarGroup` component you would run:
```shell
python scripts/init_component.py AvatarGroup --category Media
```

## Running Tests
After installing lest, simply run `lest` from the command line to run all tests within all test suites. You may use the `-t` argument to filter which tests to run. The `-e` argument can be used to determine which test suite to run. `lest env list` will list out all available test suites.

## Adding Images to the ImageSet Spritesheet
Reach out to the [Foundation team in Slack](https://rbx.enterprise.slack.com/archives/C07HG449HNZ) to request for an image to be added to the ImageSet spritesheet.

## Consumers of Foundation

### LuaApps
[LuaApps](https://github.com/Roblox/lua-apps) is the main consumer of Foundation.

#### Merging to LuaApps
Once the next version of Foundation is released, it will be updated in [LuaApps](https://github.com/Roblox/lua-apps).

- Create a branch for your upgrade PR for [LuaApps](https://github.com/Roblox/lua-apps) repo
- Navigate to `content/LuaPackages` in your [LuaApps](https://github.com/Roblox/lua-apps) repo
- Bump the version to the desired version number (e.g. 1.5.0 -> 1.6.0) in the [rotriever.toml](https://github.com/Roblox/lua-apps/blob/master/content/LuaPackages/rotriever.toml) file
- Run `rotrieve install` to pull in the latest changes
- Commit everything to your upgrade branch and create a PR for review
- Squash and merge once approved

### Other Consumers
*Are you using Foundation in your project? Let us know in our [Slack channel](https://rbx.enterprise.slack.com/archives/C07HG449HNZ)!*
