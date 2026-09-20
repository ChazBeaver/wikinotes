# 403 Error Troubleshooting

## 403 Error from Website and `curl` command

The website was attempted to be reached via web browser (Chrome), but a 403 web page was returned.
I tried to reach the application from the bastion server and got the same 403 returned to me.
What this indicated to me:
 - DNS appears to be working
   - otherwise; would have been `Could not resolve host`
 - Networking/Firewall seems to be fine
   - otherwise; would have received `Connection timed out` or something
 - A response was received over HTTPS, so TLS seems to be working
   - otherwise; would have received `Connection refused`
   - `403 Forbidden` would have meant App or proxy is reachable but blocking access
 - Application LB was reachable because 403 was returned
 
If the traffic was getting all the way to the cluster, then the problem is not network related.
The problem is likely access logic
The next thing to test would be Istio or app behavior, not NLB, DNS, or TLS

## Check the Istio Ingress Logs

1) Pick the active ingress-gateway pod

2) Stream recent Envoy (istio-proxy) access logs and filter for your host + key paths

    ```bash
    k -n istio-gateway logs <gateway-pod> -c istio-proxy --since=15m \
    | egrep 'application\.something\.com' \
    | egrep -E ' "GET /| "HEAD /| /api/op/state/sse| /ui'
    ```

3) Evaluate the log line and what it means

    "HEAD / HTTP/2" 403 - via_upstream ... "application.something.com" "10.134.133.0:54000" outbound|8080||app-service.namespace.svc.cluster.local

--------------------------------------------------------------

    "HEAD / HTTP/2" → Method/Path/Protocol that hit the gateway.

    403 → The request reached a backend and was forbidden.

    via_upstream → Envoy forwarded to the service; the upstream (app or its proxy) produced the 403 (not the gateway itself).

    outbound|8080||app-service... → Istio routed to the my-app service on port 8080 (good routing).

    "application.something.com" → The Host header matched your VirtualService host (good).
    
--------------------------------------------------------------

4) Why this ruled out AWS/LB/firewall

If AWS/NLB or a firewall blocked it, you’d see no Envoy access log for the request. Seeing the request in the ingress Envoy log proves it:

 - Reached the gateway pod

 - Matched your host

 - Routed to the service

 - Got a 403 from upstream behavior, not from external networking

Since ingress routing was correct and traffic reached the service, the 403 cause must be application behavior (e.g., HEAD not allowed on certain paths) or per-route policy, not DNS/TLS/NLB. That’s why we pivoted to testing exact paths/methods (/ui with GET vs /api/op/state/sse with HEAD) and checking app responses directly.


## Logs showed Blackbox Exporter/Prometheus hitting the app

Checked istio-gateway (deploy/internal-ingressgateway -c istio-proxy) logs and application istio-proxy (the istio sidecar) logs

    ```bash
    # Sanity check: HEAD on the SSE endpoint returns 405 (method not allowed)
    curl -skI -X HEAD https://application.something.com/api/op/state/sse
    ```
    
## "GET /ui HTTP/2" 403

--------------------------------------------------------------------------------------------------------

PRO-TIP

Why use curl -I instead of a normal GET

We didn’t need the file content—we just needed to confirm:

✅ Does it return 200 OK (good), or
❌ A 403/404 (bad)

HEAD requests are faster because they don't download the body—just the headers. This is perfect for quick routing checks.

--------------------------------------------------------------------------------------------------------

Gateway logs: show 403s on /ui for our host

Quick reproduce from outside

```bash
curl -skI https://application.something.com/ui
```

What this told me (brief)

 - A normal GET /ui was returning 403, so real users were blocked.

 - Not just monitor noise anymore → this is an actual access/routing issue.

Next step

 - Inspect VirtualService/route/rewrite for frontend path.

## "GET /api/op/state/sse" 403 — backend state stream blocked

Gateway logs: look for 403s on SSE endpoint

Reproduce like a browser (SSE requires Accept: text/event-stream)

```bash
curl -skI -H 'Accept: text/event-stream' \
  https:///application.something.com/api/op/state/sse
```

From inside the pod (bypasses Istio pathing)

```bash
k -n my-app exec deploy/my-app -c my-app -- \
  node -e "require('http').get('http://127.0.0.1:54000/api/op/state/sse',r=>{console.log(r.statusCode);r.resume();});"
```

What this told me (brief)

 - The SSE API was 403 at the gateway, but 200 directly in the pod → Istio/routing/headers issue, not app code.

