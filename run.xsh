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

    env = __xonsh__.env
    env.register('MB_JAR', 'path', default='/app/metabase.jar')
    env.register('MB_DB_PATH', 'path', default='/data/metabase')
    env.register('MB_DB_INIT_SQL_FILE', 'path')
    env.register('MB_DB_SAVE_TO_SQL_FILE', 'path')

    $MB_DB_FILE = $MB_DB_PATH / $MB_DB_PATH.name

    if $MB_DB_PATH.exists():
        echo @(f'*** Metabase DB path: {$MB_DB_PATH}')
        db_path_exists = True
    else:
        if ![mkdir -p $MB_DB_PATH]:
            echo @(f'*** Metabase DB path created: {$MB_DB_PATH}')
            db_path_exists = False
        else:
            exit(1)

    if $MB_DB_INIT_SQL_FILE and $MB_DB_INIT_SQL_FILE.exists():
        if db_path_exists:
            echo @(f'*** Database path {$MB_DB_PATH} exists, SKIP creating database from {$MB_DB_INIT_SQL_FILE}')
        else:
            echo @(f'*** Create database {$MB_DB_FILE} from {$MB_DB_INIT_SQL_FILE}')
            java -cp $MB_JAR org.h2.tools.RunScript -url jdbc:h2:$MB_DB_FILE -script $MB_DB_INIT_SQL_FILE
            echo '*** Creating DONE'
    else:
        echo @(f'*** MB_DB_INIT_SQL_FILE {$MB_DB_INIT_SQL_FILE} not found, SKIP')

    p = Process('/app/run_metabase.sh')

    if $MB_DB_SAVE_TO_SQL_FILE:
        echo @(f'*** Saving database {$MB_DB_FILE} to {$MB_DB_SAVE_TO_SQL_FILE}')
        java -cp $MB_JAR org.h2.tools.Script -url jdbc:h2:$MB_DB_FILE -script $MB_DB_SAVE_TO_SQL_FILE
        echo @('*** Saving DONE')
    else:
        echo @(f'*** MB_DB_SAVE_TO_SQL_FILE not found, SKIP')