::BATCH file to seed new taxonomy repo via docker
docker run -v %userprofile%/.gitconfig:/root/.gitconfig -v %cd%:/work -w /work --rm -ti brain-bican/tdt /tools/tdt.py seed %*