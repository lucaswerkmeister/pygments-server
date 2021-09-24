# -*- coding: utf-8 -*-

from errno import ENOENT
import io
from os import strerror
import sys

import flask
import pygments.cmdline


class AnyIO(io.IOBase):
    """A combination of StringIO and BytesIO
       that supports writing str and bytes."""

    def __init__(self):
        self.bytes_io = io.BytesIO()
        self.string_io = io.TextIOWrapper(self.bytes_io)

    def write(self, content):
        if isinstance(content, str):
            return self.string_io.write(content)
        else:
            return self.bytes_io.write(content)

    def getvalue(self):
        self.string_io.flush()
        return self.bytes_io.getvalue()


def request_open(file, *args, **kwargs):
    """Fake open() function that returns a matching file
       from the flask request. (The mode is ignored.)

       If there is no matching file, for files below sys.path,
       perform a real open; otherwise, report file not found."""
    for request_file in flask.request.files.getlist('file'):
        if request_file.filename == file:
            return request_file.stream
    for path in sys.path:
        if file.startswith(path + '/'):
            return real_open(file, *args, **kwargs)
    raise FileNotFoundError(ENOENT, strerror(ENOENT))


real_open = open


app = flask.Flask(__name__)


@app.post('/')
def index():
    try:
        sys.stdin = request_open('/dev/stdin')
        sys.stdin.buffer = sys.stdin
        sys.stdout = AnyIO()
        sys.stdout.buffer = sys.stdout
        __builtins__['open'] = request_open

        args = flask.request.args.getlist('args')
        pygments.cmdline.main(['pygmentize', *args])

        return sys.stdout.getvalue()
    finally:
        sys.stdin = sys.__stdin__
        sys.stdout = sys.__stdout__
        __builtins__['open'] = real_open
