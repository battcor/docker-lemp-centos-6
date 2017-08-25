#
# LEMP stack on CentOS 6
#
FROM centos:6

# ARGS
ENV AWS_ACCESS_KEY_ID=USER_ID
ENV AWS_SECRET_ACCESS_KEY=ACCESS_KEY
ENV AWS_DEFAULT_REGION=REGION

RUN yum -y install epel-release
RUN yum -y install wget
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN wget https://centos6.iuscommunity.org/ius-release.rpm
RUN rpm -Uvh ius-release*.rpm
RUN yum -y update

# Install PHP 5.6 and extensions
RUN yum -y install php56u-fpm php56u php56u-opcache php56u-xml php56u-mcrypt php56u-gd php56u-devel php56u-mysql php56u-intl php56u-mbstring php56u-bcmath php56u-pecl-memcache

# Install MariaDB
COPY settings/yum/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN yum -y install MariaDB-server MariaDB-client

# Install Phalcon
COPY settings/yum/phalcon.so /usr/lib64/php/modules
RUN echo -e "extension=phalcon.so" > /etc/php.d/phalcon.ini

# Other configs / timezone, short tags, etc
COPY settings/php.d /etc/php.d

# Install Nginx
RUN yum -y install nginx

# Copy Nginx config files
COPY settings/nginx/conf.d /etc/nginx/conf.d
COPY settings/nginx/nginx.conf /etc/nginx/nginx.conf

# Install utilities
RUN yum -y install git unzip

# Install AWS CLI
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

RUN aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
RUN aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
RUN aws configure set default.region $AWS_DEFAULT_REGION

# Set the working directory
WORKDIR /var/www/html

# Copy source codes
COPY . ./

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
RUN composer install

# Install supervisor
RUN yum -y install supervisor
RUN chkconfig supervisord on
COPY settings/yum/supervisord.conf /etc/

CMD ["sh","scripts/start.sh"]

EXPOSE 80
EXPOSE 443
