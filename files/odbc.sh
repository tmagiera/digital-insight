echo "Copy&unpack MSSQL ODBC"
cd /home/vagrant
cp /var/www/install/msodbcsql-11.0.2270.0.tar.gz /home/vagrant/
tar -xzf msodbcsql-11.0.2270.0.tar.gz

echo "Download&unpack UnixODBC"
wget ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.0.tar.gz
tar -xzf unixODBC-2.3.0.tar.gz

echo "Compile UnixODBC"
cd unixODBC-2.3.0/
./configure --disable-gui --disable-drivers --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE
make
sudo make install

echo "Fix broken MSSQL library dependencies (RedHat6)"
sudo echo "/usr/local/lib/" > /etc/ld.so.conf.d/redhat6
sudo apt-get install libssl1.0.0
cd /usr/lib/
sudo ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 libssl.so.10
sudo ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 libcrypto.so.10

echo "Install MSSQL ODBC"
cd /home/vagrant/msodbcsql-11.0.2270.0/
sudo bash ./install.sh install --force

echo "Configure local ODBC connection"
sudo cp /var/www/digital-insight/files/odbc.ini /usr/local/etc/odbc.ini