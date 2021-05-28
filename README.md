# pygments-server

This project provides an HTTP server that serves [pygments][],
and a shell script to implement `pygmentize` using that server.

The project is inspired by [Khan/pygments-server][];
the main difference is that it supports all `pygmentize` options,
because it wraps pygments’ command line module rather than its Python API.
(Naturally, the options to specify input and output files won’t be very useful to you
unless the script and the server run on the same file system.)

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

## Limitations

All command line arguments, as well as standard input and output, are transferred between client and server.
Things that are not transferred include:

- Local files which may be specified as input or output files.
  It’s strongly recommended to rely on stdin/stdout.
- The standard error stream.
  Any errors will probably end up in your WSGI server’s logs.
- The exit code.
  The script exits 0 unless `curl` had an error.
- Environment variables.
  Hopefully you’re using `-fhtml` and not relying on the `$TERM` variable.

Some of these are probably fixable with more or less effort,
should the need for it arise.
(So far, it has remained dormant.)

## License

[Blue Oak Model License, version 1.0.0][BlueOak-1.0.0].

[pygments]: https://pygments.org/
[Khan/pygments-server]: https://github.com/Khan/pygments-server
[WSGI]: https://www.wikidata.org/wiki/Special:GoToLinkedPage/enwiki/Q539164
[Gunicorn]: https://gunicorn.org/
[uWSGI]: https://uwsgi-docs.readthedocs.io/en/latest/
[BlueOak-1.0.0]: https://blueoakcouncil.org/license/1.0.0
