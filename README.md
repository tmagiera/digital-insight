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

    cp /var/www/install/unixODBC-2.3.0.tar.gz /home/vagrant
    tar -xzf unixODBC-2.3.0.tar.gz
    cd unixODBC-2.3.0/
    ./configure --disable-gui --disable-drivers --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE
    make
    sudo make install


    echo "/usr/local/lib/" > /etc/ld.so.conf.d/redhat6
    sudo ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/local/lib/libssl.so.10
    sudo ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/local/lib/libcrypto.so.10

    cd /home/vagrant/msodbcsql-11.0.2270.0/
    sudo bash ./install.sh install --force
    ```

    odbc installed, some additional config
    ```
    sudo cp /var/www/files/odbc.ini /usr/local/etc/
    ```

    just for confirmation that works
    in shell
    ```
    isql -v mssql_dev USER PASS (<- dev db)
    ```
    in php, change USER and PASS (<- dev db)
    ```
    php connection.php
    ```

3.  pretty URLs for application to change in /etc/apache2/sites-enabled/1-digital-insight.dev.conf

```
<VirtualHost *:80>
    ServerAdmin webmaster@digital-insight.dev
    DocumentRoot /var/www/web/
    <Directory /var/www/web/>
        DirectoryIndex app_dev.php
        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteCond %{REQUEST_URI}::$1 ^(/.+)/(.*)::\2$
            RewriteRule ^(.*) - [E=BASE:%1]
            RewriteCond %{ENV:REDIRECT_STATUS} ^$
            RewriteRule ^app_dev\.php(/(.*)|$) %{ENV:BASE}/$2 [R=301,L]
            RewriteCond %{REQUEST_FILENAME} -f
            RewriteRule .? - [L]
            RewriteRule .? %{ENV:BASE}/app.php [L]
        </IfModule>

        <IfModule !mod_rewrite.c>
            <IfModule mod_alias.c>
                RedirectMatch 302 ^/$ /app_dev.php/
            </IfModule>
        </IfModule>
        Order allow,deny
        Allow from All
    </Directory>

    ServerName digital-insight.dev
    ServerAlias digital-insight.dev

    ErrorLog  /var/log/apache2/digital-insight.dev-error_log
    CustomLog /var/log/apache2/digital-insight.dev-access_log common
</VirtualHost>
```

    now applicaton should be visible in URL : http://digital-insight.dev/