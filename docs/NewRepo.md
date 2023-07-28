# Creating a new Repository with the Taxonomy Development Tools

This is instructions on how to create a CCN2 taxonomy repository in
GitHub. This will only need to be done once per taxonomy. You may need
assistance from someone with basic unix knowledge in following
instructions here.

We will walk you though the steps to make a new ontology project

## 1. Install requirements

- [docker](https://www.docker.com/get-docker): Install Docker and make sure its runnning properly, for example by typing `docker ps` in your terminal or command line (CMD). If all is ok, you should be seeing something like:

```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

- git, for example bundled with [GitHub Desktop](https://desktop.github.com/)

## 2. Download the wrapper script and pull latest ODK version

- Linux/Mac: [seed-via-docker.sh](https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/seed-via-docker.sh)
- PC: [seed-via-docker.bat](https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/seed-via-docker.bat)
- Make sure to save the wrapper script in your working directory and that the filetype is correct.
- You should have git installed - for the repo command to work perfectly, it requires a `.gitconfig` file in your user directory!
- First, make sure you have Docker running (you will see the Docker whale in your toolbar on a Mac)
- To make sure you have the latest version of the TDT installed, run in the command line

  `docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest`

**NOTE** The very first time you run this it may be slow, while docker downloads necessary images. Don't worry, subsequent runs should be much faster!

**NOTE** Windows users, occasionally it has been reported that files downloaded on a Windows machine get a wrong file ending, for example `seed-via-docker.bat.txt` instead of `seed-via-docker.bat`, or, as we will see later, `project.yaml.txt` instead of `project.yaml`. If you have problems, double check your files are named correctly after the download!

## 3. Run the wrapper script

You can pass in a configuration file in YAML format that specifies your taxonomy project setup. You can use `dir` in your command line on PC to ensure that your wrapper script, .gitconfig, and project.yaml (if you so choose) are all in the correct directory before running the wrapper script.

### Unix (Max, Linux)

Using the predefined [CCN20230601_project_config.yaml](https://github.com/brain-bican/taxonomy-development-tools/tree/main/examples/nhp_basal_ganglia/CCN20230601_project_config.yaml) file:

    ./seed-via-docker.sh -C CCN20230601_project_config.yaml

### Windows

Using the predefined [CCN20230601_project_config.yaml](https://github.com/brain-bican/taxonomy-development-tools/tree/main/examples/nhp_basal_ganglia/CCN20230601_project_config.yaml) config file:

    seed-via-docker.bat -C CCN20230601_project_config.yaml

This will create your starter files in
`target/human_m1`. It will also prepare an initial
release and initialize a local repository (not yet pushed to your Git host site such as GitHub or GitLab).

### Problems?

There are three frequently encountered problems at this stage:

1. No `.gitconfig` in user directory
2. Spaces is user path
3. During download, your filenames got changed (Windows)

#### No `.gitconfig` in user directory

The seed-via-docker script requires a `.gitconfig` file in your user directory. If your `.gitconfig` is in a different directory, you need to change the path in the downloaded `seed-via-docker` script. For example on Windows (look at `seed-via-docker.bat`):

```
docker run -v %userprofile%/.gitconfig:/root/.gitconfig -v %cd%:/work -w /work --rm -ti brain-bican/tdt /tools/tdt.py seed %*
```

`%userprofile%/.gitconfig` should be changed to the correct path of your local `.gitconfig` file.

#### Spaces is user path

We have had reports of users having trouble if there are paths (say, `D:\data`) contain a space symbol, like `D:/Dropbox (Personal)` or similar. In this case, we recommend to find a directory you can work in that does not contain a space symbol.

You can customize at this stage, but we recommend to first push the changes to you Git hosting site (see next steps).

#### During download, your filenames got changed (Windows)

Windows users, occasionally it has been reported that files downloaded on a Windows machine get a wrong file ending,
for example `seed-via-docker.bat.txt` instead of `seed-via-docker.bat`, or, as we will see later, `project.yaml.txt`
instead of `project.yaml`. If you have problems, double-check your files are named correctly after the download!

## 4. Push to Git hosting website

The development kit will automatically initialize a git project, add all files and commit.

You will need to create a project on you Git hosting site.

_For GitHub:_

1.  Go to: https://github.com/new
2.  The owner MUST be the org you selected with the `github_org` option in the project yaml file. Repo name should be same with the `repo` option
3.  Do not initialize with a README (you already have one)
4.  Click Create
5.  See the section under "…or push an existing repository from the command line"

_For GitLab:_

1.  Go to: https://gitlab.com/projects/new
2.  The owner MUST be the org you selected with the `github_org` option in the project yaml file. Repo name should be same with the `repo` option
3.  Do not initialize with a README (you already have one)
4.  Click 'Create project'
5.  See the section under "Push an existing Git repository"

Follow the instructions there. E.g. (make sure the location of your remote is exactly correct!).

```
cd target/human_m1
git remote add origin https://github.com/hkir-dev/human_m1.git
git branch -M main
git push -u origin main
```

Note: you can now mv `target/human_m1` to anywhere you like in your home directory. Or you can do a fresh checkout from github.

## Additional

You will want to also:

- enable GitHub actions

