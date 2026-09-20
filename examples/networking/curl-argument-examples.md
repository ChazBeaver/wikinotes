# Curl Argument Examples

Command	                    Purpose	                      Example
curl -k 	        Ignore certificate errors (TLS)	      curl -k https://site
curl -I	          Only fetch HTTP headers, no body	    curl -k -I https://site
curl -X HEAD	    Force HTTP method to HEAD	            curl -k -I -X HEAD https://site
curl -H	          Add HTTP headers manually	            curl -H 'Header: value' https://site
curl --max-time	  Stop hanging if response streams  	  curl --max-time 5 https://site

