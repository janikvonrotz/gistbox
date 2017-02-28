First let's see which is latest relase of ruby.

Download Ruby from the offical ftp server where `[version]` has to replaced with the latest release.

    cd /usr/local/src
    sudo wget http://ftp.ruby-lang.org/pub/ruby/ruby-[version].tar.gz

Untar the downloaded package.
   
    sudo tar -xzvf ruby-[version].tar.gz
    sudo rm ruby-[version].tar.gz
    cd ruby-[version]/
    
Compile ruby.

    sudo ./configure
    sudo make
    sudo make install

Check the Ruby version.

    ruby -v

If everything's ok clone RubyGems from GitHub.

    cd /usr/local/src
    sudo git clone https://github.com/rubygems/rubygems.git

And install it with Ruby.

    cd rubygems/
    sudo ruby setup.rb
    
Check the RubyGems version.

    gem -v