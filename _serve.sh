#!/usr/bin/env bash

###
#
# Build and serve a site made with Jekyll (https://jekyllrb.com).
#
#
# Copyright (C) 2020  Nicolas Jeanmonod, ouilogique.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
##


rm -rf _site

# Get default route interface
if=$(route -n get 0.0.0.0 2>/dev/null | awk '/interface: / {print $2}')
if [ -n "$if" ]; then
    echo "Default route is through interface $if"
else
    echo "No default route found"
fi

# Get IP of the default route interface
IP=$( ipconfig getifaddr $if )

# Find an available port
PORTMIN=8000
PORTMAX=8009
PORT=$PORTMIN
while true; do
    PORTINUSE=$( lsof -i tcp:$PORT )
    if [ -z "$PORTINUSE" ]; then
        break;
    fi
    echo "$IP:$PORT already in use"

    PORT=$((PORT+1))
    if [ "$PORT" -gt "$PORTMAX" ]; then
        echo "No available port found between $PORTMIN and $PORTMAX."
        exit 1
    fi
done

# Saves the settings in the development config file.
# http://stackoverflow.com/questions/24633919/prepend-heredoc-to-a-file-in-bash
CONFIG_DEV="_config_dev.yml"
read -r -d '' CONFIG_STR << EOF
url: http://$IP:$PORT
host: $IP
port: $PORT
baseurl: ""
unpublished: true
incremental: true

sass:
  style: normal
l
EOF
# trick to pertain newline at the end of a message
# see here: http://unix.stackexchange.com/a/20042
CONFIG_STR=${CONFIG_STR%l}
printf %s "$CONFIG_STR" > $CONFIG_DEV
cat $CONFIG_DEV

# Use ruby from Homebrew
ruby -v
which ruby
# export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# Ruby 3.3 doesn’t work. Install ruby 3.1 with
# brew install ruby@3.1
export PATH="/opt/homebrew/Cellar/ruby@3.1/3.1.4/bin:$PATH"
ruby -v
which ruby

# Start Jekyll.
# Remove `2>/dev/null` to see warnings.
bundle exec jekyll serve --config _config.yml,_config_dev.yml # 2>/dev/null

# In case of problems
# Delete:
#   Gemfile.lock
# Execute:
#   bundle install
#   gem update jekyll

