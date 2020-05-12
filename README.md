### update-cf
A small bash script that acts as a DDNS client for CloudFlare.

The project consists of two files:
* ``` update-cf.sh ```
  Handles the update
* ``` .env ```
  Configuration for your client

#### Get Started in two simple steps ####
1. Start by copy ```.env.example``` to ```.env``` and provide your information there.  
   The configuration directives are described below.
2. Execute ``` $ ./update-cf.sh ```

Note that the user executing the script must have write access to the catalog where
the script is executed.  
A small file, ```ip```, is created which keeps track of your current IP address.

If Your IP address was updated, the result of the operation is logged to syslog.

#### Configuration ####
| Name            | Description                                                    |
| --------------- | -------------------------------------------------------------- |
| ```CF_EMAIL```  | Your email adress, associated with your account on cloudflare. |
| ```CF_TOKEN```  | Your ***global*** CloudFlare API access token.                 |
| ```ZONE_NAME``` | Your domain. i.e. ```example.com```                            |

#### Scheduling of the updater with Crontab ####
Since the API at CloudFlare only is called when the IP needs to be updated it is safe
to execute this script frequently.

The snippet belows describes how to add an entry in Crontab for running it each 15 minutes.

```
*/15 * * * * ~/scripts/ddns/update-cf.sh > /dev/null 2>&1
```
