# Systemd service deployment

The script [`systemd.deploy.sh`](../systemd.deploy.sh) will create a systemd service file and a socket file and will enable the socket. Initially it will install the depends. The service uses `gunicorn`, so if it is available the existing installation will be used, otherwise you will be asked to install it. I will recommend to use an OS package for `gunicorn` if it is available - i.e. `apt install gunicorn`. Finally the script will create `/usr/local/bin/pygmentize` as a copy of the file [`systemd.pygmentize`](../systemd.pygmentize). If the file `pygmentize.env` exists it will be also supplied to the directory `/usr/local/bin`.

The service will be created for the current user who possess the repository. All environment variables will be detected automatically, however you can override them via the `pygmentize.env` file. For example if you want to change the number of the workers to `2` set `GUNICORN_WORKERS=2`. For the rest parameters available see the beginning of the `systemd.deploy.sh` file.

Note the files in the directory [`systemd.units/`](../systemd.units/) are just templates and the actual values will be assigned via the deployment script. So if you want to change something add the necessary parameters to the `pygmentize.env` file and rerun `systemd.deploy.sh`.

## Use persistent service instead of socket file

If you want to use it as persistent services instead as socked notified one, you could remove the directive `Requires=pygments-server.socket` and modify the type to `Type=exec` in the file `/etc/systemd/system/pygments-server.service` and remove the file `/etc/systemd/system/pygments-server.socket`. Then restart and enable the service and remove the socket:

```bash
sudo systemctl enable pygments-server.service
sudo rm /etc/systemd/system/pygments-server.socket
sudo systemctl daemon-reload
sudo systemctl restart pygments-server.service
```

In this scenario you must use `pygmentize` instead of `systemd.pygmentize` as connector script, so you will need to recreate `/usr/local/bin/pygmentize`. The difference between the both scripts is at the last line.

## Remove the service

In order to remove the service you need to remove the following files:

```bash
/etc/systemd/system/pygments-server.service
/etc/systemd/system/pygments-server.socket
/usr/local/bin/pygmentize
/usr/local/bin/pygmentize.env
```

## References

* [Gunicorn Docs Systemd](https://docs.gunicorn.org/en/latest/deploy.html#systemd)
* [Freedesktop.org Systemd directives](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
* [Drumcoder.co.uk Systemd and Gunicorn](https://drumcoder.co.uk/blog/2018/feb/04/systemd-and-gunicorn/)
