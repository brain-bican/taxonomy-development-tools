if not exist %homedrive%%homepath%\tdt_datasets mkdir %homedrive%%homepath%\tdt_datasets

docker run -v %cd%:/work -v %homedrive%%homepath%\tdt_datasets:/tdt_datasets -w /work --rm -ti -p 3000:3000 -p 8000:8000 -e "GITHUB_AUTH_TOKEN=$GH_TOKEN" --env "GITHUB_USER=$GITHUB_USER" --env "GITHUB_EMAIL=$GITHUB_EMAIL" ghcr.io/brain-bican/taxonomy-development-tools %*