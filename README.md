# pygments-server

This project provides an HTTP server that serves [pygments][],
and a shell script to implement `pygmentize` using that server.

The project is inspired by [Khan/pygments-server][];
the main difference is that it supports all `pygmentize` options,
because it wraps pygments’ command line module rather than its Python API.
It also supports input files in addition to standard input.

## Server usage

The server is a [WSGI][] application, implemented using the Flask framework.
After installing its dependencies (`pip install -r requirements.txt`),
you can run it using any WSGI server, such as:

- Flask’s own development server (recommended for development purposes only):

  ```sh
  FLASK_APP=app.py flask run --port 7879
  ```
  
- [Gunicorn][]:

  ```sh
  gunicorn --workers=4 --bind=:7879 app:app
  ```
  
- [uWSGI][]:

  ```sh
  uwsgi --processes 4 --http :7879 --wsgi-file app.py --callable app
  ```

Try to set up the server in such a way that it doesn’t have read access to any files that should not be public.
`pygments-server` attempts to prevent pygments from reading any files on the server,
but you shouldn’t rely on that alone as protection from attackers pygmentizing `/etc/shadow` or the like.

## Client usage

The `pygmentize` script included here is a drop-in replacement for the real one.
By default, it connects to `localhost`, port 7879
(the same port used in the server examples above);
you can override these with the `PYGMENTIZE_HOST` and `PYGMENTIZE_PORT` environment variables.

In case you’re using a program that expects to call `pygmentize` with no special environment variables,
you can also customize the host and port by placing them in a `pygmentize.env` file.
The file should be in the same directory as the `pygmentize` script, and look like this:

```sh
PYGMENTIZE_HOST=pygments-server.example
PYGMENTIZE_PORT=1234
```

Either line can be left out if you want to use the default.

The script will attempt to read from standard input regardless of command-line options,
since the command line will only be parsed on the server.
If you don’t need to use standard input,
you can skip this by setting the `PYGMENTIZE_NO_STDIN` environment variable (to any value).
When reading standard input from a terminal,
the script will also print a note (to avoid confusing users),
which you can suppress with the `PYGMENTIZE_NO_STDIN_WARNING` environment variable.

## Limitations

The following things are transferred between client and server:

- All command line arguments (client to server).
- Standard input (client to server) and standard output (server to client).
- Input files (client to server).
  Specifically, for any command line argument that exists as a file,
  the contents of the file are made available to the server.
  The wrapper script doesn’t know which of these arguments will actually be read as files by pygments
  (e.g. if you use `-l sh` and the current working directory is `/bin`,
  the contents of `/bin/sh` will be sent to the server);
  for the same reason, any files which aren’t listed as separate arguments
  (e.g. some kind of `--input=filename` option)
  won’t be transferred either.
- The boolean status of the exit code (zero or nonzero).

The following things are not transferred between client and server:

- Standard error (server to client).
  Any errors will probably end up in your WSGI server’s logs.
- Any output files (server to client).
  You must use stdout for output.
- The exact exit code.
  If pygments returns a nonzero exit code,
  the server returns HTTP 500 Internal Server Error,
  which makes `curl` exit with status 22.
  Any other nonzero exit status from the script signifies some other `curl` error.
- Environment variables (client to server).
  Hopefully you’re using `-fhtml` and not relying on the `$TERM` variable.

Some of these are probably fixable with more or less effort,
should the need for it arise.
(So far, it has remained dormant.)

## Systemd service deployment

The script [`systemd.deploy.sh`](systemd.deploy.sh) will create a systemd service file and a socket file and will enable the socket. Initially it will install the depends. The service uses `gunicorn`, so if it is available the existing installation will be used, otherwise you will be asked to install it. I will recommend to use an OS package for `gunicorn` if it is available - i.e. `apt install gunicorn`. Finally the script will create `/usr/local/bin/pygmentize` as a copy of the file [`systemd.pygmentize`](systemd.pygmentize).

The service will be created for the current user who possess the repository. All environment variables will detected automatically, however you can override them via the `pygmentize.env` file. For example if you want to change the number of the workers to `2` set `GUNICORN_WORKERS=2`. For the rest parameters available see the beginning of the `systemd.deploy.sh` file.

Note the files in the directory [`systemd.units/`](systemd.units/) are just templates and the actual values will be assigned via the deployment script. So if you want to change something add the necessary parameters to the `pygmentize.env` file and rerun `systemd.deploy.sh`.

## License

[Blue Oak Model License, version 1.0.0][BlueOak-1.0.0].

[pygments]: https://pygments.org/
[Khan/pygments-server]: https://github.com/Khan/pygments-server
[WSGI]: https://www.wikidata.org/wiki/Special:GoToLinkedPage/enwiki/Q539164
[Gunicorn]: https://gunicorn.org/
[uWSGI]: https://uwsgi-docs.readthedocs.io/en/latest/
[BlueOak-1.0.0]: https://blueoakcouncil.org/license/1.0.0
