### update-cf
A small bash script that handles the updating of your A record on CloudFlare.

The project consists of two files:
* ``` update-cf.sh ```
  Handles the update
* ``` .env ```
  Configuration for your client

##### Configuration ##### 
###### CF_EMAIL ######
Your email adress, associated with your account on cloudflare.

###### CF_TOKEN ######
Your global API access token

###### ZONE_NAME ######
Your domain
