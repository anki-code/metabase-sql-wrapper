#!/usr/bin/env xonsh

import subprocess, signal

class Process:
    """
    Process class catches the signals and wait for the process end or interrupt.
    """
    stop_now = False
    def __init__(self, cmd):
        for s in [signal.SIGINT, signal.SIGTERM]:
            signal.signal(s, self.proc_terminate)

        proc = subprocess.Popen(cmd, shell=True)
        self.proc = proc
        self.pid = proc.pid
        proc.wait()

    def proc_terminate(self, signum, frame):
        echo @(f'*** CATCH: signum={signum}, stopping the process...')
        self.proc.terminate()
        self.stop_now = True

if __name__ == '__main__':
    echo '*** Metabase SQL wrapper [https://github.com/anki-code/metabase-sql-wrapper]'

    metabase_jar = '/app/metabase.jar'

    metabase_db_path = ${...}.get('MB_DB_FILE', '/data/metabase')
    metabase_db_path = fp'{metabase_db_path}'

    metabase_db_path_exists = metabase_db_path.exists()
    if metabase_db_path_exists:
        echo @(f'*** Metabase DB path: {metabase_db_path}')
    else:
        mkdir -p @(metabase_db_path)
        echo @(f'*** Metabase DB path created: {metabase_db_path}')

    metabase_db_file = metabase_db_path / metabase_db_path.name

    init_sql_file = ${...}.get('MB_DB_INIT_SQL_FILE')

    if pf'{init_sql_file}'.exists():
        if metabase_db_path_exists:
            echo @(f'*** Database path {metabase_db_path} exists, SKIP creating database from {init_sql_file}')
        else:
            echo @(f'*** Create database {metabase_db_file} from {init_sql_file}')
            java -cp @(metabase_jar) org.h2.tools.RunScript -url jdbc:h2:@(metabase_db_file) -script @(init_sql_file)
            echo '*** Creating DONE'
    else:
        echo @(f'*** MB_DB_INIT_SQL_FILE {init_sql_file} not found, SKIP')

    p = Process('/app/run_metabase.sh')

    save_sql_file = ${...}.get('MB_DB_SAVE_TO_SQL_FILE')
    if save_sql_file:
        echo @(f'*** Saving database {metabase_db_file} to {save_sql_file}')
        java -cp @(metabase_jar) org.h2.tools.Script -url jdbc:h2:@(metabase_db_file) -script @(save_sql_file)
        echo @('*** Saving DONE')