# Notes about the systemd units

If you want to use it as persistent services instead as socked notified one, you could remove the directive `Requires=pygments-server.socket` and modify the type to `Type=exec` in the file `/etc/systemd/system/pygments-server.service` and remove the file `/etc/systemd/system/pygments-server.socket`. Then restart and enable the service and remove the socket:

```bash
sudo systemctl enable pygments-server.service
sudo rm /etc/systemd/system/pygments-server.socket
sudo systemctl daemon-reload
sudo systemctl restart pygments-server.service
```

In this scenario you must use `pygmentize` instead of `systemd.pygmentize` as connector script, so you will need to recreate `/usr/local/bin/pygmentize`. The difference between the both scripts is at the last line.

## References

* [Gunicorn Docs Systemd](https://docs.gunicorn.org/en/latest/deploy.html#systemd)
* [Freedesktop.org Systemd directives](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
* [Drumcoder.co.uk Systemd and Gunicorn](https://drumcoder.co.uk/blog/2018/feb/04/systemd-and-gunicorn/)
