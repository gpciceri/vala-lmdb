/* test_lmdb.vala
 *
 * Copyright (C) 2016 Gian Paolo Ciceri
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	gian paolo ciceri <gp.ciceri@gmail.com>
 *
 *
 * Release:
 *  2016.08.17 - initial release. only the vala-equivalent of sample-mdb.c
 *
 */



 int main(string[] args) {

    Lmdb.Env env;
    Lmdb.Txn txn;
    Lmdb.Dbi dbi;
    Lmdb.Val key, data;
	Lmdb.Cursor cur;

    int rc;

    // which LMDB are we using?
    stdout.printf("Using: %s\n", Lmdb.version());


    // trivial tests
    stdout.printf("Test for FLAG (0x1000000): 0x%x\n", Lmdb.Envflag.NOMEMINIT);
    stdout.printf("Test for ERROR (0): %s\n", Lmdb.strerror(Lmdb.Retcode.SUCCESS));
    stdout.printf("Test for ERROR (-30788): %s\n", Lmdb.strerror(Lmdb.Retcode.TXN_FULL));


    // 0. create the environment
    // rc = mdb_env_create(&env);
	rc = Lmdb.Env.create(out env);
    stdout.printf("ENV CREATE rc: %d, %s\n", rc, Lmdb.strerror(rc));

    // 1. open the DB directory
    //rc = mdb_env_open(env, "./testdb", 0, 0664);
	rc = env.open("./testdb/", 0, 0644);
    stdout.printf("ENV OPEN rc: %d, %s\n", rc, Lmdb.strerror(rc));
    if (rc != 0){
        Process.exit(rc);
    }

    // 2. begin the transaction
    // rc = mdb_txn_begin(env, NULL, 0, &txn);
    rc = Lmdb.Txn.begin(env, null, 0, out txn);
    stdout.printf("TNX BEGIN rc: %d, %s\n", rc, Lmdb.strerror(rc));

    // 3. open the dbi
    // rc = mdb_open(txn, NULL, 0, &dbi)
    rc = Lmdb.dbi_open (txn, null, 0, out dbi);
    stdout.printf("DB OPEN rc: %d, %s\n", rc, Lmdb.strerror(rc));

    // 4. format the data
    //sprintf(sval, "%03x %d foo bar", 32, 3141592);
    string sval = "%03x %d foo bar".printf (32, 3141592);
    stdout.printf("SVAL: '%s' - len: %d.\n", sval, sval.length);

    key = {sizeof(int), sval};
    data = {(size_t)sval.length, sval};

    // 5. put the data in the db
    rc = Lmdb.put(txn, dbi, key, data, 0);
    stdout.printf("TNX PUT rc: %d, %s\n", rc, Lmdb.strerror(rc));

    rc = txn.commit();
    stdout.printf("TNX COMMIT rc: %d, %s\n", rc, Lmdb.strerror(rc));

    // 6. now read, open a R/O txn
    rc = Lmdb.Txn.begin(env, null, Lmdb.Envflag.RDONLY, out txn);
    stdout.printf("TNX BEGIN (R/O) rc: %d, %s\n", rc, Lmdb.strerror(rc));

    // 7. open a cursor
    rc = Lmdb.Cursor.open(txn, dbi, out cur);
    stdout.printf("CUR OPEN rc: %d, %s\n", rc, Lmdb.strerror(rc));

    // 8. fetch results
    while ((rc = cur.get(key, data, Lmdb.Cursor_op.NEXT)) == 0) {
        stdout.printf("key.length: %d, data.length: %d\n", (int) key.mv_size, (int) data.mv_size);
        stdout.printf("key: %p ; '%.*s', data: %p ; '%.*s'\n",
            key.mv_data,  (int) key.mv_size,  (char *) key.mv_data,
            data.mv_data, (int) data.mv_size, (char *) data.mv_data);
    }
    // close the cursor
    cur.close();
    // abort the transaction, we don't need it anymore
    txn.abort();
    // close the database
    env.closeDbi(dbi);
    // close the environment
	env.close();

    return 0;
}
