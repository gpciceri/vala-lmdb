/* lmdb.vapi
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
 *  2016.08.17 - initial release. only to run the vala-equivalent of sample-mdb.c
 *
 */



[CCode (lower_case_cprefix = "lmdb_", cheader_filename = "lmdb.h")]
namespace Lmdb {

    [CCode (cname = "MDB_VERSION_MAJOR")]
    public const int VERSION_MAJOR;
    [CCode (cname = "MDB_VERSION_MINOR")]
    public const int VERSION_MINOR;
    [CCode (cname = "MDB_VERSION_PATCH")]
    public const int VERSION_PATCH;
    [CCode (cname = "MDB_VERSION_FULL")]
    public const int VERSION_FULL;
    [CCode (cname = "MDB_VERSION_DATE")]
    public const string VERSION_DATE;
    [CCode (cname = "MDB_VERSION_STRING")]
    public const string VERSION_STRING;


    [CCode (cname = "int", cprefix = "MDB_", has_type_id = false)]
    public enum Cursor_op {
    	FIRST,
    	FIRST_DUP,
    	GET_BOTH,
    	GET_BOTH_RANGE,
    	GET_CURRENT,
    	GET_MULTIPLE,
    	LAST,
    	LAST_DUP,
    	NEXT,
    	NEXT_DUP,
    	NEXT_MULTIPLE,
    	NEXT_NODUP,
    	PREV,
    	PREV_DUP,
    	PREV_NODUP,
    	SET,
    	SET_KEY,
    	SET_RANGE
    }

    [CCode (cname = "int", cprefix = "MDB_", has_type_id = false)]
    public enum Retcode {
        SUCCESS,
        KEYEXIST,
        NOTFOUND,
        PAGE_NOTFOUND,
        CORRUPTED,
        PANIC,
        VERSION_MISMATCH,
        INVALID,
        MAP_FULL,
        DBS_FULL,
        READERS_FULL,
        TLS_FULL,
        TXN_FULL,
        CURSOR_FULL,
        PAGE_FULL,
        MAP_RESIZED,
        INCOMPATIBLE,
        BAD_RSLOT,
        BAD_TXN,
        BAD_VALSIZE,
        BAD_DBI,
        LAST_ERRCODE
    }


    [CCode (cname = "int", cprefix = "MDB_", has_type_id = false)]
    public enum Envflag {
        FIXEDMAP,
        NOSUBDIR,
        NOSYNC,
        RDONLY,
        NOMETASYNC,
        WRITEMAP,
        MAPASYNC,
        NOTLS,
        NOLOCK,
        NORDAHEAD,
        NOMEMINIT
    }

    [CCode (cname = "int", cprefix = "MDB_", has_type_id = false)]
    public enum Openflag {
        REVERSEKEY,
        DUPSORT,
        INTEGERKEY,
        DUPFIXED,
        INTEGERDUP,
        REVERSEDUP,
        CREATE
    }

    [CCode (cname = "int", cprefix = "MDB_", has_type_id = false)]
    public enum Writeflag {
        NOOVERWRITE,
        NODUPDATA,
        CURRENT,
        RESERVE,
        APPEND,
        APPENDDUP,
        MULTIPLE
    }

    [CCode (cname = "int", cprefix = "MDB_", has_type_id = false)]
    public enum Copyflag {
        CP_COMPACT
    }

    [CCode (cname = "mdb_version")]
    public unowned string version(int? major = null, int? minor=null, int? patch=null);
    [CCode (cname = "mdb_strerror")]
    public unowned string strerror(int err);

    [SimpleType]
    [IntegerType (rank = 9)]
    [CCode (cname = "mdb_mode_t", has_type_id = false)]
    public struct MdbModeType {
    }


    [Compact, CCode (cname = "MDB_env", cprefix = "mdb_", free_function = "")]
    public class Env {

        [CCode (cname = "mdb_env_create", cprefix = "mdb_")]
        public static int create (out Env env);


        [CCode (cname = "mdb_env_open", cprefix = "mdb_")]
        public int open (string path, uint flags = 0, MdbModeType mode = 0644);


        //void mdb_dbi_close(MDB_env *env, MDB_dbi dbi);
        [CCode (cname = "mdb_dbi_close", cprefix = "mdb_")]
        public void closeDbi (Dbi dbi);

        //void mdb_env_close(MDB_env *env);
        [CCode (cname = "mdb_env_close", cprefix = "mdb_")]
        public void close ();


        }


    [Compact, CCode (cname = "MDB_txn", cprefix = "mdb_", free_function = "")]
    public class Txn {

        [CCode (cname = "mdb_txn_begin", cprefix = "mdb_")]
        public static int begin (Env env, Txn? parent_txn, int flags, out Txn txn);

        [CCode (cname = "mdb_txn_commit", cprefix = "mdb_")]
        public int commit();

        [CCode (cname = "mdb_txn_abort", cprefix = "mdb_")]
        public void abort();

        }

    // now open the database

    // typedef unsigned int	MDB_dbi;
    [SimpleType]
    [CCode (cname = "MDB_dbi", has_type_id = false)]
    public struct Dbi : uint {
    }

    // int  mdb_dbi_open(MDB_txn *txn, const char *name, unsigned int flags, MDB_dbi *dbi);
    [Compact, CCode (cname = "mdb_dbi_open", cprefix = "mdb_", free_function = "mdb_dbi_close")]
    public int dbi_open (Txn txn, string? name, uint flags, out Dbi dbi);


    // build MDB key and value
    [Compact, CCode (cname = "MDB_val", cprefix = "mdb_")]
    public struct Val {
        size_t		 mv_size;
        void         *mv_data;
        }

    // mdb_put(txn, dbi, &key, &data, 0);
    [Compact, CCode (cname = "mdb_put", cprefix = "mdb_")]
    public int put(Txn txn, Dbi dbi, Val key, Val data, uint flags);


    // the cursor
    // int  mdb_cursor_open(MDB_txn *txn, MDB_dbi dbi, MDB_cursor **cursor);
    [Compact, CCode (cname = "MDB_cursor", cprefix = "mdb_", free_function = "")]
    public class Cursor {

        [CCode (cname = "mdb_cursor_open", cprefix = "mdb_")]
        public static int open (Txn txn, Dbi dbi, out Cursor cur);


        [CCode (cname = "mdb_cursor_close", cprefix = "mdb_")]
        public void close ();

        // int  mdb_cursor_get(MDB_cursor *cursor, MDB_val *key, MDB_val *data, MDB_cursor_op op);
        [Compact, CCode (cname = "mdb_cursor_get", cprefix = "mdb_")]
        public int get(Val? key, Val? data, Cursor_op op);


        }



}
