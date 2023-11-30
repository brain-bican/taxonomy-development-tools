# Get Taxonomy Development Tools

You can download TDT Docker image through following the steps defined in project [GitHub Container Registry](https://github.com/brain-bican/taxonomy-development-tools/pkgs/container/taxonomy-development-tools).

```
docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest
```

## Update Taxonomy Development Tools to the latest version

You can update TDT Docker image to the latest version through:

Stop running TDT containers:
```
docker stop $(docker ps -a -q --filter ancestor=ghcr.io/brain-bican/taxonomy-development-tools:latest)
```

Remove the existing TDT image and pull the latest one:

```
docker rmi $(docker images 'ghcr.io/brain-bican/taxonomy-development-tools:latest' -a -q | uniq)
docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest
```


# Install requirements

## Docker

- Install [Docker](https://www.docker.com/get-docker) and make sure its runnning properly, for example by typing `docker ps` in your terminal or command line (CMD). If all is ok, you should be seeing something like:

```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## Git

1. Setup your GitHub user configs

```
git config --global user.name "your_github_user"
git config --global user.email "your_github_email"
```

2. Create a GitHub [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic).

3. Set `GH_TOKEN` environment variable. 

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

- Test your new config: 

```
echo $GH_TOKEN
```


## Build Taxonomy Development Tools (Optional)

Users are suggested to use the [Get Taxonomy Development Tools](#get-taxonomy-development-tools) step to have a TDT Docker Image. But, alternatively, you can build TDT docker image in your local. Checkout the project and run given command in the project root folder:

```
docker build --no-cache -t "ghcr.io/brain-bican/taxonomy-development-tools" .
```