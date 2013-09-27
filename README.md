TODO
==================

work on host
-----------------------------
1.  install vagrant & virtualbox
2.  create dir and change to
    `c:\www\`
    &
    `git clone https://github.com/tmagiera/digital-insight.git`
    &
    change dir to
    `c:\www\digital-insight`
3.  change your hosts file:

    ```
    192.168.56.101	digital-insight.dev
    ```

4.  run in cmd :

    ```
    vagrant up
    ```

5.  standard vagrant ssh won't work properly on Windows so use puttygen to load Linux ssh key from
    `C:/Users/tmagiera/.vagrant.d/insecure_private_key`
    and save in Putty format to
    `C:/Users/tmagiera/.vagrant.d/key.ppk`
6.  connect SSH to `vagrant@192.168.56.101` with key from `C:/Users/tmagiera/.vagrant.d/key.ppk` (connection->SSH->Auth)


work on server
-----------------------------
1.  change time zone in php.ini to
    ```
    date.timezone = "Europe/London"
    ```
    in `/etc/php5/apache2/php.ini` & `/etc/php5/cli/php.ini`
    seems to be know bug in puphpet : https://github.com/puphpet/puphpet/issues/135
    we could switch back to php 5.4 but i think that it is just better to wait for a change in a puphpet

    ```
    sudo /etc/init.d/apache2 restart
    ```

    should work! http://digital-insight.dev/web/app_dev.php

2.  odbc install based on http://www.codesynthesis.com/~boris/blog/2011/12/02/microsoft-sql-server-odbc-driver-linux/
    changed for RedHat6
    ```Shell
    cd /home/vagrant
    cp /var/www/install/msodbcsql-11.0.2270.0.tar.gz /home/vagrant/
    tar -xzf msodbcsql-11.0.2270.0.tar.gz

    wget ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.0.tar.gz
    tar -xzf unixODBC-2.3.0.tar.gz
    cd unixODBC-2.3.0/
    ./configure --disable-gui --disable-drivers --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE
    make
    sudo make install


    echo "/usr/local/lib/" > /etc/ld.so.conf.d/redhat6
    sudo apt-get install libssl1.0.0
    cd /usr/lib/
    sudo ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 libssl.so.10
    sudo ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 libcrypto.so.10

    cd /home/vagrant/msodbcsql-11.0.2270.0/
    sudo bash ./install.sh install --force`
    ```

    odbc installed, some additional config, just for confirmation that works
    in shell
    ```
    isql -v accord_dev USER PASS
    ```
    in php
    ```
    php connection.php
    ```