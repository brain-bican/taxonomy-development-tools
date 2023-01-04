### TODO LIST

- [x] generate tables
- [x] clean nanobot dependencies to speed it up
- [ ] read variables from config
- [x] run.sh and run.bat auto generate
- [x] mkdocs documentation
- [ ] Config file schema and validation action
- [ ] validation action auto generate
- [x] nanobot integration
- [ ] droid integration ???
- [x] nanobot not saving autocomplete value (validation fail?)
- [ ] *** save is only updating DB. Add save button to export data


### Docker Commands

```
docker build -t "brain-bican/tdt" .
```

```
$ python tdt/tdt.py seed -C examples/human_m1/CCN201912131_project_config.yaml
```

### CLI Commands

```
./seed-via-docker.sh -C CCN202204130_project_config.yaml
bash ./run.sh make build_nomenclature_tables
bash ./run.sh make load
bash ./run.sh /tools/run_nanobot.py
```

http://127.0.0.1:5004/table