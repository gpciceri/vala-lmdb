# vala-lmdb
vala (and genie) interface (.vapi) to LMDB key-value store (from OpenLDAP)

2016.08.17 - initial release. only to run the vala-equivalent to sample-mdb program.


to build the sample (on OSX, with lmdb installed via port): from the same directory where files are

valac --vapidir . --pkg lmdb test_lmdb.vala -X -L/opt/local/lib -X -llmdb  -v

N.B. you need to create ./testdb/ database directory before running the sample.

