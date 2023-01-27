---
layout  : wiki
title   : WSL에서 jekyll 기반 ghpage 세팅하기
summary :
date    : 2020-02-04 20:00:00 +0900
updated : 2020-02-21 18:30:00 +0900
tag     : record jekyll wsl
resource: 7A/8A1FBD-A544-4A8D-9A66-F720E90E6BBB
toc     : true
comment : true
public  : true
parent  : [[how-to]]
latex   : false
---
* TOC
{:toc}

깃허브 지킬을 이용한 블로그를 세팅할 때 문제가 발생해서 매번 삽질하기 번거로워 작성 ...

# Resources
1. [mcsmonk/README.md](https://github.com/mcsmonk/mcsmonk.github.io/blob/master/README.md)
2. [Jekyll doc](https://jekyllrb.com/docs/)
3. [GitHub Pages 블로그 따라하기](https://devinlife.com/howto/)

# Step
1. Jekyll 세팅
    - Windows 10 WSL 환경에서 세팅 - https://jekyllrb.com/docs/installation/windows/
    - .bashrc 에 아래 추가할 것 - https://jekyllrb.com/docs/troubleshooting/#no-sudo
      ``` sh
      # Ruby exports
      export GEM_HOME=$HOME/gems
      export PATH=$HOME/gems/bin:$PATH
      ```
    - 명령어
      ``` bash
      sudo apt-get update -y && sudo apt-get upgrade -y
      sudo apt-add-repository ppa:brightbox/ruby-ng
      sudo apt-get update
      sudo apt-get install ruby2.6 ruby2.6-dev build-essential dh-autoreconf # 가급적 ruby 최신 버전으로 ...
      gem update
      gem install jekyll bundler
      jekyll -v
      ```
    - Troubleshooting
      1. gem update
          ``` bash
          sunghyun@SUNGHYUN:~$ gem update
          ERROR:  SSL verification error at depth 1: unable to get local issuer certificate (20)
          ERROR:  You must add /C=BE/O=GlobalSign nv-sa/OU=Root CA/CN=GlobalSign Root CA to your local trusted store
          ERROR:  While executing gem ... (Gem::RemoteFetcher::FetchError)
              SSL_connect returned=1 errno=0 state=error: certificate verify failed (unable to get local issuer certificate) (https://rubygems.org/specs.4.8.gz)
          sunghyun@SUNGHYUN:~$ ruby -ropen-uri -e 'eval open("https://git.io/vQhWq").read'
          Traceback (most recent call last):
                  13: from -e:1:in `<main>'
                  12: from /usr/lib/ruby/2.6.0/open-uri.rb:35:in `open'
                  11: from /usr/lib/ruby/2.6.0/open-uri.rb:736:in `open'
                  10: from /usr/lib/ruby/2.6.0/open-uri.rb:165:in `open_uri'
                  9: from /usr/lib/ruby/2.6.0/open-uri.rb:224:in `open_loop'
                  8: from /usr/lib/ruby/2.6.0/open-uri.rb:224:in `catch'
                  7: from /usr/lib/ruby/2.6.0/open-uri.rb:226:in `block in open_loop'
                  6: from /usr/lib/ruby/2.6.0/open-uri.rb:756:in `buffer_open'
                  5: from /usr/lib/ruby/2.6.0/open-uri.rb:337:in `open_http'
                  4: from /usr/lib/ruby/2.6.0/net/http.rb:919:in `start'
                  3: from /usr/lib/ruby/2.6.0/net/http.rb:930:in `do_start'
                  2: from /usr/lib/ruby/2.6.0/net/http.rb:996:in `connect'
                  1: from /usr/lib/ruby/2.6.0/net/protocol.rb:44:in `ssl_socket_connect'
          /usr/lib/ruby/2.6.0/net/protocol.rb:44:in `connect_nonblock': SSL_connect returned=1 errno=0 state=error: certificate verify failed (unable to get local issuer certificate) (OpenSSL::SSL::SSLError)
          sunghyun@SUNGHYUN:~$ export SSL_CERT_DIR=/etc/ssl/certs
          sunghyun@SUNGHYUN:~$ export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
          sunghyun@SUNGHYUN:~$ ruby -ropen-uri -e 'eval open("https://git.io/vQhWq").read'
          Here's your Ruby and OpenSSL environment:

          Ruby:           2.6.5p114 (2019-10-01 revision 67812) [x86_64-linux-gnu]
          RubyGems:       3.0.3
          Bundler:        1.17.2
          Compiled with:  OpenSSL 1.1.1  11 Sep 2018
          Loaded version: OpenSSL 1.1.1c  28 May 2019
          SSL_CERT_FILE:  /usr/local/ssl/cert.pem
          SSL_CERT_DIR:   /usr/local/ssl/certs

          With that out of the way, let's see if you can connect to rubygems.org...

          Bundler connection to rubygems.org:       failed  ❌  (Net::OpenTimeout)
          RubyGems connection to rubygems.org:      success ✅
          Ruby net/http connection to rubygems.org: success ✅

          Although your Ruby installation and RubyGems can both connect to rubygems.org, Bundler is having trouble. The most likely way to fix this is to upgrade Bundler by running `gem install bundler`. Run this script again after doing that to make sure everything is all set. If you're still having trouble, check out the troubleshooting guide at http://ruby.to/ssl-check-failed 📦
          (eval):136: warning: constant OpenSSL::SSL::SSLContext::METHODS is deprecated
          ```
          - 참고 사이트
            - https://bundler.io/v2.0/guides/rubygems_tls_ssl_troubleshooting_guide.html#troubleshooting-certificate-errors
            - https://github.com/rubygems/rubygems/issues/2415

2. 블로그 세팅
    - 깃허브 페이지 테마 선택 후 클론 및 각종 설정
      ``` bash
      sunghyun@SUNGHYUN:.../mcsmonk.github.io$ gem update
      Could not find gem 'rake (~> 10.0)' in any of the gem sources listed in your Gemfile.
      Run `bundle install` to install missing gems.
      sunghyun@SUNGHYUN:.../mcsmonk.github.io$ bundle install
      sunghyun@SUNGHYUN:.../mcsmonk.github.io$ bundle exec jekyll serve
      ```

