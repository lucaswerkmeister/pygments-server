# -*- coding: utf-8 -*-

import io
import sys

import flask
import pygments.cmdline


app = flask.Flask(__name__)


@app.post('/')
def index():
    try:
        sys.stdin = io.BytesIO(flask.request.data)
        sys.stdin.buffer = sys.stdin
        sys.stdout = io.BytesIO()
        sys.stdout.buffer = sys.stdout

        args = flask.request.args.getlist('args')
        pygments.cmdline.main(['pygmentize', *args])

        return sys.stdout.getvalue()
    finally:
        sys.stdin = sys.__stdin__
        sys.stdout = sys.__stdout__
