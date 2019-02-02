#/bin/bash

scalafmt_ng &

sleep 10
ng ng-alias scalafmt org.scalafmt.cli.Cli
ng scalafmt --version
