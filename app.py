# -*- coding: utf-8 -*-

import io
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


def no_open(file, mode='r', *args, **kwargs):
    """Fake open() function that always return empty objects."""
    if 'b' in mode:
        return io.BytesIO()
    else:
        return io.StringIO()


real_open = open


app = flask.Flask(__name__)


@app.post('/')
def index():
    try:
        sys.stdin = io.BytesIO(flask.request.data)
        sys.stdin.buffer = sys.stdin
        sys.stdout = AnyIO()
        sys.stdout.buffer = sys.stdout
        __builtins__['open'] = no_open

        args = flask.request.args.getlist('args')
        pygments.cmdline.main(['pygmentize', *args])

        return sys.stdout.getvalue()
    finally:
        sys.stdin = sys.__stdin__
        sys.stdout = sys.__stdout__
        __builtins__['open'] = real_open
