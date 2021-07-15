# -*- coding: utf-8 -*-

import io
import sys

import flask
import pygments.cmdline


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
        sys.stdout = io.BytesIO()
        sys.stdout.buffer = sys.stdout
        __builtins__['open'] = no_open

        args = flask.request.args.getlist('args')
        pygments.cmdline.main(['pygmentize', *args])

        return sys.stdout.getvalue()
    finally:
        sys.stdin = sys.__stdin__
        sys.stdout = sys.__stdout__
        __builtins__['open'] = real_open
