# Get Taxonomy Development Tools

You can download TDT Docker image through following the steps defined in project [GitHub Container Registry](https://github.com/brain-bican/taxonomy-development-tools/pkgs/container/taxonomy-development-tools).

```
docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest
```

## Update Taxonomy Development Tools to the latest version

If you already have a version of TDT Docker image and want to update it to the latest version, you can follow these steps:

Stop the running TDT containers:
```
docker stop $(docker ps -a -q --filter ancestor=ghcr.io/brain-bican/taxonomy-development-tools:latest)
```

Remove the existing TDT image and pull the latest one:
```
docker rmi $(docker images 'ghcr.io/brain-bican/taxonomy-development-tools:latest' -a -q | uniq)
docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest
```

# Install Requirements

## Docker

- Install [Docker](https://www.docker.com/get-docker) and make sure its runnning properly, for example by typing `docker ps` in your terminal or command line (CMD). If all is ok, you should be seeing something like:

```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## Git

1. Make sure you have [Git installed](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

2. Set up your GitHub user configs

```
git config --global user.name "your_github_user"
git config --global user.email "your_github_email"
```

3. Create a GitHub [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic).

4. Set `GH_TOKEN` environment variable. 

**_For Linux and MacOS:_**

- You can use `nano` or any other editor to edit the files.

For bash (Linux):
```
nano ~/.bashrc
```

For zshrc (MacOS):
```
nano ~/.zshrc
```

- When the file opens, add the environment variable in a new line:

```
export GH_TOKEN=my_github_personal_access_token_here`
```

- Reinitialize the configuration file to apply the changes to the current session:

`source ~/.bashrc` or `source ~/.zshrc`

- Test your new config open a new Terminal and run: 

```
echo $GH_TOKEN
```

**_For Windows:_**
```
setx GH_TOKEN my_github_personal_access_token_here
```

- To test your new config open a new Command Prompt (Terminal) and run:
```
echo %GH_TOKEN%
```

## Build Taxonomy Development Tools (Optional)

This step is optional and specifically aimed at users interested in utilizing the development branch of the TDT. Please note that the development branch may exhibit instability.

For those looking to use the TDT, it's recommended to follow the [Get Taxonomy Development Tools](#get-taxonomy-development-tools) section to obtain a TDT Docker Image. However, as an alternative, you have the option to build the TDT Docker image locally. To do this, clone the project repository and execute the provided command within the root directory of the project:

```
docker build --no-cache -t "ghcr.io/brain-bican/taxonomy-development-tools" .
```