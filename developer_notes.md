### TODO LIST

- [x] generate tables
- [x] clean nanobot dependencies to speed it up
- [ ] read variables from config
- [x] run.sh and run.bat auto generate
- [x] mkdocs documentation
- [ ] Config file schema and validation action
- [ ] validation action auto generate
- [x] nanobot integration
- [x] nanobot not saving autocomplete value (validation fail?)
- [ ] ** droid integration for release management
- [ ] *** save is only updating DB. Add save button to export data
- [ ] ** ontodev.Makefile save is changing order of entities


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

bash ./run.sh make save
```

http://127.0.0.1:5004/table