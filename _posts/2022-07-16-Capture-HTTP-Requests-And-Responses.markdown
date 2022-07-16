---
layout: post
title:  "Capturing HTTP Requests and Responses with Istio Filters"
date:   2022-07-16 14:38:00 +0000
categories: Kubernetes K8S Istio
---

One thing that's sometimes useful when debugging a system running on Kubernetes is capturing what exactly has been sent and received through the Istio proxy. This post covers how to set up an Istio filter to log out information and payloads to Istio's logs for HTTP requests.

First, turn up the logging level for the app you want to observe in the deployment.yaml page for your app:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: productpage-v1
  labels:
    app: productpage
    version: v1
spec:
  template:
    metadata:
      annotations:
        sidecar.istio.io/logLevel: "info"
```

Then apply the following filter:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: book-info-product-page-filter
spec:
  workloadSelector:
    labels: 
      app: productpage
  configPatches:
  - applyTo: HTTP_FILTER
    match: 
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
            name: 'envoy.filters.network.http_connection_manager'
            subFilter:
              name: 'envoy.filters.http.router'
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.lua
        typed_config:
          "@type": "type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua"
          inline_code: |
            function envoy_on_request(request_handle)
              request_handle:logInfo("Request method: "..request_handle:headers():get(":method"))
              
              local body = request_handle:body()
              if (body ~= null) then
                local bodyBytes = body:getBytes(0, body:length())
                request_handle:logInfo("Request body: "..bodyBytes)
              end
            end
            function envoy_on_response(response_handle)
              response_handle:logInfo("Response status: "..response_handle:headers():get(":status"))
              
              local body = response_handle:body()
              if (body ~= null) then
                local bodyBytes = body:getBytes(0, body:length())
                response_handle:logInfo("Response body: "..bodyBytes)
              end
            end
```

What this will do is insert a Lua script that is run before each HTTP request is handled by Istio, for the apps selected by the `workloadSelector` - in this case the filter is applied to any apps labelled `productpage`. 

The Lua script implements two functions: 
```lua
function envoy_on_request(request_handle)
function envoy_on_response(response_handle)
```

The `request_handle` and `response_handle` objects contain information about the HTTP request and response, including headers and the request/response body. The supported methods are documented here:

https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/lua_filter#config-http-filters-lua-stream-handle-api 

Once this filter is applied to your cluster, you will need to at least restart the Istio proxy that you want to log info from for it to pick up the new filter.
After this, each HTTP request will result in entries like the following being written to Istio proxy logs:

```
2022-07-16T14:56:12.288433Z    info    envoy lua    script log: Request method: GET
2022-07-16T14:56:12.372937Z    info    envoy lua    script log: Response status: 200    
```

Sample code used in this post can be found here: https://github.com/Sarkimedes/istio-filter-demo