Next step

 - Verify/adjust headers and VirtualService so SSE works (pass Host, X-Forwarded-Proto, etc.).


## "GET /serviceWorker.js" 403 — static file path not routed

Why we tried /serviceWorker.js

When we loaded the app from the browser and saw that it still didn’t render correctly, we checked the gateway logs and noticed this line:


"GET /serviceWorker.js" 403


That was a big clue. Modern web apps often use a Service Worker, which is a small JavaScript file used for caching and app lifecycle behavior (like offline support or background sync). If that file can’t load, the browser won’t fully initialize the app UI.

So we targeted it because:

- It showed up in the logs
- Browsers automatically request /serviceWorker.js
- A 403 here means something is blocking normal UI behavior
- It helped confirm whether static files were being routed correctly

----------------------------------------------------------------------------------------------

Gateway logs: service worker requests failing

Reproduce

```bash
curl -skI https://application.something.com/serviceWorker.js
```

What this told me (brief)

 - Static asset path wasn’t being served through the current routing rules.

Conclusion / Fix applied

 - VirtualService needed proper frontend route handling (rewrite /ui → /) so the UI and its assets resolve correctly. After adjusting rewrite/headers, browser access worked.


## Check the Application logs

The application had no errors and was not rejecting any requests

This means that something in front of the application is!

Conclusion: It must be Istio routing or headers

Next Step: Test locally inside the pod to see what behavior we get


## Inside the Pod

```bash
GET http://127.0.0.1:54000/ -> 200 OK
```

 - What it told us: App works normally inside the pod.

 - What it ruled out: NOT an app bug — problem happens before traffic reaches app.

 - Conclusion: Must be handled by Istio or Envoy.

 - Next step: Try adding headers that browsers normally send.


## Pod test with browser-style headers

below is a command derived from ChatGPT to help mimic/simulate what the gateway/browser sends to see if the app expexts `Host`/`X-Forwarded-proto` and behaves differently with them.

```bash
k -n my-app exec deploy/my-app -c my-app -- \
  node -e "require('http').get({
    host:'127.0.0.1',port:54000,path:'/ui',
    headers:{
      'Host':'application.something.com',
      'X-Forwarded-Proto':'https',
      'X-Forwarded-Host':'application.something.com',
      'X-Forwarded-Port':'443',
      'User-Agent':'Mozilla/5.0',
      'Origin':'https://application.something.com'
    }},r=>{console.log('STATUS',r.statusCode);r.resume();});"
```

What it told us: With those headers, the app is happy → confirms it relies on them (proxy-aware behavior).

Conclusion: Ensure the gateway passes these (Envoy normally does). Header rewrites weren’t strictly required long-term, but this proved the point.


## HEAD test returns 405

Why: Blackbox/monitoring often uses `HEAD`. We needed to confirm the API simply doesn’t support `HEAD`.

```bash
curl -skI -X HEAD https://application.something.com/api/op/state/sse
```

Result: `405 Method Not Allowed` (and `Allow: GET`).
What it told us: That endpoint only supports `GET`. HEAD will always look “bad.”
Why use `curl -I -X HEAD`?

`-I` asks for headers only (fast, no body).

`-X HEAD` forces the exact method (mirrors monitoring behavior).

This precisely reproduces the monitor’s probe.

Fix: Point monitoring to `GET /ui` (or change probe method to `GET`) to avoid false alarms.


## Browser simulation with SSE

Why: Prove the endpoint works when called the way a browser does (Server-Sent Events).

Command:

```bash
curl -sk \
  -H 'Accept: text/event-stream' \
  https://application.something.com/api/op/state/sse \
  --max-time 5
```


(optional, even closer to browser)

```bash
curl -sk \
  -H 'Origin: https://application.something.com' \
  -H 'User-Agent: Mozilla/5.0' \
  -H 'Accept: text/event-stream' \
  https://application.something.com/api/op/state/sse \
  --max-time 5
```


Result: You saw event: state-report → success.
What it told us: The API is fine for real browser usage. The “errors” were the method mismatch (HEAD vs GET), not an app failure.


## Bonus: What each curl command did and why we used it
Command	                  Purpose	                  Example
curl -k 	    Ignore certificate errors (TLS)	      curl -k https://site
curl -I	      Only fetch HTTP headers, no body	      curl -k -I https://site
curl -X       HEAD	Force HTTP method to HEAD	      curl -k -I -X HEAD https://site
curl -H	      Add HTTP headers manually	      curl -H 'Header: value' https://site
curl --max-time	      Stop hanging if response streams  	    curl --max-time 5 https://site
