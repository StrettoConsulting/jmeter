# jmeter Docker Image
Use this image to quickly / easily run jmeter tests via CLI.

The image's `latest` tag currently uses jmeter version 5.1.

For more information on how to use jmeter via CLI please see the [jmeter docs](https://jmeter.apache.org/usermanual/get-started.html).

## Default Option(s)

#### Option: `-n` (no-gui)
You do not need to specify the `-n` flag for the `jmeter` command.  As this image is intended to be a CLI tool, the `-n` flag will be added by default to all commands.

#### Dashboard Options
If you provide the `DASHBOARD=1` environment variable, all options related to writing the dashboard will be set automatically.  See the "Output/Reports" section for additional detail and examples.

#### Default Project File
If you do not specify the `-t [filepath]` option (see section on "Loading your project file"), the container will look to see if a file has been loaded to `/project.jmx`.  See additional information under "Loading your project file".

## Loading your project file
To pass your project file (`.jmx` file) to jmeter you need to load this file as a volume via the `docker` command and then include the `-t [file]` options when running.  For example, if my project file is called `my-project.jmx` I would run the following to run the project (assuming no other options):

Linux
```bash
docker run -v $(pwd)/my-project.jmx:/my-project.jmx stretto/jmeter -t /my-project.jmx
```

Windows
```bash
docker run -v %cd%/my-project.jmx:/my-project.jmx stretto/jmeter -t /my-project.jmx
```

If you do not specify the `-t [filepath]` flag, the container will also look for a project file named `/project.jmx`. So alternatively, you may use a volume mount to load your project file to `/project.jmx` and do not need to provide the `-t [filepath]` flag.

## Output / Reports
To make things easy, if you simply set the environment variable `DASHBOARD=1`, the container will set all of the necessary flags to write a dashboard to `/opt/output/dashboard`.  
To view output files you must include a volume reference pointed to `/opt/output`.

For example, to save a results dashboard use the following command (Windows users may replace `$(pwd)` with `%cd%`:
```bash
docker run -e DASHBOARD=1 -v $(pwd)/output:/opt/output -v $(pwd)/project.jmx:/project.jmx stretto/jmeter [options]...
```
The dashboard may then be found in `./output/dashboard`

If you are using the `docker-compose.yaml` file in this repo, you may set the `JMETER_DASHBOARD=1` environment variable on your host will will then be passed into the `DASHBOARD` environment variable in the container.

The jmeter logfile will be written to `/opt/output/jmeter.log`

## Usage Examples
These examples are not intended to be comprehensive examples of the jmeter cli, but are intended to demonstrate how to use this image.

_Note:_ all examples use the Linux convention for resolving the current directory to an absolute path (i.e. $(pwd) or \`pwd\`).  Windows users should be able to replace this with %cd%

Run a basic project file named `project.jmx` (do not save output/reports):
```bash
docker run -v $(pwd)/project.jmx:/project.jmx stretto/jmeter
```

Run a project file with properties passed to the project:
```bash
docker run -v $(pwd)/project.jmx:/project.jmx stretto/jmeter -Jhost=example.com -Jsomething=else
```

Write to a custom log file
```bash
docker run -v $(pwd)/project.jmx:/project.jmx -v $(pwd)/output:/opt/output stretto/jmeter -l /opt/output/custom.log
```

Load an entire directory of project files that need to be included in a parent test file (parent.jmx):
```bash
docker run -v $(pwd)/project-files:/project-files stretto/jmeter -t /project-files/parent.jmx
```
## Using Docker Compose
Make it easy to run your test file by using the example `docker-compose.yaml` and directories provided in this repo.

Just follow these steps
1) Clone this repo
2) Save your project file in the repo directory with the name `project.jmx`
3) Make sure you have [Docker Compose](https://docs.docker.com/compose/) installed
4) From the repo root run: `docker-compose run jmeter [options]...` (do not include the `-t [file]` option as that will be included automatically via the compose file)
Simply clone this repo and run:
```bash
docker-compose run jmeter [options]...
```

## Heap Size
If you need to alter the Java Heap value simply set the `HEAP` environment variable when running.  For example:
```bash
docker run -e HEAP="-Xms512m -Xmx512m" ...
```

If you are using the `docker-compose.yaml` file provided in this repo, you may also set the `JMETER_HEAP` environment variable on your host and that value will be passed to the `HEAP` value via the compose file.
